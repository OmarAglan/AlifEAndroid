import "dart:io";

import "package:taif/core/theme/Colors.dart";
import "package:taif/core/theme/Text.dart";
import "package:taif/core/widgets/custom_bottom_sheet.dart";
import "package:flutter/material.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:permission_handler/permission_handler.dart";

Future<bool> requestStoragePermission(BuildContext context) async {
  if (Platform.isLinux) return true;

  var status = await Permission.manageExternalStorage.status;
  if (status.isGranted) return true;
  final result = await showModalBottomSheet<bool>(
    context: context,
    builder: (context) {
      return CustomBottomSheet(
        padding: EdgeInsets.all(10),
        height: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              spacing: 10,
              children: [
                Icon(
                  LucideIcons.folderCog,
                  size: 40,
                  color: ThemeColors.foreground,
                ),
                Text(
                  "الوصول للتخزين",
                  style: TextStyle(
                    color: ThemeColors.foreground,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
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
                    backgroundColor: WidgetStateProperty.all(
                      ThemeColors.foreground,
                    ),
                  ),
                  onPressed: () => Navigator.pop(context, true),
                  child: SizedBox(
                    width: double.infinity,
                    child: Center(
                      child: Text(
                        "منح الإذن",
                        style: TextStyle(
                          color: ThemeColors.background,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: IntrinsicWidth(
                    stepWidth: double.infinity,
                    child: Center(child: Text("رفض", style: ThemeText.title)),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
  if (result != true) return false;
  status = await Permission.manageExternalStorage.request();
  if (!status.isGranted) {
    final opened = await openAppSettings();
    if (!opened) print("فشل فتح الاعدادات");
  }

  return status.isDenied ? false : true;
}
