import "package:flutter/material.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:provider/provider.dart";
import "../../../../constants.dart";
import "../../../../core/providers/terminal_provider.dart";
import "../../../../core/providers/workspace_provider.dart";
import "../../../../core/theme/colors.dart";
import "../../../terminal/functions/run_command.dart";
import "../../../terminal/view/terminal_view.dart";
import "key_button.dart";

class ShortcutsView extends StatelessWidget {
  const ShortcutsView({super.key});

  @override
  Widget build(BuildContext context) {
    final workspace = context.watch<WorkspaceProvider>();
    final terminal = context.watch<TerminalProvider>();
    const double iconSize = 17;

    final bool hasSelection =
        workspace.codeController.selection.start !=
        workspace.codeController.selection.end;

    return SizedBox(
      height: 30,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Run
            KeyButton(
              onPressed: () => {
                context.read<TerminalProvider>().clearOutput(),
                runCommand(context, kAlifBin),
                showTerminalView(context),
              },
              child: Icon(
                terminal.runningProcess?.exitCode == null
                    ? LucideIcons.play
                    : LucideIcons.square,
                size: iconSize,
                color: terminal.runningProcess?.exitCode == null
                    ? context.foreground
                    : Colors.red,
              ),
            ),
            // search
            KeyButton(
              onPressed: () => workspace.toggleSearch(),
              child: Icon(
                workspace.findController.isActive
                    ? LucideIcons.x
                    : LucideIcons.search,
                size: iconSize,
              ),
            ),
            // Tab
            KeyButton(
              onPressed: () => workspace.codeController.indent(),
              child: const Icon(LucideIcons.arrowRightToLine, size: iconSize),
            ),

            // Undo / Redo
            if (workspace.undoController.canUndo)
              KeyButton(
                onPressed: () => workspace.undoController.undo(),
                child: const Icon(LucideIcons.undo2, size: iconSize),
              ),
            if (workspace.undoController.canRedo)
              KeyButton(
                onPressed: () => workspace.undoController.redo(),
                child: const Icon(LucideIcons.redo2, size: iconSize),
              ),

            // تحريك السطور وتكرارها
            KeyButton(
              onPressed: () => workspace.codeController.moveLineUp(),
              child: const Icon(LucideIcons.arrowUp, size: iconSize),
            ),
            KeyButton(
              onPressed: () => workspace.codeController.moveLineDown(),
              child: const Icon(LucideIcons.arrowDown, size: iconSize),
            ),
            KeyButton(
              onPressed: () => workspace.codeController.duplicateLine(),
              child: const Icon(LucideIcons.layers2, size: iconSize),
            ),

            // copy / cut / paste / selectAll
            KeyButton(
              onPressed: () => workspace.codeController.paste(),
              child: const Icon(LucideIcons.clipboard, size: iconSize),
            ),
            if (hasSelection) ...[
              KeyButton(
                onPressed: () => workspace.codeController.copy(),
                child: const Icon(LucideIcons.copy, size: iconSize),
              ),
              if (!workspace.codeController.readOnly)
                KeyButton(
                  onPressed: () => workspace.codeController.cut(),
                  child: const Icon(LucideIcons.scissors, size: iconSize),
                ),
              KeyButton(
                onPressed: () => workspace.codeController.selectAll(),
                child: const Icon(LucideIcons.squareDashed, size: iconSize),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
