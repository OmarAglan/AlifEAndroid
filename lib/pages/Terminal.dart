import 'package:provider/provider.dart';
import 'package:taif/core/data/ideData.dart';
import 'package:taif/core/theme/Colors.dart';
import 'package:taif/core/theme/Text.dart';
import 'package:taif/generated/l10n.dart';
import 'package:taif/utils/runCommand.dart';
import 'package:taif/widgets/BottomSheet.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class Terminal extends StatelessWidget {
  Terminal({super.key});
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
    return MyBottomsheet(
      child: Padding(
        padding: EdgeInsets.only(
          top: 10,
          left: 10,
          right: 10,
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(S.of(context).terminal, style: ThemeText.title),
                  Consumer(
                    builder: (context, IdeData data, child) => Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.clear_all_rounded,
                            color: ThemeColors.foreground,
                            size: 30,
                          ),
                          onPressed: data.clearOutput,
                        ),
                        IconButton(
                          icon: Icon(
                            data.runningProcess?.exitCode == null
                                ? LucideIcons.play
                                : LucideIcons.square,
                            size: 20,
                            color: data.runningProcess?.exitCode == null
                                ? ThemeColors.foreground
                                : Colors.red,
                          ),
                          onPressed: () => runCommand(context, "الف"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                reverse: true,
                child: SizedBox(
                  width: double.infinity,
                  child: Consumer<IdeData>(
                    builder: (context, data, child) => SelectableText(
                      data.output,
                      style: ThemeText.smallW,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ),
              ),
            ),
            Consumer(
              builder: (context, IdeData data, child) => Row(
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
                    icon: Icon(
                      LucideIcons.arrowRight,
                      color: ThemeColors.foreground,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
