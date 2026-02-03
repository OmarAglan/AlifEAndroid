import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:taif/data/data_types.dart";
import "package:taif/data/ide_data.dart";

Future<void> openFile(int fileID, BuildContext context) async {
  final data = Provider.of<IdeData>(context, listen: false);
  final files = data.files;
  if (fileID < 0 || fileID >= files.length) return;

  data.setLastFile(fileID);

  final openedFile = files[fileID];
  data.setSelectedFile(
    FileEntity(
      id: fileID,
      name: openedFile.name,
      code: openedFile.code,
      path: openedFile.path,
    ),
  );
  data.editCode(openedFile.code);
  data.focusNode.requestFocus();
}
