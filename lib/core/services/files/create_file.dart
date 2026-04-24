import "dart:math";

import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../../models/data_typs.dart";
import "../../providers/workspace_provider.dart";
import "open_file.dart";

void createFile({
  String name = "",
  String path = "",
  String code = "",
  required BuildContext context,
}) {
  final workspace = context.read<WorkspaceProvider>();
  final newId = workspace.files.isEmpty
      ? 0
      : workspace.files.map((file) => file.id).reduce(max) + 1;

  final FileEntity newFile = FileEntity(
    id: newId,
    name: name.isEmpty ? "ملف_جديد_${workspace.files.length + 1}.الف" : name,
    path: path.isEmpty ? null : path,
    code: code,
    saved: false,
  );
  workspace.addFile(newFile);
  openFile(newId, context);
}
