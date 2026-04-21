import "package:code_forge/code_forge.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../../../../constants.dart";
import "../../../../core/services/files/save_file.dart";
import "../../../../core/theme/alif_dark_theme.dart";
import "../../../../core/theme/alif_lang/alif.dart";
import "../../../../data/ide_data.dart";

extension CodeForgeControllerValueExt on CodeForgeController {
  set value(TextEditingValue newValue) {
    text = newValue.text;
    selection = newValue.selection;
  }
}

class IDE extends StatefulWidget {
  const IDE({super.key});

  @override
  State<IDE> createState() => _IDEState();
}

class _IDEState extends State<IDE> {
  CodeForgeController? codeController;
  bool isSyncing = false;
  late IdeData data;

  @override
  void initState() {
    super.initState();
    data = Provider.of<IdeData>(context, listen: false);

    if (data.isReady) {
      _initController();
    } else {
      data.addListener(_onDataReady);
    }
  }

  @override
  void dispose() {
    data.removeListener(_onDataReady);
    codeController?.dispose();
    super.dispose();
  }

  void _onDataReady() {
    if (data.isReady && codeController == null) {
      _initController();
      data.removeListener(_onDataReady);
    }
  }

  void _initController() {
    codeController = CodeForgeController();

    codeController!.value = TextEditingValue(
      text: data.code.text,
      selection: data.code.selection,
    );

    codeController!.addListener(() async {
      if (isSyncing) return;

      if (data.code.text != codeController!.text ||
          data.code.selection != codeController!.selection) {
        isSyncing = true;

        data.editCode(
          codeController!.text,
          selection: codeController!.selection,
          markDirty: true,
        );

        if (data.autoSave) {
          if (data.selectedFile.path?.isNotEmpty ?? false) {
            await saveFileToStorage(context);
          } else {
            await saveFilesLocal(context);
          }
        }

        isSyncing = false;
      }
    });

    data.code.addListener(() {
      if (!mounted || codeController == null || isSyncing) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || isSyncing) return;

        if (codeController!.text != data.code.text ||
            codeController!.selection != data.code.selection) {
          isSyncing = true;

          final newText = data.code.text;
          final newSelection = data.code.selection;

          codeController!.value = TextEditingValue(
            text: newText,
            selection: newSelection.copyWith(
              baseOffset: newSelection.baseOffset.clamp(0, newText.length),
              extentOffset: newSelection.extentOffset.clamp(0, newText.length),
            ),
          );

          isSyncing = false;
        }
      });
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: codeController == null
          ? const Center(child: CircularProgressIndicator())
          : Consumer<IdeData>(
              builder: (context, data, child) {
                return CodeForge(
                  controller: codeController,
                  customCodeSnippets: alifSnippets,
                  language: alif,
                  editorTheme: alifDarkTheme,
                  focusNode: data.focusNode,
                  textDirection: TextDirection.rtl,
                  textStyle: TextStyle(
                    fontFamily: kMainFont,
                    fontSize: data.fontSize,
                  ),
                  enableFolding: false,
                  enableGuideLines: false,
                );
              },
            ),
    );
  }
}
