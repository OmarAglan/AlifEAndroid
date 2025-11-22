import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taif/core/data/ideData.dart';
import 'package:taif/utils/files/openFile.dart';

void createFile({
  String name = "",
  String path = "",
  String code = "",
  required BuildContext context,
}) {
  final data = Provider.of<IdeData>(context, listen: false);

  final Map<String, dynamic> newFile = {
    "id": data.files.length - 1,
    "Name": name.isEmpty ? "ملف_جديد_${data.files.length + 1}.الف" : name,
    "Path": path,
    "Code": code,
    "Saved": false,
  };
  data.addFile(newFile);
  openFile(data.files.length - 1, context);
}
