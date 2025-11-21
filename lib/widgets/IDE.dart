import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:provider/provider.dart';
import 'package:taif/core/data/ideData.dart';
import 'package:taif/utils/ide/Theme.dart';
import 'package:taif/utils/ide/alif.dart';

class IDE extends StatefulWidget {
  const IDE({super.key});

  @override
  State<IDE> createState() => _IDEState();
}

class _IDEState extends State<IDE> {
  late CodeController codeController;

  @override
  void initState() {
    super.initState();
    final data = Provider.of<IdeData>(context, listen: false);

    codeController = CodeController(text: data.code.text, language: alif);

    codeController.addListener(() {
      if (data.code.text != codeController.text ||
          data.code.selection != codeController.selection) {
        data.code.value = data.code.value.copyWith(
          text: codeController.text,
          selection: codeController.selection,
          composing: TextRange.empty,
        );
      }
    });

    data.code.addListener(() {
      if (codeController.text != data.code.text ||
          codeController.selection != data.code.selection) {
        codeController.value = codeController.value.copyWith(
          text: data.code.text,
          selection: data.code.selection,
          composing: TextRange.empty,
        );
      }
    });
  }

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<IdeData>(context);

    return Expanded(
      child: SingleChildScrollView(
        child: CodeTheme(
          data: CodeThemeData(styles: {...alifDarkTheme}),
          child: CodeField(
            gutterStyle: GutterStyle(
              width: 70,
              showErrors: false,
              showFoldingHandles: false,
              textAlign: TextAlign.center,
            ),
            controller: codeController,
            focusNode: data.focusNode,
            textStyle: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: data.fontSize.toDouble(),
              height: 1.4,
            ),
          ),
        ),
      ),
    );
  }
}
