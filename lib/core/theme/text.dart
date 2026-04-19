import "package:flutter/material.dart";
import "package:taif/core/theme/colors.dart";

abstract class ThemeText {
  static const String fontFamily = "Alif";

  static const double smallF = 14;
  static const double midF = 18;

  static const TextStyle smallG = TextStyle(
    fontSize: smallF,
    color: ThemeColors.secondary,
  );

  static const TextStyle smallW = TextStyle(
    fontSize: smallF,
    color: ThemeColors.foreground,
  );

  static const TextStyle mid = TextStyle(
    fontSize: midF,
    color: ThemeColors.secondary,
  );

  static const TextStyle title = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: ThemeColors.foreground,
  );
}
