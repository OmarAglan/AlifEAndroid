import "dart:async";
import "package:flutter/material.dart";
import "../../constants.dart";
import "../theme/colors.dart";
import "../theme/material.dart";

Future<T?> showCustomDialog<T>({
  required String title,
  String? subtitle,
  void Function()? onConfirm,
  bool closeOnConfirm = true,
  Widget? child,
  bool easyClose = true,
}) async {
  final Completer<T?> completer = Completer<T?>();

  Future<void> buildAndComplete(BuildContext ctx) async {
    final result = await showGeneralDialog<T?>(
      context: ctx,
      barrierDismissible: easyClose,
      barrierLabel: title,
      transitionDuration: kAnimationFasterDuration,
      pageBuilder: (context, animation, secondaryAnimation) => CustomDialog(
        title: title,
        subtitle: subtitle,
        onConfirm: onConfirm,
        closeOnConfirm: closeOnConfirm,
        child: child,
      ),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(
            begin: 0.8,
            end: 1.0,
          ).animate(CurvedAnimation(parent: animation, curve: kCurveEaseInOut)),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
    completer.complete(result);
  }

  final context = navigatorKey.currentContext;
  if (context != null && context.mounted) {
    buildAndComplete(context);
  } else {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final postFrameContext = navigatorKey.currentContext;
      if (postFrameContext != null) {
        buildAndComplete(postFrameContext);
      } else {
        completer.complete(null);
      }
    });
  }

  return completer.future;
}

class CustomDialog extends StatelessWidget {
  const CustomDialog({
    super.key,
    required this.title,
    this.subtitle,
    this.onConfirm,
    required this.closeOnConfirm,
    this.child,
  });

  final String title;
  final String? subtitle;
  final void Function()? onConfirm;
  final bool closeOnConfirm;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final withConfirm = onConfirm != null;
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: kDefaultPadding * 1.5,
      ),
      child: MyMaterial(
        theme: MyMaterialTheme.glass,
        borderRadius: BorderRadius.circular(kLargeBorderRadius),
        padding: const EdgeInsets.all(kLargeBorderRadius * 0.5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: kLargeFont,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: kSmallPadding),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: kSmallFont,
                  color: context.secondary,
                ),
              ),
            ],
            if (child != null) ...[
              const SizedBox(height: kMediumPadding),
              child!,
            ],
            const SizedBox(height: kMediumPadding),
            Row(
              spacing: kMediumPadding,
              children: [
                Expanded(
                  child: DialogButton(
                    title: withConfirm ? l10n.cancel : l10n.close,
                    color: withConfirm ? context.error : context.primary,
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                if (withConfirm) ...[
                  Expanded(
                    child: DialogButton(
                      title: "تاكيد",
                      color: context.primary,
                      onTap: () {
                        onConfirm?.call();
                        if (closeOnConfirm) Navigator.pop(context, true);
                      },
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DialogButton extends StatelessWidget {
  const DialogButton({
    super.key,
    required this.title,
    this.icon,
    required this.onTap,
    required this.color,
  });

  final String title;
  final IconData? icon;
  final Color color;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.foreground.withOpacity(0.1),
        foregroundColor: color,
        // شيلنا الـ infinity وخليناها 0 عشان ميزقش الـ Row
        minimumSize: const Size(0, 50),
        padding: const EdgeInsets.symmetric(vertical: kMediumPadding),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kCircleBorderRadius),
        ),
      ),
      onPressed: onTap,
      child: Row(
        spacing: kSmallPadding,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) Icon(icon, size: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: kSmallFont,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
