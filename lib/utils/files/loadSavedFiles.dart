import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taif/core/data/ideData.dart';
import 'package:taif/utils/files/createFile.dart';
import 'package:taif/utils/files/openFile.dart';

Future<void> loadFilesFromStorage(BuildContext context) async {
  final data = Provider.of<IdeData>(context, listen: false);

  final prefs = await SharedPreferences.getInstance();
  final savedFiles = prefs.getString('opened_files');
  final lastFile = prefs.getInt("lastFile");

  if (savedFiles != null) {
    try {
      final decoded = jsonDecode(savedFiles);
      if (decoded is List) {
        data.files = decoded
            .map<Map<String, dynamic>>(
              (item) => {
                "Name": item["Name"].toString(),
                "Path": item["Path"].toString(),
                "Code": item["Code"].toString(),
              },
            )
            .toList();
      }
      if (lastFile != null && lastFile >= 0 && lastFile < data.files.length) {
        openFile(lastFile, context);
      }
    } catch (e) {
      debugPrint("خطأ في قراءة الملفات المخزنة: $e");
    }
  } else {
    createFile(
      name: defFile["Name"]!,
      code: defFile["Code"]!,
      context: context,
    );
  }
}

Map<String, dynamic> defFile = {
  "Name": "الأعداد_الاولية.الف",
  "Code": """
# برنامج لإيجاد الأعداد الأولية
دالة هل_اولي(عدد):
    اذا عدد < 2: ارجع
    اذا عدد == 2: اطبع(عدد); ارجع
    اذا ليس عدد \\\\ 2: ارجع
    لاجل مقسوم في مدى(3, صحيح(\\^عدد) + 1, 2):
        اذا ليس عدد \\\\ مقسوم: ارجع
    اطبع(عدد)

اطبع("*- هذا البرنامج يقوم بإيجاد الأعداد الأولية ضمن المدى المدخل له -*")
ن = صحيح(ادخل("ادخل عدد: "))
لاجل ب في مدى(ن): هل_اولي(ب)
""",
};
