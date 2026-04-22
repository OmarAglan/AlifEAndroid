import "dart:io";

import "package:flutter/material.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "../theme/colors.dart";
import "../theme/text.dart";
import "../widgets/show_bottom_sheet.dart";

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
          ? "${Platform.environment["HOME"]}"
          : "");

  final directory = Directory(rootPath);

  if (!await directory.exists()) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("المجلد غير موجود: $rootPath")));
    return;
  }

  final List<FileSystemEntity> items = directory.listSync().where((entity) {
    if (FileSystemEntity.isDirectorySync(entity.path)) return true;

    final name = entity.path.toLowerCase();
    return name.endsWith(".alif") ||
        name.endsWith(".الف") ||
        name.endsWith(".aliflib");
  }).toList();

  items.sort((a, b) {
    final bool isDirA = FileSystemEntity.isDirectorySync(a.path);
    final bool isDirB = FileSystemEntity.isDirectorySync(b.path);

    if (!isDirA && isDirB) return -1;
    if (isDirA && !isDirB) return 1;

    return a.path.toLowerCase().compareTo(b.path.toLowerCase());
  });

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

  if (!context.mounted) return;
  showMyBottomSheet(
    context: context,
    header: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          rootPath.replaceAll(RegExp(r"^(/storage/emulated/0|/home)"), "~"),
          style: ThemeText.mid,
          overflow: TextOverflow.ellipsis,
        ),
        IconButton(
          icon: Icon(Icons.arrow_back, color: context.foreground),
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
    child: Column(
      children: [
        Expanded(
          child: items.isNotEmpty
              ? ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final entity = items[index];
                    final isDir = FileSystemEntity.isDirectorySync(entity.path);
                    final name = entity.path.split("/").last;
                    return ListTile(
                      leading: Icon(
                        isDir ? LucideIcons.folder : LucideIcons.fileCode,
                        color: isDir
                            ? const Color(0xFFDAB744)
                            : context.foreground,
                      ),
                      title: Text(
                        name,
                        style: TextStyle(color: context.foreground),
                      ),
                      subtitle: Text(
                        isDir
                            ? "عدد الملفات ${Directory(entity.path).listSync().length}"
                            : "الحجم ${formatFileSize(File(entity.path).statSync().size)}",
                        style: TextStyle(color: context.secondary),
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
                  style: TextStyle(color: context.secondary),
                ),
        ),
      ],
    ),
  );
}
