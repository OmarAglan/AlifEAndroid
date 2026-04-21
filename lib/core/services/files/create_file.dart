import "dart:math";

import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../../../data/data_types.dart";
import "../../../data/ide_data.dart";
import "open_file.dart";

void createFile({
  String name = "",
  String path = "",
  String code = "",
  required BuildContext context,
}) {
  final data = Provider.of<IdeData>(context, listen: false);
  final newId = data.files.isEmpty
      ? 0
      : data.files.map((file) => file.id).reduce(max) + 1;

  final FileEntity newFile = FileEntity(
    id: newId,
    name: name.isEmpty ? "ملف_جديد_${data.files.length + 1}.الف" : name,
    path: path.isEmpty ? null : path,
    code: code,
    saved: false,
  );
  data.addFile(newFile);
  openFile(newId, context);
}
