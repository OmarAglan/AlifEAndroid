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

class ShortcutsView extends StatefulWidget {
  const ShortcutsView({super.key});

  @override
  State<ShortcutsView> createState() => _ShortcutsViewState();
}

class _ShortcutsViewState extends State<ShortcutsView> {
  void _update() => setState(() {});

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkspaceProvider>().codeController.addListener(_update);
    });
  }

  @override
  Widget build(BuildContext context) {
    final workspace = context.read<WorkspaceProvider>();

    final isSearchActive = context.select<WorkspaceProvider, bool>(
      (p) => p.findController.isActive,
    );
    final isReadOnly = context.select<WorkspaceProvider, bool>(
      (p) => p.codeController.readOnly,
    );
    final canUndo = context.select<WorkspaceProvider, bool>(
      (p) => p.undoController.canUndo,
    );
    final canRedo = context.select<WorkspaceProvider, bool>(
      (p) => p.undoController.canRedo,
    );
    final isRunning = context.select<TerminalProvider, bool>(
      (p) => p.runningProcess?.exitCode == null && p.runningProcess != null,
    );

    final bool hasSelection =
        workspace.codeController.selection.start !=
        workspace.codeController.selection.end;

    const double iconSize = 17;

    return SizedBox(
      height: 30,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: kSmallPadding),
        child: Row(
          children: [
            // زرار التشغيل
            KeyButton(
              onPressed: () {
                final terminal = context.read<TerminalProvider>();
                terminal.clearOutput();
                runCommand(context, kAlifBin);
                showTerminalView(context);
              },
              child: Icon(
                isRunning ? LucideIcons.square : LucideIcons.play,
                size: iconSize,
                color: isRunning ? Colors.red : context.foreground,
              ),
            ),

            KeyButton(
              onPressed: () => workspace.toggleSearch(),
              child: Icon(
                isSearchActive ? LucideIcons.x : LucideIcons.search,
                size: iconSize,
              ),
            ),

            // Tab
            KeyButton(
              onPressed: () => workspace.codeController.indent(),
              child: const Icon(LucideIcons.arrowRightToLine, size: iconSize),
            ),

            // Undo / Redo
            if (canUndo)
              KeyButton(
                onPressed: () => workspace.undoController.undo(),
                child: const Icon(LucideIcons.undo2, size: iconSize),
              ),
            if (canRedo)
              KeyButton(
                onPressed: () => workspace.undoController.redo(),
                child: const Icon(LucideIcons.redo2, size: iconSize),
              ),

            // عمليات السطور
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

            // Clipboard
            KeyButton(
              onPressed: () => workspace.codeController.paste(),
              child: const Icon(LucideIcons.clipboard, size: iconSize),
            ),

            // أزرار التحديد
            if (hasSelection) ...[
              KeyButton(
                onPressed: () => workspace.codeController.copy(),
                child: const Icon(LucideIcons.copy, size: iconSize),
              ),
              if (!isReadOnly)
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

  @override
  void dispose() {
    try {
      context.read<WorkspaceProvider>().codeController.removeListener(_update);
    } catch (_) {}
    super.dispose();
  }
}
