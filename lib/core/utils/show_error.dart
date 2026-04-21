import "dart:io";

import "package:flutter/material.dart";
import "package:fluttertoast/fluttertoast.dart";
import "../../constants.dart";
import "../theme/colors.dart";

void showMessage(String msg, {bool? isError, bool isPersistent = false}) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    bool isBottomSheetOpen = false;
    final bgColor = isError == true
        ? AppColors.error
        : isError == false
        ? AppColors.success
        : AppColors.background;

    navigatorKey.currentState?.popUntil((route) {
      if (route is PopupRoute) isBottomSheetOpen = true;
      return true;
    });

    if (isBottomSheetOpen && !Platform.isLinux) {
      ToastHelper.showToast(msg, bgColor);
    } else {
      messengerKey.currentState?.clearSnackBars();
      messengerKey.currentState?.showSnackBar(
        SnackBar(
          content: SelectableText(
            msg,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.foreground),
          ),
          duration: isPersistent
              ? const Duration(days: 365)
              : const Duration(seconds: 3),
          margin: const EdgeInsets.all(kMediumPadding),
          padding: const EdgeInsets.all(kMediumPadding),
          behavior: SnackBarBehavior.floating,
          backgroundColor: bgColor,
        ),
      );
    }
  });
}

class ToastHelper {
  static void showToast(String message, Color bgColor) {
    closeToast();
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: bgColor,
      textColor: AppColors.foreground,
      fontSize: kMediumFont,
    );
  }

  static void closeToast() => Fluttertoast.cancel();
}

void hideMessage() {
  if (!Platform.isLinux) ToastHelper.closeToast();
  messengerKey.currentState?.clearSnackBars();
}
