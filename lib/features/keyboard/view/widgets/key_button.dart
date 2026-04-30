import "dart:async";

import "package:flutter/material.dart";

import "../../../../constants.dart";
import "../../../../core/theme/colors.dart";

class KeyButton extends StatefulWidget {
  const KeyButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.onLongPress,
    this.shortcutLabel,
    this.isRepeatable = false,
    this.onPanUpdate,
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
  State<KeyButton> createState() => _KeyButtonState();
}

class _KeyButtonState extends State<KeyButton> {
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
