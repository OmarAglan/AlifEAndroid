import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_code_editor/src/code_modifiers/insertion.dart';
import 'package:provider/provider.dart';
import 'package:taif/data/ide_data.dart';
import 'package:taif/core/services/files/save_file.dart';
import 'package:taif/core/theme/Theme.dart';
import 'package:taif/core/theme/alif.dart';

class IDE extends StatefulWidget {
  const IDE({super.key});

  @override
  State<IDE> createState() => _IDEState();
}

class _IDEState extends State<IDE> {
  CodeController? codeController;

  bool isSyncing = false;

  @override
  void initState() {
    super.initState();
    final data = Provider.of<IdeData>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (data.isReady) {
        _initController(data);
      }
    });
  }

  @override
  void dispose() {
    codeController?.dispose();
    super.dispose();
  }

  void _initController(IdeData data) {
    codeController = CodeController(
      text: data.code.text,
      language: alif,
      modifiers: [
        const CloseBlockModifier(),
        const TabModifier(),
        InsertionCodeModifier.backticks,
        InsertionCodeModifier.braces,
        InsertionCodeModifier.brackets,
        InsertionCodeModifier.doubleQuotes,
        InsertionCodeModifier.parentheses,
        InsertionCodeModifier.singleQuotes,
      ],
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

        data.files[data.selectedFile.id!].code = codeController!.text;

        if (data.autoSave) {
          if (data.selectedFile.path!.isNotEmpty) {
            saveFileToStorage(context);
          } else {
            saveFilesLocal(context);
          }
        } else {
          if (data.selectedFile.id! < 0 || data.files.isEmpty) return;
          data.files[data.selectedFile.id!].saved = false;
        }

        isSyncing = false;
      }
    });

    data.code.addListener(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || codeController == null) return;
        if (isSyncing) return;

        if (codeController!.text != data.code.text ||
            codeController!.selection != data.code.selection) {
          isSyncing = true;

          codeController!.value = codeController!.value.copyWith(
            text: data.code.text,
            selection: data.code.selection,
            composing: TextRange.empty,
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
      child: SingleChildScrollView(
        child: CodeTheme(
          data: CodeThemeData(styles: {...alifDarkTheme}),
          child: codeController == null
              ? SizedBox(height: 200)
              : Consumer<IdeData>(
                  builder: (context, data, child) => CodeField(
                    gutterStyle: GutterStyle(
                      width: 70,
                      showErrors: false,
                      showFoldingHandles: false,
                      textAlign: TextAlign.center,
                    ),
                    controller: codeController!,
                    focusNode: data.focusNode,
                    textStyle: TextStyle(
                      fontSize: data.fontSize.toDouble(),
                      height: 1.4,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
