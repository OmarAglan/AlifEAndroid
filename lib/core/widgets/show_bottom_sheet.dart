import "package:flutter/material.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "../../constants.dart";
import "../theme/colors.dart";
import "../theme/material.dart";

class MyBottomSheet extends StatefulWidget {
  const MyBottomSheet({
    super.key,
    required this.child,
    this.bg = true,
    this.reverse = false,
    this.closeButton = false,
    this.actionButtons = const [],
    this.header,
    this.height,
  });

  final Widget child;
  final bool bg;
  final bool reverse;
  final bool closeButton;
  final List<Widget> actionButtons;
  final Widget? header;
  final double? height;

  @override
  State<MyBottomSheet> createState() => _MyBottomSheetState();
}

class _MyBottomSheetState extends State<MyBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (_, controller) => MyMaterial(
        width: double.infinity,
        theme: MyMaterialTheme.glass,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(kMediumBorderRadius),
          topRight: Radius.circular(kMediumBorderRadius),
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: kMediumPadding,
                vertical: kSmallPadding,
              ),
              child: widget.header ?? _buildDefaultHeader(context),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: kMediumPadding),
                child: widget.child,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultHeader(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: const EdgeInsets.only(top: kMediumPadding),
          decoration: BoxDecoration(
            color: context.secondary,
            borderRadius: BorderRadius.circular(kMediumBorderRadius),
          ),
          height: 5,
          width: 40,
        ),
        Row(
          children: [
            Expanded(
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: (widget.closeButton || widget.actionButtons.isNotEmpty)
                    ? IconButton(
                        icon: const Icon(LucideIcons.x),
                        onPressed: () => Navigator.pop(context),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
            Expanded(
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: widget.actionButtons.isNotEmpty
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: widget.actionButtons,
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

Future<T?> showMyBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  bool reverse = false,
  bool easyClose = true,
  bool? closeButton,
  List<Widget>? actionButtons,
  Widget? header,
  double? height,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isDismissible: easyClose,
    enableDrag: easyClose,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    useSafeArea: true,
    sheetAnimationStyle: const AnimationStyle(
      curve: kCurveEaseOutBack,
      reverseCurve: kCurveEaseOutBack,
      duration: kAnimationDuration,
      reverseDuration: kAnimationDuration,
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          left: kSmallPadding,
          right: kSmallPadding,
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: MyBottomSheet(
          reverse: reverse,
          closeButton: closeButton ?? false,
          actionButtons: actionButtons ?? [],
          header: header,
          height: height,
          child: child,
        ),
      );
    },
  );
}
