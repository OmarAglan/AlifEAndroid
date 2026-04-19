import "package:flutter/material.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:provider/provider.dart";
import "package:taif/core/services/run_command.dart";
import "package:taif/core/theme/colors.dart";
import "package:taif/core/theme/text.dart";
import "package:taif/data/ide_data.dart";
import "package:taif/generated/l10n.dart";

class TerminalTopBar extends StatelessWidget {
  const TerminalTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(S.of(context).terminal, style: ThemeText.title),
          Consumer<IdeData>(
            builder: (context, data, child) => Row(
              children: [
                IconButton(
                  icon: const Icon(
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
                  onPressed: () => runCommand(context, "الف ملف"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
