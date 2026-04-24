import "dart:io";

import "package:flutter/material.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "../../constants.dart";
import "../extensions/strings.dart";
import "../theme/colors.dart";
import "../theme/material.dart";
import "../theme/text.dart";
import "../widgets/show_bottom_sheet.dart";
import "show_message.dart";

Future<void> showFileManagerModal(
  BuildContext context,
  void Function(String) onFileSelected, {
  String rootPath = "/",
  String? startPath,
  void Function(String)? onFolderSelected,
}) async {
  final currentPath = startPath ?? rootPath;
  final directory = Directory(currentPath);

  if (!await directory.exists()) {
    if (!context.mounted) return;
    showMessage("المجلد غير موجود: $currentPath", isError: true);
    return;
  }

  final List<FileSystemEntity> items = directory.listSync().where((entity) {
    final name = entity.path.split(Platform.pathSeparator).last;
    if (name.startsWith(".")) return false;
    if (FileSystemEntity.isDirectorySync(entity.path)) return true;

    final lowerName = name.toLowerCase();
    return lowerName.endsWith(".alif") ||
        lowerName.endsWith(".الف") ||
        lowerName.endsWith(".aliflib");
  }).toList();

  items.sort((a, b) {
    final bool isDirA = FileSystemEntity.isDirectorySync(a.path);
    final bool isDirB = FileSystemEntity.isDirectorySync(b.path);

    if (isDirA && !isDirB) return -1;
    if (!isDirA && isDirB) return 1;

    return a.path.toLowerCase().compareTo(b.path.toLowerCase());
  });

  String formatFileSize(int bytes) {
    if (bytes < 1024) return "$bytes بايت";
    if (bytes < 1024 * 1024) {
      return "${(bytes / 1024).toStringAsFixed(2)} كيلوبايت";
    }
    if (bytes < 1024 * 1024 * 1024) {
      return "${(bytes / (1024 * 1024)).toStringAsFixed(2)} ميجابايت";
    }
    return "${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} جيجابايت";
  }

  if (!context.mounted) return;

  final parentPath = directory.parent.path;
  final pathController = TextEditingController(
    text: currentPath.handelHomePath,
  );

  showMyBottomSheet(
    context: context,
    header: buildHeader(
      context,
      rootPath,
      parentPath,
      currentPath,
      pathController,
      onFileSelected,
      onFolderSelected,
    ),
    child: Column(
      children: [
        Expanded(
          child: items.isNotEmpty
              ? ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (listContext, index) {
                    final entity = items[index];
                    final isDir = FileSystemEntity.isDirectorySync(entity.path);
                    final name = entity.path.split(Platform.pathSeparator).last;
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
                            ? getSafeDirCount(entity.path)
                            : "الحجم ${formatFileSize(File(entity.path).statSync().size)}",
                        style: TextStyle(color: context.secondary),
                      ),
                      trailing: isDir && onFolderSelected != null
                          ? IconButton(
                              icon: Icon(
                                LucideIcons.plus,
                                color: context.secondary,
                              ),
                              onPressed: () {
                                if (!listContext.mounted) return;
                                onFolderSelected(entity.path);
                                Navigator.pop(listContext);
                              },
                            )
                          : null,
                      onTap: () {
                        if (!listContext.mounted) return;
                        if (isDir) {
                          Navigator.pop(listContext);
                          showFileManagerModal(
                            context,
                            onFileSelected,
                            rootPath: rootPath,
                            startPath: entity.path,
                            onFolderSelected: onFolderSelected,
                          );
                        } else {
                          Navigator.pop(listContext);
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

Widget buildHeader(
  BuildContext context,
  String rootPath,
  String parentPath,
  String currentPath,
  TextEditingController pathController,
  void Function(String) onFileSelected,
  void Function(String)? onFolderSelected,
) {
  return Row(
    spacing: kSmallPadding,
    children: [
      if (currentPath != rootPath && currentPath != "/")
        MyMaterial(
          theme: MyMaterialTheme.border,
          padding: const EdgeInsets.all(0),
          child: IconButton(
            icon: Icon(LucideIcons.chevronLeft, color: context.secondary),
            onPressed: () {
              if (!context.mounted) return;
              Navigator.pop(context);
              showFileManagerModal(
                context,
                onFileSelected,
                rootPath: rootPath,
                startPath: parentPath,
                onFolderSelected: onFolderSelected,
              );
            },
          ),
        ),
      Expanded(
        child: MyMaterial(
          theme: MyMaterialTheme.border,
          padding: const EdgeInsets.all(kSmallPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.folderSearch,
                size: 18,
                color: context.secondary,
              ),
              Expanded(
                child: TextField(
                  controller: pathController,
                  style: ThemeText.mid,
                  textDirection: TextDirection.ltr,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    hintText: "ادخل المسار هنا...",
                    hintStyle: TextStyle(color: context.secondary),
                  ),
                  onSubmitted: (value) {
                    if (value.trim().isEmpty) return;
                    final inputPath = value.handelHomePath;

                    try {
                      final dir = Directory(inputPath);
                      if (!dir.existsSync()) {
                        showMessage("المسار غير موجود", isError: true);
                        pathController.text = currentPath.handelHomePath;
                        return;
                      }

                      final resolvedNew = dir.resolveSymbolicLinksSync();
                      final resolvedRoot = Directory(
                        rootPath,
                      ).resolveSymbolicLinksSync();

                      final isAllowed =
                          resolvedNew == resolvedRoot ||
                          resolvedNew.startsWith(
                            resolvedRoot + Platform.pathSeparator,
                          );

                      if (!isAllowed) {
                        showMessage(
                          "غير مسموح بالخروج عن المسار الأساسي",
                          isError: true,
                        );
                        pathController.text = currentPath.handelHomePath;
                        return;
                      }

                      if (!context.mounted) return;
                      Navigator.pop(context);
                      showFileManagerModal(
                        context,
                        onFileSelected,
                        rootPath: rootPath,
                        startPath: resolvedNew,
                        onFolderSelected: onFolderSelected,
                      );
                    } catch (e) {
                      showMessage("مسار غير صالح", isError: true);
                      pathController.text = currentPath.handelHomePath;
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

String getSafeDirCount(String path) {
  try {
    final dir = Directory(path);
    final count = dir.listSync().take(100).length;
    if (count == 0) return "مجلد فارغ";
    return count == 100 ? "+100 ملف" : "$count ملف";
  } catch (e) {
    return "مجلد محمي";
  }
}
