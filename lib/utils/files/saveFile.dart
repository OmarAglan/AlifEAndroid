import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taif/core/data/ideData.dart';

Future<void> saveFileToStorage(
  BuildContext context, {
  bool asNew = false,
}) async {
  final data = Provider.of<IdeData>(context, listen: false);
  final code = data.code.text;
  final filesList = data.files;

  if (data.selectedFile.path == "" || asNew) {
    try {
      final bytes = Uint8List.fromList(utf8.encode(code));
      final path = await FileSaver.instance.saveAs(
        name: (data.selectedFile.name == null || data.selectedFile.name.isEmpty)
            ? 'شفرة'
            : data.selectedFile.name.toString().replaceAll(
                RegExp(r'\.(الف|alif|aliflib)$'),
                "",
              ),
        bytes: bytes,
        fileExtension: "الف",
        mimeType: MimeType.other,
      );
      if (path == null || path.isEmpty) {
        data.addOutput("تم إلغاء الحفظ.");
        return;
      }

      final fileData = {
        "Name": data.selectedFile.name,
        "Path": path,
        "Code": code,
      };
      filesList[filesList.indexWhere(
            (p) => p["Name"] == data.selectedFile.name,
          )] =
          fileData;

      data.addOutput("تم الحفظ في: $path");
    } catch (e) {
      data.addOutput("خطأ أثناء الحفظ: $e");
    }
  } else {
    File(data.selectedFile.path).writeAsString(data.selectedFile.code);
  }
  saveFilesLocal(context);
}

void saveFilesLocal(BuildContext context) {
  final data = Provider.of<IdeData>(context, listen: false);

  final updatedFiles = data.files.map((file) {
    return {...file, "Saved": true};
  }).toList();

  SharedPreferences.getInstance().then((prefs) {
    prefs.setString("opened_files", jsonEncode(updatedFiles));
  });

  data.setFiles(updatedFiles);
}
