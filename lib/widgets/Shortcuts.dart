import 'package:provider/provider.dart';
import 'package:taif/core/data/ideData.dart';
import 'package:taif/core/theme/Colors.dart';
import 'package:flutter/material.dart';
import 'package:taif/core/theme/Text.dart';

class KeyShortcuts extends StatelessWidget {
  const KeyShortcuts({super.key});

  void _insertText(BuildContext context, String value) {
    final data = Provider.of<IdeData>(context, listen: false);

    final old = data.code;
    final text = old.text;
    final selection = old.selection;

    final newText = text.replaceRange(selection.start, selection.end, value);
    final newPos = selection.start + value.length;

    old.value = old.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newPos),
      composing: TextRange.empty,
    );

    data.focusNode.requestFocus();
  }

  Widget _buildButton(BuildContext context, String label, {String? insert}) {
    return Padding(
      padding: EdgeInsets.all(1),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 0,
          maxWidth: 37,
          maxHeight: 30,
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0x601A2340),
            foregroundColor: ThemeColors.foreground,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            textStyle: ThemeText.mid,
          ),
          onPressed: () => _insertText(context, insert ?? label),
          child: Text(label, textAlign: TextAlign.center),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildButton(context, "↹", insert: "    "),
              _buildButton(context, "("),
              _buildButton(context, '"'),
              _buildButton(context, "'"),
              _buildButton(context, "="),
              _buildButton(context, ":"),
              _buildButton(context, "-"),
              _buildButton(context, "+"),
              _buildButton(context, ")"),
              _buildButton(context, "["),
              _buildButton(context, "]"),
              _buildButton(context, "{"),
              _buildButton(context, "}"),
              _buildButton(context, "#"),
              _buildButton(context, ","),
              _buildButton(context, "\\"),
              _buildButton(context, "*"),
              _buildButton(context, "^"),
              _buildButton(context, "<"),
              _buildButton(context, ">"),
              _buildButton(context, "_"),
              _buildButton(context, "⏎", insert: "/س"),
            ],
          ),
        ),
      ),
    );
  }
}
