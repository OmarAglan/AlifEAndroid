import "dart:io";

import "package:flutter/material.dart";
import "package:permission_handler/permission_handler.dart";
import "../utils/show_dialog.dart";

Future<bool> requestStoragePermission(BuildContext context) async {
  if (Platform.isLinux) return true;

  var status = await Permission.manageExternalStorage.status;
  if (status.isGranted) return true;
  if (!context.mounted) return false;
  final result = await showCustomDialog<bool>(
    title: "الوصول للتخزين",
    subtitle: "يحتاج التطبيق الإذن للوصول للملفات لتعديل ملفات شفرة ألف",
    onConfirm: () => true,
  );
  if (result != true) return false;
  status = await Permission.manageExternalStorage.request();
  if (!status.isGranted) {
    final opened = await openAppSettings();
    if (!opened) debugPrint("فشل فتح الاعدادات");
  }

  return status.isDenied ? false : true;
}
