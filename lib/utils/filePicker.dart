import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';


Future<void> showFileManagerModal(
  BuildContext context,
  void Function(String) onFileSelected, {
  String? startPath,
}) async {
  final rootPath = startPath ?? "/storage/emulated/0";

  final directory = Directory(rootPath);

  if (!await directory.exists()) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("المجلد غير موجود: $rootPath")));
    return;
  }

  List<FileSystemEntity> items = directory.listSync().where((entity) {
    // لو فولدر سيبه زي ما هو
    if (FileSystemEntity.isDirectorySync(entity.path)) return true;

    // لو ملف، خليه يظهر لو بينتهي بالامتدادات اللي عايزها
    final name = entity.path.toLowerCase();
    return name.endsWith('.alif') ||
        name.endsWith('.الف') ||
        name.endsWith('.aliflib');
  }).toList();

  String formatFileSize(int bytes) {
    if (bytes < 1024) return "$bytes بايت";
    if (bytes < 1024 * 1024)
      return "${(bytes / 1024).toStringAsFixed(2)} كيلو بايت";
    if (bytes < 1024 * 1024 * 1024) {
      return "${(bytes / (1024 * 1024)).toStringAsFixed(2)} ميجا بايت";
    }
    return "${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} جيجا بايت";
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            color: const Color(0xFF0A0830),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0830),
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
                      rootPath.replaceAll("/storage/emulated/0", "~"),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        final parentPath = Directory(rootPath).parent.path;

                        // لو احنا في الجذر /storage/emulated/0 منرجعش
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
              Directionality(
                textDirection: TextDirection.rtl,
                child: Expanded(
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
                                isDir
                                    ? LucideIcons.folder
                                    : LucideIcons.fileCode,
                                color: isDir ? Color(0xFFDAB744) : Colors.white,
                              ),
                              title: Text(
                                name,
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                isDir
                                    ? "عدد الملفات ${Directory(entity.path).listSync().length}"
                                    : "الحجم ${formatFileSize(File(entity.path).statSync().size)}",
                                style: const TextStyle(color: Colors.grey),
                              ),
                              onTap: () {
                                if (isDir) {
                                  // فتح نفس الدالة لكن بالمسار الجديد
                                  Navigator.pop(context);
                                  showFileManagerModal(
                                    context,
                                    onFileSelected,
                                    startPath: entity.path,
                                  );
                                } else {
                                  // لو ملف رجّع المسار
                                  Navigator.pop(context);
                                  onFileSelected(entity.path);
                                }
                              },
                            );
                          },
                        )
                      : Text(
                          "لا يوجد ملفات للغة ألف في هذا المجلد",
                          style: TextStyle(color: Colors.grey),
                        ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
