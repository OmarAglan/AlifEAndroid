import "package:flutter/material.dart";
import "package:taif/core/theme/Colors.dart";
import "package:taif/core/services/files/open_file.dart";

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
        margin: EdgeInsets.all(5),
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          boxShadow: sel
              ? [BoxShadow(color: ThemeColors.primary, blurRadius: 5)]
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
                  color: ThemeColors.foreground,
                ),
              ),
            if (isNotSaved) SizedBox(width: 5),
            Text(name),
          ],
        ),
      ),
    );
  }
}
