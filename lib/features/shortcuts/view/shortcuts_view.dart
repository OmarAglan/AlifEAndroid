import "package:flutter/material.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:provider/provider.dart";
import "../../../constants.dart";
import "../../../core/providers/workspace_provider.dart";
import "../../../core/theme/colors.dart";

class ShortcutsView extends StatelessWidget {
  const ShortcutsView({super.key});

  @override
  Widget build(BuildContext context) {
    final workspace = context.watch<WorkspaceProvider>();
    const double iconSize = 17;

    final bool hasSelection =
        workspace.codeController.selection.start !=
        workspace.codeController.selection.end;

    return SizedBox(
      height: 30,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // search
            ShortCutButton(
              onPressed: () => workspace.toggleSearch(),
              child: Icon(
                workspace.findController.isActive
                    ? LucideIcons.x
                    : LucideIcons.search,
                size: iconSize,
              ),
            ),
            ShortCutButton(
              onPressed: () => workspace.codeController.indent(),
              child: const Icon(LucideIcons.arrowRightToLine, size: iconSize),
            ),

            // Undo / Redo
            if (workspace.undoController.canUndo)
              ShortCutButton(
                onPressed: () => workspace.undoController.undo(),
                child: const Icon(LucideIcons.undo2, size: iconSize),
              ),
            if (workspace.undoController.canRedo)
              ShortCutButton(
                onPressed: () => workspace.undoController.redo(),
                child: const Icon(LucideIcons.redo2, size: iconSize),
              ),

            // تحريك السطور وتكرارها
            ShortCutButton(
              onPressed: () => workspace.codeController.moveLineUp(),
              child: const Icon(LucideIcons.arrowUp, size: iconSize),
            ),
            ShortCutButton(
              onPressed: () => workspace.codeController.moveLineDown(),
              child: const Icon(LucideIcons.arrowDown, size: iconSize),
            ),
            ShortCutButton(
              onPressed: () => workspace.codeController.duplicateLine(),
              child: const Icon(LucideIcons.layers2, size: iconSize),
            ),

            // copy / cut / paste / selectAll
            ShortCutButton(
              onPressed: () => workspace.codeController.paste(),
              child: const Icon(LucideIcons.clipboard, size: iconSize),
            ),
            if (hasSelection) ...[
              ShortCutButton(
                onPressed: () => workspace.codeController.copy(),
                child: const Icon(LucideIcons.copy, size: iconSize),
              ),
              if (!workspace.codeController.readOnly)
                ShortCutButton(
                  onPressed: () => workspace.codeController.cut(),
                  child: const Icon(LucideIcons.scissors, size: iconSize),
                ),
              ShortCutButton(
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

class ShortCutButton extends StatelessWidget {
  const ShortCutButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.onLongPress,
    this.shortcutLabel,
  });

  final dynamic child;
  final VoidCallback onPressed;
  final VoidCallback? onLongPress;
  final String? shortcutLabel;

  @override
  Widget build(BuildContext context) {
    final Widget mainChild = child is Widget ? child : Text(child.toString());

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
      child: SizedBox(
        height: 40,
        width: 40,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0x601A2340),
            foregroundColor: context.foreground,
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontSize: kLargeFont,
              fontFamily: kMainFont,
            ),
          ),
          onPressed: onPressed,
          onLongPress: onLongPress,
          child: shortcutLabel == null
              ? Center(child: mainChild)
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    Center(child: mainChild),
                    Positioned(
                      top: 2,
                      right: 4,
                      child: Text(
                        shortcutLabel!,
                        style: TextStyle(
                          fontSize: kSoSmallFont,
                          color: context.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
