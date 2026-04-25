import "package:flutter/material.dart";
import "../../constants.dart";
import "colors.dart";

abstract class ThemeText {
  static const TextStyle smallG = TextStyle(
    fontSize: kSmallFont,
    color: AppColors.secondary,
  );

  static const TextStyle smallW = TextStyle(
    fontSize: kSmallFont,
    color: AppColors.foreground,
  );

  static const TextStyle mid = TextStyle(
    fontSize: kMediumFont,
    fontFamily: kMainFont,
    color: AppColors.secondary,
  );

  static const TextStyle title = TextStyle(
    fontSize: kLargeFont,
    fontWeight: FontWeight.bold,
    color: AppColors.foreground,
  );
}
