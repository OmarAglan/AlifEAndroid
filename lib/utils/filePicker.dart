import 'dart:io';
import 'package:taif/core/theme/Colors.dart';
import 'package:taif/core/theme/Text.dart';
import 'package:taif/widgets/BottomSheet.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

Future<void> showFileManagerModal(
  BuildContext context,
  void Function(String) onFileSelected, {
  String? startPath,
}) async {
  final rootPath =
      startPath ??
      (Platform.isAndroid
          ? "/storage/emulated/0"
          : Platform.isLinux
          ? "${Platform.environment['HOME']}"
          : "");

  final directory = Directory(rootPath);

  if (!await directory.exists()) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("المجلد غير موجود: $rootPath")));
    return;
  }

  List<FileSystemEntity> items = directory.listSync().where((entity) {
    if (FileSystemEntity.isDirectorySync(entity.path)) return true;

    final name = entity.path.toLowerCase();
    return name.endsWith('.alif') ||
        name.endsWith('.الف') ||
        name.endsWith('.aliflib');
  }).toList();

  String formatFileSize(int bytes) {
    if (bytes < 1024) return "$bytes بايت";
    if (bytes < 1024 * 1024) {
      return "${(bytes / 1024).toStringAsFixed(2)} كيلو بايت";
    }
    if (bytes < 1024 * 1024 * 1024) {
      return "${(bytes / (1024 * 1024)).toStringAsFixed(2)} ميجا بايت";
    }
    return "${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} جيجا بايت";
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return MyBottomsheet(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ThemeColors.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    rootPath.replaceAll(
                      RegExp(r"^(/storage/emulated/0|/home)"),
                      "~",
                    ),
                    style: ThemeText.mid,
                    overflow: TextOverflow.ellipsis,
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: ThemeColors.foreground),
                    onPressed: () {
                      final parentPath = Directory(rootPath).parent.path;

                      if (parentPath == rootPath || parentPath == "/") return;

                      Navigator.pop(context);
                      showFileManagerModal(
                        context,
                        onFileSelected,
                        startPath: parentPath,
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: items.isNotEmpty
                  ? ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final entity = items[index];
                        final isDir = FileSystemEntity.isDirectorySync(
                          entity.path,
                        );
                        final name = entity.path.split("/").last;
                        return ListTile(
                          leading: Icon(
                            isDir ? LucideIcons.folder : LucideIcons.fileCode,
                            color: isDir
                                ? Color(0xFFDAB744)
                                : ThemeColors.foreground,
                          ),
                          title: Text(
                            name,
                            style: TextStyle(color: ThemeColors.foreground),
                          ),
                          subtitle: Text(
                            isDir
                                ? "عدد الملفات ${Directory(entity.path).listSync().length}"
                                : "الحجم ${formatFileSize(File(entity.path).statSync().size)}",
                            style: TextStyle(color: ThemeColors.secondary),
                          ),
                          onTap: () {
                            if (isDir) {
                              Navigator.pop(context);
                              showFileManagerModal(
                                context,
                                onFileSelected,
                                startPath: entity.path,
                              );
                            } else {
                              Navigator.pop(context);
                              onFileSelected(entity.path);
                            }
                          },
                        );
                      },
                    )
                  : Text(
                      "لا يوجد ملفات للغة ألف في هذا المجلد",
                      style: TextStyle(color: ThemeColors.secondary),
                    ),
            ),
          ],
        ),
      );
    },
  );
}
