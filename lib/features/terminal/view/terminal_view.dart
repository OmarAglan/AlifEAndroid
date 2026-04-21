import "package:flutter/material.dart";
import "../../../constants.dart";
import "../../../core/widgets/custom_bottom_sheet.dart";
import "widgets/terminal_input.dart";
import "widgets/terminal_outputs.dart";
import "widgets/terminal_top_bar.dart";

class TerminalView extends StatelessWidget {
  const TerminalView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomBottomSheet(
      child: Padding(
        padding: EdgeInsets.only(
          top: kMediumPadding,
          left: kMediumPadding,
          right: kMediumPadding,
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [TerminalTopBar(), TerminalOutputs(), TerminalInput()],
        ),
      ),
    );
  }
}
