import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> requestStoragePermission(BuildContext context) async {
  var status = await Permission.manageExternalStorage.status;
  if (status.isGranted) return true;
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text("الوصول للتخزين", style: TextStyle(color: Colors.white)),
          content: Text(
            "يحتاج التطبيق الإذن للوصول للملفات لتعديل ملفات شفرة ألف",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xFF081433),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text("رفض", style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text("منح الإذن", style: TextStyle(color: Colors.white)),
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
