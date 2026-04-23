// ترتيب الـ imports يا بطل
import "dart:async";
import "dart:io";

import "package:code_forge/code_forge.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../../../../constants.dart";
import "../../../../core/services/files/save_file.dart";
import "../../../../data/ide_data.dart";
import "../theme/alif_dark_theme.dart";
import "../theme/alif_lang/alif.dart";
import "search_view.dart";

class IDEView extends StatefulWidget {
  const IDEView({super.key});

  @override
  State<IDEView> createState() => _IDEViewState();
}

class _IDEViewState extends State<IDEView> {
  late IdeData data;
  LspStdioConfig? _lspConfig;
  bool _lspInitializing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      data = Provider.of<IdeData>(context, listen: false);
      data.code.addListener(_onCodeChanged);
      _checkAndInitLsp();
      data.addListener(_checkAndInitLsp);
    });
  }

  void _onCodeChanged() async {
    if (data.selectedFile.readOnly) return;
    if (data.selectedFile.code != data.code.text) {
      data.editCode(data.code.text, markDirty: true);

      if (data.autoSave) {
        if (data.selectedFile.path?.isNotEmpty ?? false) {
          await saveFileToStorage(context);
        } else {
          await saveFilesLocal(context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Consumer<IdeData>(
        builder: (context, ideData, child) => CodeForge(
          // init
          controller: ideData.code,
          focusNode: ideData.focusNode,
          language: alif,
          // features
          enableFolding: false,
          enableGuideLines: false,
          enableSuggestions: !Platform.isAndroid,
          customCodeSnippets: alifSnippets,
          readOnly: ideData.selectedFile.readOnly,
          findController: ideData.findController,
          finderBuilder: (context, findController) => PreferredSize(
            preferredSize: const Size.fromHeight(30),
            child: SearchView(findController: findController),
          ),
          // styling
          editorTheme: alifDarkTheme,
          textDirection: TextDirection.rtl,
          innerPadding: const EdgeInsets.only(left: kDefaultPadding * 2),
          textStyle: TextStyle(
            fontFamily: kMainFont,
            fontSize: ideData.fontSize,
            height: Platform.isAndroid ? 1.4 : null,
          ),
          gutterStyle: Platform.isAndroid
              ? GutterStyle(
                  lineNumberStyle: TextStyle(
                    fontSize: ideData.fontSize * 0.95,
                    fontFamily: kMainFont,
                  ),
                )
              : null,
        ),
      ),
    );
  }

  void _checkAndInitLsp() {
    if (data.alifBinPath != null && _lspConfig == null && !_lspInitializing) {
      _lspInitializing = true;
      _initAlifLsp();
    }
  }

  Future<void> _initAlifLsp() async {
    try {
      final workspace = data.workspacePath != null
          ? data.workspacePath!
          : Directory.current.path;

      final alifDir = File(data.alifBinPath!).parent.path;
      const String executableName = "alif_lsp";
      final executablePath = "$alifDir/$executableName";

      if (Platform.isAndroid) {
        await Process.run("chmod", ["+x", executablePath]);
      }

      final env = <String, String>{};
      if (Platform.isAndroid) env["LD_LIBRARY_PATH"] = alifDir;

      _lspConfig = await LspStdioConfig.start(
        executable: executablePath,
        args: [],
        workspacePath: workspace,
        languageId: "alif",
        environment: env,
      );

      data.code.lspConfig = _lspConfig;

      if (data.selectedFile.path != null) {
        data.code.openedFile = data.selectedFile.path;
      }
      debugPrint("Alif LSP Initialized at: $executablePath");
    } catch (e) {
      debugPrint("LSP Initialization Error: $e");
    } finally {
      _lspInitializing = false;
    }
  }

  @override
  void dispose() {
    data.removeListener(_checkAndInitLsp);
    _lspConfig?.dispose();
    data.code.removeListener(_onCodeChanged);
    super.dispose();
  }
}
