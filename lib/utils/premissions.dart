import 'package:alifeditor/core/theme/Colors.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> requestStoragePermission(BuildContext context) async {
  var status = await Permission.manageExternalStorage.status;
  if (status.isGranted) return true;
  final result = await showModalBottomSheet<bool>(
    context: context,
    builder: (context) {
      return SafeArea(
        child: Container(
          padding: EdgeInsets.all(20),
          height: 300,
          decoration: BoxDecoration(
            color: ThemeColors.background,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      LucideIcons.folderCog,
                      size: 40,
                      color: ThemeColors.foreground,
                    ),
                  ),
                  Text(
                    "الوصول للتخزين",
                    style: TextStyle(
                      color: ThemeColors.foreground,
                      fontSize: 22,
                    ),
                  ),
                  Text(
                    "يحتاج التطبيق الإذن للوصول للملفات لتعديل ملفات شفرة ألف",
                    style: TextStyle(
                      color: ThemeColors.foreground,
                      fontSize: 20,
                    ),
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
                    child: IntrinsicWidth(
                      stepWidth: double.infinity,
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
                      child: Center(
                        child: Text(
                          "رفض",
                          style: TextStyle(
                            color: ThemeColors.foreground,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
