import 'package:flutter/material.dart';
import 'package:taif/core/theme/Colors.dart';

class MyBottomsheet extends StatelessWidget {
  const MyBottomsheet({
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
    final baseHeight = MediaQuery.of(context).size.height * 0.7;
    final extraHeight = keyboardHeight > 0 ? keyboardHeight / 2 : 0;
    final totalHeight = baseHeight + extraHeight;

    return SafeArea(
      child: Container(
        height: height ?? totalHeight,
        decoration: BoxDecoration(
          color: ThemeColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
      ),
    );
  }
}
