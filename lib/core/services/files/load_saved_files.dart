import "dart:convert";

import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:taif/core/services/files/create_file.dart";
import "package:taif/core/services/files/open_file.dart";
import "package:taif/data/data_types.dart";

Future<void> loadFilesFromStorage(BuildContext context, data) async {
  final prefs = await SharedPreferences.getInstance();
  final savedFiles = prefs.getString("opened_files");
  final lastFile = prefs.getInt("lastFile");

  if (savedFiles != null) {
    try {
      final decoded = jsonDecode(savedFiles);
      if (decoded is List) {
        data.files = decoded.map((file) => FileEntity.fromJson(file)).toList();
      }
      if (lastFile != null && lastFile >= 0 && lastFile < data.files.length) {
        openFile(lastFile, context);
      }
    } catch (e) {
      print("خطأ في قراءة الملفات المخزنة: $e");
    }
  } else {
    createFile(name: defultFile.name, code: defultFile.code, context: context);
  }
}

FileEntity defultFile = FileEntity(
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
