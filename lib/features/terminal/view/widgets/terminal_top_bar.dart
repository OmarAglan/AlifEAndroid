import "package:flutter/material.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:provider/provider.dart";
import "../../../../constants.dart";
import "../../../../core/services/run_command.dart";
import "../../../../core/theme/colors.dart";
import "../../../../core/theme/text.dart";
import "../../../../data/ide_data.dart";

class TerminalTopBar extends StatelessWidget {
  const TerminalTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const SizedBox(width: kMediumPadding),
            Text(l10n.terminal, style: ThemeText.title),
          ],
        ),
        Consumer<IdeData>(
          builder: (context, data, child) => Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.clear_all_rounded,
                  color: context.foreground,
                  size: kSmallFont * 2,
                ),
                onPressed: data.clearOutput,
              ),
              IconButton(
                icon: Icon(
                  data.runningProcess?.exitCode == null
                      ? LucideIcons.play
                      : LucideIcons.square,
                  size: kLargeFont,
                  color: data.runningProcess?.exitCode == null
                      ? context.foreground
                      : Colors.red,
                ),
                onPressed: () => runCommand(context, "الف ملف"),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
