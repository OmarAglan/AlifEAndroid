import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:taif/data/ide_data.dart";
import "package:taif/core/theme/Text.dart";
import "package:taif/core/widgets/custom_bottom_sheet.dart";
import "package:taif/features/terminal/view/widgets/terminal_input.dart";
import "package:taif/features/terminal/view/widgets/terminal_top_bar.dart";

class TerminalView extends StatelessWidget {
  const TerminalView({super.key});
  @override
  Widget build(BuildContext context) {
    return CustomBottomSheet(
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
            const TerminalTopBar(),
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
            TerminalInput(),
          ],
        ),
      ),
    );
  }
}
