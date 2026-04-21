import "package:flutter/material.dart";
import "../../../../constants.dart";
import "../../../../core/services/files/open_file.dart";
import "../../../../core/theme/colors.dart";

class CustomTap extends StatelessWidget {
  const CustomTap({
    super.key,
    required this.id,
    required this.name,
    required this.sel,
    required this.isNotSaved,
    required this.onLongPress,
  });

  final int id;
  final String name;
  final bool sel;
  final bool isNotSaved;
  final Function onLongPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => openFile(id, context),
      onLongPress: () => onLongPress(context, id),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: kSmallPadding),
        padding: const EdgeInsets.symmetric(
          horizontal: kLargePadding,
          vertical: kSmallPadding,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          boxShadow: sel
              ? [BoxShadow(color: context.primary, blurRadius: 5)]
              : [],
        ),
        child: Row(
          children: [
            if (isNotSaved)
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: context.foreground,
                ),
              ),
            if (isNotSaved) const SizedBox(width: 5),
            Text(name),
          ],
        ),
      ),
    );
  }
}
