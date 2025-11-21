import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taif/core/data/dataTypes.dart';
import 'package:taif/core/data/ideData.dart';

Future<void> openFile(int fileID, BuildContext context) async {
  final data = Provider.of<IdeData>(context, listen: false);
  final files = data.files;
  if (fileID < 0 || fileID >= files.length) return;

  data.setLastFile(fileID);

  final openedFile = files[fileID];
  data.setSelectedFile(
    SelectedFile(
      id: fileID,
      name: openedFile["Name"],
      code: openedFile["Code"],
      path: openedFile["Path"],
    ),
  );
  data.editCode(openedFile["Code"]);
  data.focusNode.requestFocus();
}
