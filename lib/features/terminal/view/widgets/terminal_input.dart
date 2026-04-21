import "package:flutter/material.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:provider/provider.dart";
import "../../../../core/services/run_command.dart";
import "../../../../core/theme/colors.dart";
import "../../../../data/ide_data.dart";

class TerminalInput extends StatelessWidget {
  TerminalInput({super.key});
  final TextEditingController inputController = TextEditingController();
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
    if (!context.mounted) return;
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
              style: TextStyle(color: context.foreground),
              decoration: InputDecoration(
                hintText: "ادخل هنا",
                hintStyle: TextStyle(color: context.secondary),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            onPressed: () => runCommandHandler(data, context),
            icon: Icon(LucideIcons.arrowRight, color: context.foreground),
          ),
        ],
      ),
    );
  }
}
