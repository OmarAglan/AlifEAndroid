import "package:flutter/material.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:provider/provider.dart";
import "../../../core/providers/workspace_provider.dart";
import "../../../core/theme/colors.dart";
import "../../../core/theme/text.dart";
import "../data/shortcuts_data.dart";

class ShortcutsView extends StatefulWidget {
  const ShortcutsView({super.key});

  @override
  State<ShortcutsView> createState() => _ShortcutsViewState();
}

class _ShortcutsViewState extends State<ShortcutsView> {
  // دالة التحديث اللي هناديها لما السليكشن يتغير
  void _updateSelection() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // بنجيب الكنترولر ونضيف له الليسنر
    final workspace = Provider.of<WorkspaceProvider>(context, listen: false);
    workspace.codeController.addListener(_updateSelection);
  }

  @override
  void dispose() {
    // مهم جداً تشيله عشان الباقة والجهاز ميهنجوش
    final workspace = Provider.of<WorkspaceProvider>(context, listen: false);
    workspace.codeController.removeListener(_updateSelection);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shortcusts = context.read<ShortcutsProvider>();
    final workspace = context.watch<WorkspaceProvider>();

    // دلوقتي الحساب ده هيتحدث "لحظياً" أول ما تلمس الشاشة
    final bool hasSelection =
        workspace.codeController.selection.start !=
        workspace.codeController.selection.end;

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // زرار البحث
                  ShortCutButton(
                    onPressed: () => workspace.toggleSearch(),
                    child: Icon(
                      workspace.findController.isActive
                          ? LucideIcons.x
                          : LucideIcons.search,
                      size: 15,
                    ),
                  ),
                  ShortCutButton(
                    onPressed: () => workspace.codeController.indent(),
                    child: const Icon(LucideIcons.arrowRightToLine, size: 15),
                  ),

                  // Undo / Redo
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

                  // تحريك السطور وتكرارها
                  ShortCutButton(
                    onPressed: () => workspace.codeController.moveLineUp(),
                    child: const Icon(LucideIcons.arrowUp, size: 15),
                  ),
                  ShortCutButton(
                    onPressed: () => workspace.codeController.moveLineDown(),
                    child: const Icon(LucideIcons.arrowDown, size: 15),
                  ),
                  ShortCutButton(
                    onPressed: () => workspace.codeController.duplicateLine(),
                    child: const Icon(LucideIcons.layers2, size: 15),
                  ),

                  // copy / cut / paste / selectAll
                  ShortCutButton(
                    onPressed: () => workspace.codeController.paste(),
                    child: const Icon(LucideIcons.clipboard, size: 15),
                  ),
                  if (hasSelection) ...[
                    ShortCutButton(
                      onPressed: () => workspace.codeController.copy(),
                      child: const Icon(LucideIcons.copy, size: 15),
                    ),
                    if (!workspace.codeController.readOnly)
                      ShortCutButton(
                        onPressed: () => workspace.codeController.cut(),
                        child: const Icon(LucideIcons.scissors, size: 15),
                      ),
                    ShortCutButton(
                      onPressed: () => workspace.codeController.selectAll(),
                      child: const Icon(LucideIcons.squareDashed, size: 15),
                    ),
                  ],
                ],
              ),
            ),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: List.generate(
                  shortcusts.shortcuts.length,
                  (index) => ShortCutButton(
                    onPressed: () => shortcusts.insertText(context, index),
                    child: Text(
                      shortcusts.shortcuts[index].name,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
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
