import "dart:async";

import "package:flutter/material.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:provider/provider.dart";
import "../../../constants.dart";
import "../../../core/providers/terminal_provider.dart";
import "../../../core/providers/workspace_provider.dart";
import "../../../core/theme/colors.dart";
import "../../terminal/functions/run_command.dart";
import "../../terminal/view/terminal_view.dart";

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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Run
            ShortCutButton(
              onPressed: () => {
                context.read<TerminalProvider>().clearOutput(),
                runCommand(context, kAlifBin),
                showTerminalView(context),
              },
              child: const Icon(LucideIcons.play, size: iconSize),
            ),
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
            // Tab
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

class ShortCutButton extends StatefulWidget {
  const ShortCutButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.onLongPress,
    this.shortcutLabel,
    this.isRepeatable = false,
    this.onPanUpdate, // هيفيدنا في تحريك المؤشر
    this.onPanEnd,
  });

  final dynamic child;
  final VoidCallback onPressed;
  final VoidCallback? onLongPress;
  final String? shortcutLabel;
  final bool isRepeatable;
  final Function(DragUpdateDetails)? onPanUpdate;
  final Function(DragEndDetails)? onPanEnd;

  @override
  State<ShortCutButton> createState() => _ShortCutButtonState();
}

class _ShortCutButtonState extends State<ShortCutButton> {
  Timer? _delayTimer;
  Timer? _periodicTimer;
  bool _isLongPressed = false;

  void _stopTimers() {
    _delayTimer?.cancel();
    _periodicTimer?.cancel();
  }

  void _handleTapDown(TapDownDetails details) {
    _isLongPressed = false;

    _delayTimer = Timer(const Duration(milliseconds: 200), () {
      _isLongPressed = true;
      if (widget.onLongPress != null) {
        widget.onLongPress!();
      }

      // لو الزرار قابل للتكرار (زي الحذف) بنشغل التايمر الدوري
      if (widget.isRepeatable) {
        _periodicTimer = Timer.periodic(const Duration(milliseconds: 50), (
          timer,
        ) {
          widget.onPressed(); // بيفضل ينفذ الحذف كل ٥٠ مللي ثانية
        });
      }
    });
  }

  void _handleTapUp(TapUpDetails details) {
    if (!_isLongPressed) {
      widget.onPressed(); // ضغطة عادية سريعة
    }
    _stopTimers();
  }

  @override
  void dispose() {
    _stopTimers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Material(
        color: const Color(0x601A2340),
        borderRadius: BorderRadius.circular(8),
        child: GestureDetector(
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _stopTimers,
          onPanUpdate: widget.onPanUpdate,
          onPanEnd: widget.onPanEnd,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: null,
            child: SizedBox(
              height: 45,
              width: 45,
              child: widget.shortcutLabel == null
                  ? Center(
                      child: widget.child is Widget
                          ? widget.child
                          : Text(widget.child.toString()),
                    )
                  : Stack(
                      alignment: Alignment.center,
                      children: [
                        widget.child is Widget
                            ? widget.child
                            : Text(
                                widget.child.toString(),
                                style: const TextStyle(fontSize: kLargeFont),
                              ),
                        Positioned(
                          top: 2,
                          right: 4,
                          child: Text(
                            widget.shortcutLabel!,
                            style: TextStyle(
                              fontSize: kSoSmallFont,
                              color: context.secondary,
                            ), // مثال
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
