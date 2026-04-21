import "package:flutter/material.dart";
import "../theme/colors.dart";

class CustomBottomSheet extends StatelessWidget {
  const CustomBottomSheet({
    super.key,
    required this.child,
    this.padding,
    this.height,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final baseHeight = MediaQuery.of(context).size.height * 0.6;
    final extraHeight = keyboardHeight > 0 ? keyboardHeight / 2 : 0;
    final totalHeight = baseHeight + extraHeight;

    return SafeArea(
      child: Container(
        height: height ?? totalHeight,
        padding: padding ?? const EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
          color: context.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: child,
      ),
    );
  }
}
