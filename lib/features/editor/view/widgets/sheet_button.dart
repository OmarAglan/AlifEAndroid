import "package:flutter/material.dart";
import "../../../../constants.dart";

class SheetButton extends StatelessWidget {
  const SheetButton({
    super.key,
    required this.title,
    required this.color,
    this.bg = Colors.transparent,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final Color color;
  final Color bg;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: kLargePadding,
          vertical: kMediumPadding,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: kSmallPadding,
          children: [
            Icon(icon, color: color),
            Text(
              title,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
