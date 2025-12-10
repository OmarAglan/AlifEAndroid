import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taif/data/ide_data.dart';
import 'package:taif/core/theme/Colors.dart';
import 'package:taif/core/services/run_command.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class TerminalInput extends StatelessWidget {
  TerminalInput({super.key});
  TextEditingController inputController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  void runCommandHandler(IdeData data, BuildContext context) async {
    if (data.runningProcess?.exitCode == null) {
      if (inputController.text == "clear" || inputController.text == "مسح") {
        data.clearOutput();
        inputController.clear();
        FocusScope.of(context).requestFocus(_focusNode);
        return;
      } else {
        await runCommand(context, inputController.text);
      }
    } else {
      data.sendOutput(inputController.text);
    }
    inputController.clear();
    FocusScope.of(context).requestFocus(_focusNode);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<IdeData>(
      builder: (context, data, child) => Row(
        children: [
          Expanded(
            child: TextField(
              focusNode: _focusNode,
              controller: inputController,
              onSubmitted: (_) => runCommandHandler(data, context),
              style: TextStyle(color: ThemeColors.foreground),
              decoration: InputDecoration(
                hintText: "ادخل هنا",
                hintStyle: TextStyle(color: ThemeColors.secondary),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            onPressed: () => runCommandHandler(data, context),
            icon: Icon(LucideIcons.arrowRight, color: ThemeColors.foreground),
          ),
        ],
      ),
    );
  }
}
