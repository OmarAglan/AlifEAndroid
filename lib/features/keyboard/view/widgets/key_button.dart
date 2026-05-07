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
    this.shortcut,
    this.isRepeatable = false,
    this.onPanUpdate,
    this.onPanEnd,
    this.disabled = false,
  });

  final dynamic child;
  final VoidCallback onPressed;
  final VoidCallback? onLongPress;
  final dynamic shortcut;
  final bool isRepeatable;
  final Function(DragUpdateDetails)? onPanUpdate;
  final Function(DragEndDetails)? onPanEnd;
  final bool disabled;

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
      if (widget.onLongPress != null) widget.onLongPress!();
      if (widget.isRepeatable) {
        _periodicTimer = Timer.periodic(const Duration(milliseconds: 50), (
          timer,
        ) {
          widget.onPressed();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mainContent = _buildContent(widget.child);
    final shortcutContent = widget.shortcut != null
        ? _buildContent(
            widget.shortcut,
            iconSize: 14,
            fontSize: kSoSmallFont,
            color: context.secondary,
          )
        : null;

    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Material(
        color: const Color(0x601A2340),
        borderRadius: BorderRadius.circular(8),
        child: GestureDetector(
          onPanUpdate: widget.disabled ? null : widget.onPanUpdate,
          onPanEnd: widget.disabled ? null : widget.onPanEnd,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTapDown: widget.disabled ? null : _handleTapDown,
            onTap: widget.disabled
                ? null
                : () {
                    if (!_isLongPressed) widget.onPressed();
                    _stopTimers();
                  },
            onTapCancel: widget.disabled ? null : _stopTimers,
            child: SizedBox(
              height: 45,
              width: 45,
              child: shortcutContent == null
                  ? Center(child: mainContent)
                  : Stack(
                      alignment: Alignment.center,
                      children: [
                        mainContent,
                        Positioned(top: 2, right: 4, child: shortcutContent),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    dynamic data, {
    double? iconSize,
    double? fontSize,
    Color? color,
  }) {
    if (data is Widget) return data;
    if (data is IconData) {
      return Icon(
        data,
        size: iconSize ?? 17,
        color: widget.disabled ? context.secondary : color,
      );
    }
    if (data is String) {
      return Text(
        data,
        style: TextStyle(
          fontSize: fontSize ?? kLargeFont,
          color: widget.disabled ? context.secondary : color,
        ),
      );
    }
    return Text(data.toString());
  }
}
