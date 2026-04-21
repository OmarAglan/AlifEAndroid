import "dart:convert";
import "dart:io";
import "dart:typed_data";

import "package:file_saver/file_saver.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:shared_preferences/shared_preferences.dart";
import "../../../data/data_types.dart";
import "../../../data/ide_data.dart";

Future<bool> saveFileToStorage(
  BuildContext context, {
  bool asNew = false,
}) async {
  final data = Provider.of<IdeData>(context, listen: false);

  if (data.files.isEmpty) {
    data.addOutput("لا يوجد ملف مفتوح للحفظ.");
    return false;
  }

  final code = data.code.text;
  final selectedId = data.selectedFile.id;
  final filesList = List<FileEntity>.from(data.files);
  final currentIndex = filesList.indexWhere((file) => file.id == selectedId);

  if (data.selectedFile.path == null ||
      data.selectedFile.path!.isEmpty ||
      asNew) {
    try {
      final bytes = Uint8List.fromList(utf8.encode(code));
      final path = await FileSaver.instance.saveAs(
        name: (data.selectedFile.name.isEmpty)
            ? "شفرة"
            : data.selectedFile.name.replaceAll(
                RegExp(r"\.(الف|alif|aliflib)$"),
                "",
              ),
        bytes: bytes,
        fileExtension: "الف",
        mimeType: MimeType.other,
      );

      if (path == null || path.isEmpty) {
        data.addOutput("تم إلغاء الحفظ.");
        return false;
      }

      final FileEntity fileData = data.selectedFile.copyWith(
        name: path.split(Platform.pathSeparator).last,
        path: path,
        code: code,
        saved: true,
      );

      if (currentIndex >= 0) {
        filesList[currentIndex] = fileData;
      } else {
        filesList.add(fileData);
      }

      data.setSelectedFile(fileData);
      data.setFiles(filesList);
      data.addOutput("تم الحفظ في: $path");
    } catch (e) {
      data.addOutput("خطأ أثناء الحفظ: $e");
      return false;
    }
  } else {
    try {
      await File(data.selectedFile.path!).writeAsString(code);
      final FileEntity fileData = data.selectedFile.copyWith(
        code: code,
        saved: true,
      );
      if (currentIndex >= 0) {
        filesList[currentIndex] = fileData;
      }
      data.setSelectedFile(fileData);
      data.setFiles(filesList);
    } catch (e) {
      data.addOutput("خطأ أثناء الحفظ: $e");
      return false;
    }
  }
  if (!context.mounted) return false;
  await saveFilesLocal(context);
  return true;
}

Future<void> saveFilesLocal(BuildContext context) async {
  final data = Provider.of<IdeData>(context, listen: false);
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString("opened_files", jsonEncode(data.files));
  data.setFiles(data.files);
}
