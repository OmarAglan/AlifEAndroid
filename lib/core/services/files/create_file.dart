import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:taif/data/data_types.dart";
import "package:taif/data/ide_data.dart";
import "package:taif/core/services/files/open_file.dart";

void createFile({
  String name = "",
  String path = "",
  String code = "",
  required BuildContext context,
}) {
  final data = Provider.of<IdeData>(context, listen: false);

  final FileEntity newFile = FileEntity(
    id: data.files.length - 1,
    name: name.isEmpty ? "ملف_جديد_${data.files.length + 1}.الف" : name,
    path: path,
    code: code,
    saved: false,
  );
  data.addFile(newFile);
  openFile(data.files.length - 1, context);
}
