import "dart:io";

import "package:flutter/material.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:permission_handler/permission_handler.dart";
import "../../constants.dart";
import "../theme/colors.dart";
import "../theme/text.dart";
import "../widgets/show_bottom_sheet.dart";

Future<bool> requestStoragePermission(BuildContext context) async {
  if (Platform.isLinux) return true;

  var status = await Permission.manageExternalStorage.status;
  if (status.isGranted) return true;
  if (!context.mounted) return false;
  final result = await showMyBottomSheet<bool>(
    context: context,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          spacing: kMediumPadding,
          children: [
            Icon(
              LucideIcons.folderCog,
              size: kLargeFont * 2,
              color: context.foreground,
            ),
            Text(
              "الوصول للتخزين",
              style: TextStyle(
                color: context.foreground,
                fontSize: kSoLargeFont,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              "يحتاج التطبيق الإذن للوصول للملفات لتعديل ملفات شفرة ألف",
              textAlign: TextAlign.center,
              style: ThemeText.title,
            ),
          ],
        ),
        Column(
          children: [
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(context.foreground),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: SizedBox(
                width: double.infinity,
                child: Center(
                  child: Text(
                    "منح الإذن",
                    style: TextStyle(
                      color: context.background,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const IntrinsicWidth(
                stepWidth: double.infinity,
                child: Center(child: Text("رفض", style: ThemeText.title)),
              ),
            ),
          ],
        ),
      ],
    ),
  );
  if (result != true) return false;
  status = await Permission.manageExternalStorage.request();
  if (!status.isGranted) {
    final opened = await openAppSettings();
    if (!opened) debugPrint("فشل فتح الاعدادات");
  }

  return status.isDenied ? false : true;
}
