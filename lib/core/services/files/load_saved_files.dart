import "dart:convert";

import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

import "../../../data/data_types.dart";
import "create_file.dart";
import "open_file.dart";

Future<void> loadFilesFromStorage(BuildContext context, data) async {
  final prefs = await SharedPreferences.getInstance();
  final savedFiles = prefs.getString("opened_files");
  final lastFile = prefs.getInt("lastFile") ?? 0;

  if (savedFiles != null) {
    try {
      final decoded = jsonDecode(savedFiles);
      if (decoded is List) {
        data.files = decoded.map((file) => FileEntity.fromJson(file)).toList();
      }
    } catch (e) {
      debugPrint("خطأ في قراءة الملفات المخزنة: $e");
    }
  }
  if (!context.mounted) return;
  if (data.files.isNotEmpty) {
    final selectedIndex = lastFile >= 0 && lastFile < data.files.length
        ? lastFile
        : 0;
    await openFile(selectedIndex, context);
  } else {
    createFile(name: defultFile.name, code: defultFile.code, context: context);
  }
}

FileEntity defultFile = const FileEntity(
  id: 0,
  name: "الأعداد_الاولية.الف",
  code: """
# هذا البرنامج يقوم بطباعة الاعداد الاولية ضمن المدى المعطى له
دالة هل_اولي(عدد):
	اذا عدد < 2:
		ارجع
	اذا عدد == 2:
		اطبع(عدد)
		ارجع
	اذا ليس عدد \\\\ 2:
		ارجع
	لكل مقسوم في مدى(3, صحيح(\\^عدد) + 1, 2):
		اذا ليس عدد \\\\ مقسوم:
			ارجع
	اطبع(عدد)

اطبع("*- هذا البرنامج يقوم بإيجاد الأعداد الأولية ضمن المدى المدخل له -*")
ن = صحيح(ادخل("ادخل عدد: "))
لكل ب في مدى(ن):
	هل_اولي(ب)
اطبع(م"تم إيجاد الاعداد الاولية ضمن العدد { ن }")
""",
);
