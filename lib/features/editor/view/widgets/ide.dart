import "package:flutter/material.dart";
import "package:code_forge/code_forge.dart";
import "package:provider/provider.dart";
import "package:taif/data/ide_data.dart";
import "package:taif/core/services/files/save_file.dart";
import "package:taif/core/theme/alif_dark_theme.dart";
import "package:taif/core/theme/alif.dart";

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

  @override
  void initState() {
    super.initState();
    final data = Provider.of<IdeData>(context, listen: false);

    if (data.isReady) {
      _initController(data);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (data.isReady) {
          _initController(data);
        }
      });
    }
  }

  @override
  void dispose() {
    codeController?.dispose();
    super.dispose();
  }

  void _initController(IdeData data) {
    codeController = CodeForgeController();

    codeController!.value = TextEditingValue(
      text: data.code.text,
      selection: data.code.selection,
    );

    codeController!.addListener(() {
      if (isSyncing) return;

      if (data.code.text != codeController!.text ||
          data.code.selection != codeController!.selection) {
        isSyncing = true;

        data.selectedFile.code = codeController!.text;
        data.editCode(
          codeController!.text,
          selection: codeController!.selection,
        );

        final currentId = data.selectedFile.id;
        if (currentId != null &&
            currentId >= 0 &&
            currentId < data.files.length) {
          data.files[currentId].code = codeController!.text;
        }

        if (data.autoSave) {
          if (data.selectedFile.path?.isNotEmpty ?? false) {
            saveFileToStorage(context);
          } else {
            saveFilesLocal(context);
          }
        } else {
          if (currentId != null &&
              currentId >= 0 &&
              currentId < data.files.length) {
            data.files[currentId].saved = false;
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
                  language: alif,
                  editorTheme: alifDarkTheme,
                  focusNode: data.focusNode,
                  textDirection: TextDirection.rtl,
                  textStyle: const TextStyle(
                    fontFamily: "Tajawal",
                    fontSize: 16,
                  ),
                  enableFolding: false,
                  enableGuideLines: false,
                );
              },
            ),
    );
  }
}
