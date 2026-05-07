import "package:flutter/material.dart";
import "../../../constants.dart";
import "../../../core/widgets/show_bottom_sheet.dart";
import "widgets/terminal_input.dart";
import "widgets/terminal_outputs.dart";
import "widgets/terminal_top_bar.dart";

class TerminalView extends StatelessWidget {
  const TerminalView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: DefaultTextStyle.of(
        context,
      ).style.copyWith(fontFamily: kTerminalFont),
      child: const Column(
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
