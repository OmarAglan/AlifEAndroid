import "package:flutter/material.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:provider/provider.dart";
import "../../../core/providers/workspace_provider.dart";
import "../../../core/theme/colors.dart";
import "../../../core/theme/text.dart";
import "../data/shortcuts_data.dart";

class ShortcutsView extends StatelessWidget {
  const ShortcutsView({super.key});

  @override
  Widget build(BuildContext context) {
    final shortcusts = context.read<ShortcutsProvider>();
    final workspace = context.watch<WorkspaceProvider>();
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ShortCutButton(
                onPressed: () => workspace.toggleSearch(),
                child: Icon(
                  workspace.findController.isActive
                      ? LucideIcons.x
                      : LucideIcons.search,
                ),
              ),
              if (workspace.undoController.canUndo)
                ShortCutButton(
                  onPressed: () => workspace.undoController.undo(),
                  child: const Icon(LucideIcons.undo2, size: 15),
                ),
              if (workspace.undoController.canRedo)
                ShortCutButton(
                  onPressed: () => workspace.undoController.redo(),
                  child: const Icon(LucideIcons.redo2, size: 15),
                ),
              ...List.generate(
                shortcusts.shortcuts.length,
                (index) => ShortCutButton(
                  onPressed: () => shortcusts.insertText(context, index),
                  child: Text(
                    shortcusts.shortcuts[index].name,
                    textAlign: TextAlign.center,
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

class ShortCutButton extends StatelessWidget {
  const ShortCutButton({
    super.key,
    required this.child,
    required this.onPressed,
  });

  final Widget child;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(1),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 0,
          maxWidth: 37,
          maxHeight: 30,
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0x601A2340),
            foregroundColor: context.foreground,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            textStyle: ThemeText.mid,
          ),
          onPressed: () => onPressed(),
          child: child,
        ),
      ),
    );
  }
}
