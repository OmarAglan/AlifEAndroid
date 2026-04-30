import "dart:async";
import "dart:io";

import "package:code_forge/code_forge.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../../../../constants.dart";
import "../../../../core/providers/settings_provider.dart";
import "../../../../core/providers/workspace_provider.dart";
import "../../../../core/services/files/save_file.dart";
import "../theme/alif_dark_theme.dart";
import "../theme/alif_lang/alif.dart";
import "search_view.dart";

class IDEView extends StatefulWidget {
  const IDEView({super.key});

  @override
  State<IDEView> createState() => _IDEViewState();
}

class _IDEViewState extends State<IDEView> {
  late WorkspaceProvider workspace;
  late SettingsProvider settings;

  LspStdioConfig? _lspConfig;
  bool _lspInitializing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      workspace = context.read<WorkspaceProvider>();
      settings = context.read<SettingsProvider>();

      workspace.codeController.addListener(_onCodeChanged);

      if (Platform.isAndroid) {
        _checkAndInitLsp();
        settings.addListener(_checkAndInitLsp);
      }
    });
  }

  void _onCodeChanged() async {
    if (workspace.selectedFile.code != workspace.codeController.text) {
      workspace.editCode(
        workspace.codeController.text,
        settings.get(AppSetting.autoSave),
        markDirty: true,
      );

      if (settings.get(AppSetting.autoSave)) {
        if (workspace.selectedFile.path?.isNotEmpty ?? false) {
          await saveFileToStorage(context);
        } else {
          await saveFilesLocal(context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final workspace = context.watch<WorkspaceProvider>();
    final settings = context.watch<SettingsProvider>();

    return Expanded(
      child: CodeForge(
        // init
        controller: workspace.codeController,
        undoController: workspace.undoController,
        focusNode: workspace.focusNode,
        language: alif,
        filePath: workspace.selectedFile.path,
        keyboardType: settings.get(AppSetting.customKeyboard)
            ? TextInputType.none
            : TextInputType.multiline,
        // features
        enableFolding: settings.get(AppSetting.enableFolding),
        enableGuideLines: settings.get(AppSetting.enableGuideLines),
        enableSuggestions: settings.get(AppSetting.enableSuggestions),
        lineWrap: settings.get(AppSetting.lineWrap),
        // tapSize: settings.tapSize,
        customCodeSnippets: alifSnippets,
        findController: workspace.findController,
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
          fontSize: settings.get(AppSetting.fontSize),
          height: Platform.isAndroid ? 1.4 : null,
        ),
        gutterStyle: Platform.isAndroid
            ? GutterStyle(
                lineNumberStyle: TextStyle(
                  fontSize: settings.get(AppSetting.fontSize) * 0.95,
                  fontFamily: kMainFont,
                ),
              )
            : null,
      ),
    );
  }

  void _checkAndInitLsp() {
    if (_lspConfig == null && !_lspInitializing) {
      _lspInitializing = true;
      _initAlifLsp();
    }
  }

  Future<void> _initAlifLsp() async {
    try {
      final currentWorkspace =
          workspace.workspacePath ?? Directory.current.path;
      final alifDir = File(settings.alifBinPath).parent.path;
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
        workspacePath: currentWorkspace,
        languageId: "alif",
        environment: env,
      );

      workspace.codeController.lspConfig = _lspConfig;

      if (workspace.selectedFile.path != null) {
        workspace.codeController.openedFile = workspace.selectedFile.path;
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
    settings.removeListener(_checkAndInitLsp);
    workspace.codeController.removeListener(_onCodeChanged);
    _lspConfig?.dispose();
    super.dispose();
  }
}
