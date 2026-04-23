import "dart:io";

import "package:code_forge/code_forge.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../../../../constants.dart";
import "../../../../core/services/files/save_file.dart";
import "../../../../core/theme/alif_dark_theme.dart";
import "../../../../core/theme/alif_lang/alif.dart";
import "../../../../data/ide_data.dart";
import "search_view.dart";

class IDE extends StatefulWidget {
  const IDE({super.key});

  @override
  State<IDE> createState() => _IDEState();
}

class _IDEState extends State<IDE> {
  late IdeData data;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      data = Provider.of<IdeData>(context, listen: false);
      data.code.addListener(_onCodeChanged);
    });
  }

  @override
  void dispose() {
    data.code.removeListener(_onCodeChanged);
    super.dispose();
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
          readOnly: ideData.selectedFile.readOnly,
          customCodeSnippets: alifSnippets,
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
}
