import 'dart:convert';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:taif/core/data/ideData.dart';
import 'package:taif/core/theme/Colors.dart';
import 'package:taif/generated/l10n.dart';
import 'package:taif/pages/About.dart';
import 'package:taif/pages/Terminal.dart';
import 'package:taif/utils/filePicker.dart';
import 'package:taif/utils/files/createFile.dart';
import 'package:taif/utils/files/openFile.dart';
import 'package:taif/utils/runAlif.dart';
import 'package:taif/widgets/OpenedFiles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_saver/file_saver.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AlifAppBar extends StatelessWidget {
  AlifAppBar({super.key});

  Future<void> saveFileToStorage(BuildContext context) async {
    final data = Provider.of<IdeData>(context, listen: false);
    final code = data.code.text;
    final filesList = data.files;

    if (data.selectedFile.path == "") {
      try {
        final bytes = Uint8List.fromList(utf8.encode(code));
        final path = await FileSaver.instance.saveAs(
          name:
              (data.selectedFile.name == null || data.selectedFile.name.isEmpty)
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
  }

  Future<void> openFileFromStorage(BuildContext context) async {
    final data = Provider.of<IdeData>(context, listen: false);
    try {
      showFileManagerModal(context, (selectedPath) async {
        final file = File(selectedPath);
        final code = await file.readAsString();
        final fileName = selectedPath.split(Platform.pathSeparator).last;

        final existingIndex = data.files.indexWhere(
          (f) => f["Path"] == selectedPath,
        );

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
      });
    } catch (e) {
      data.addOutput("خطأ أثناء الفتح: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<IdeData>(context, listen: false);
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 10, right: 10, left: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => About(),
                    );
                  },
                  child: Text(
                    S.of(context).title,
                    style: TextStyle(
                      color: ThemeColors.foreground,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        LucideIcons.terminal,
                        color: ThemeColors.foreground,
                        size: 20,
                      ),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => Terminal(),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        LucideIcons.play,
                        color: ThemeColors.foreground,
                        size: 20,
                      ),
                      onPressed: () => {
                        data.clearOutput(),
                        runAlifCode(context),
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => Terminal(),
                        ),
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        LucideIcons.save,
                        color: ThemeColors.foreground,
                        size: 20,
                      ),
                      onPressed: () => saveFileToStorage(context),
                    ),
                    IconButton(
                      icon: Icon(
                        LucideIcons.folderOpen,
                        color: ThemeColors.foreground,
                        size: 20,
                      ),
                      onPressed: () => openFileFromStorage(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
          OpenedFiles(),
        ],
      ),
    );
  }
}
