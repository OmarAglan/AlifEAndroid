import 'package:flutter/material.dart';
import 'package:alifeditor/core/theme/Colors.dart';

class MyBottomsheet extends StatefulWidget {
  const MyBottomsheet({super.key, required this.child});

  final Widget child;

  @override
  State<MyBottomsheet> createState() => _MyBottomsheetState();
}

class _MyBottomsheetState extends State<MyBottomsheet> {
  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final baseHeight = MediaQuery.of(context).size.height * 0.7;
    final extraHeight = keyboardHeight > 0 ? keyboardHeight / 1.5 : 0;
    final totalHeight = baseHeight + extraHeight;

    return SafeArea(
      child: Container(
        height: totalHeight,
        decoration: BoxDecoration(
          color: ThemeColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: widget.child,
      ),
    );
  }
}
