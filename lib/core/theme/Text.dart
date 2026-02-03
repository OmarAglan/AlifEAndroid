import "package:flutter/material.dart";
import "package:taif/core/theme/Colors.dart";

abstract class ThemeText {
  static const String fontFamily = "Alif";

  static const double smallF = 14;
  static const double midF = 18;

  static final TextStyle smallG = TextStyle(
    fontSize: smallF,
    color: ThemeColors.secondary,
  );

  static final TextStyle smallW = TextStyle(
    fontSize: smallF,
    color: ThemeColors.foreground,
  );

  static final TextStyle mid = TextStyle(
    fontSize: midF,
    color: ThemeColors.secondary,
  );

  static final TextStyle title = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: ThemeColors.foreground,
  );
}
