import "package:flutter/material.dart";
import "../../../constants.dart";
import "../../../core/widgets/show_bottom_sheet.dart";
import "widgets/terminal_input.dart";
import "widgets/terminal_outputs.dart";
import "widgets/terminal_top_bar.dart";

// lib/features/terminal/view/terminal_view.dart

class TerminalView extends StatelessWidget {
  const TerminalView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: kMediumPadding),
      child: Column(
        children: [
          Expanded(child: TerminalOutputs()),
          TerminalInput(),
        ],
      ),
    );
  }
}

void showTerminalView(BuildContext context) {
  showMyBottomSheet(
    context: context,
    header: const TerminalTopBar(),
    child: const TerminalView(),
  );
}
