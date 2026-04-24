import "dart:io";

import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../../../data/ide_data.dart";
import "../../utils/file_picker.dart";
import "create_file.dart";
import "open_file.dart";

Future<void> openFileFromStorage(
  BuildContext context, {
  String rootPath = "/",
  String? startPath,
}) async {
  final data = Provider.of<IdeData>(context, listen: false);
  try {
    showFileManagerModal(
      context,
      (selectedPath) async {
        final file = File(selectedPath);
        final code = await file.readAsString();
        final fileName = selectedPath.split(Platform.pathSeparator).last;

        final existingIndex = data.files.indexWhere(
          (f) => f.path == selectedPath,
        );

        if (!context.mounted) return;
        if (existingIndex >= 0) {
          openFile(existingIndex, context);
        } else {
          createFile(
            name: fileName,
            path: selectedPath,
            code: code,
            context: context,
          );
        }
      },
      rootPath: rootPath,
      startPath: startPath,
      onFolderSelected: (folderPath) {
        data.setWorkspacePath(folderPath);
      },
    );
  } catch (e) {
    data.addOutput("خطأ أثناء الفتح: $e");
  }
}
