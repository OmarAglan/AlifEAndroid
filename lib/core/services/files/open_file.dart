import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../../../data/ide_data.dart";
import "save_file.dart";

Future<void> openFile(int fileID, BuildContext context) async {
  final data = Provider.of<IdeData>(context, listen: false);
  final files = data.files;
  if (fileID < 0 || fileID >= files.length) return;

  if (data.selectedFile.id != -1 && !data.selectedFile.saved) {
    await saveFilesLocal(context);
    if (data.selectedFile.path != null && data.selectedFile.path!.isNotEmpty) {
      if (!context.mounted) return;
      await saveFileToStorage(context);
    }
  }

  data.setLastFile(fileID);

  final openedFile = files[fileID];
  data.setSelectedFile(openedFile.copyWith(id: fileID));
  data.editCode(openedFile.code, markDirty: false);
  data.focusNode.requestFocus();
}
