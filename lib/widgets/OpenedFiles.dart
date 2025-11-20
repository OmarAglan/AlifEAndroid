import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:alifeditor/core/theme/Colors.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OpenedFiles extends StatefulWidget {
  OpenedFiles({
    super.key,
    required this.currentCode,
    required this.selectedFile,
    this.onFileSelected,
    required this.autoSave,
  });

  final TextEditingController currentCode;
  final ValueNotifier<Map<dynamic, dynamic>> selectedFile;
  final ValueChanged<int>? onFileSelected;
  final ValueNotifier<bool> autoSave;

  @override
  OpenedFilesState createState() => OpenedFilesState();
}

class OpenedFilesState extends State<OpenedFiles> {
  late ValueNotifier<Map<dynamic, dynamic>> selectedFile;
  List<Map<String, String>> files = [];

  Timer? _autoSaveTimer;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    selectedFile = widget.selectedFile;
    widget.currentCode.addListener(() => _hasChanges = true);
    _loadFilesFromStorage();
    _startAutoSave();
  }

  Future<void> _loadFilesFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedFiles = prefs.getString('opened_files');
    final lastFile = prefs.getInt("lastFile");

    if (savedFiles != null) {
      try {
        final decoded = jsonDecode(savedFiles);
        if (decoded is List) {
          files = decoded
              .map<Map<String, String>>(
                (item) => {
                  "Name": item["Name"].toString(),
                  "Path": item["Path"].toString(),
                  "Code": item["Code"].toString(),
                },
              )
              .toList();
        }
        if (lastFile != null && lastFile >= 0 && lastFile < files.length) {
          _openFile(lastFile);
        }
      } catch (e) {
        debugPrint("خطأ في قراءة الملفات المخزنة: $e");
      }
    } else {
      createFile(name: defFile["Name"]!, code: defFile["Code"]!);
    }
  }

  void _startAutoSave() {
    _autoSaveTimer = Timer.periodic(Duration(seconds: 1), (_) async {
      if (!_hasChanges ||
          selectedFile.value["id"] == null ||
          selectedFile.value["id"] >= files.length)
        return;

      final index = selectedFile.value["id"];
      files[index]["Code"] = widget.currentCode.text;
      files[index]["Path"] = selectedFile.value["Path"];
      selectedFile.value = {
        "id": index,
        "Name": selectedFile.value["Name"],
        "Path": selectedFile.value["Path"],
        "Code": widget.currentCode.text,
      };

      if (widget.autoSave.value && files[index]["Path"]?.isNotEmpty == true) {
        await File(files[index]["Path"]!).writeAsString(files[index]["Code"]!);
      }

      await _saveFilesToStorage();
      _hasChanges = false;
    });
  }

  Future<void> _openFile(int fileIndex) async {
    if (fileIndex < 0 || fileIndex >= files.length) return;

    Directory defaultDir;

    if (Platform.isAndroid) {
      final status = await Permission.manageExternalStorage.status;
      if (!status.isDenied) {
        defaultDir = Directory('/storage/emulated/0/Documents/شفرات لغة الف');
        if (!await defaultDir.exists())
          await defaultDir.create(recursive: true);

        final tempFile = File('${defaultDir.path}/${files[fileIndex]["Name"]}');
        await tempFile.writeAsString(files[fileIndex]["Code"] ?? "");
      }
    } else if (Platform.isLinux) {
      final home = Platform.environment['HOME']!;
      defaultDir = Directory('$home/Documents/شفرات لغة الف');

      if (!await defaultDir.exists()) {
        await defaultDir.create(recursive: true);
      }

      final tempFile = File('${defaultDir.path}/${files[fileIndex]["Name"]}');
      await tempFile.writeAsString(files[fileIndex]["Code"] ?? "");
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("lastFile", fileIndex);

    final openedFile = files[fileIndex];
    widget.currentCode.text = openedFile["Code"] ?? "";
    selectedFile.value = {
      "id": fileIndex,
      "Name": openedFile["Name"],
      "Path": openedFile["Path"] ?? "",
      "Code": openedFile["Code"] ?? "",
    };

    setState(() {});
    await _saveFilesToStorage();
    widget.onFileSelected?.call(fileIndex);
  }

  void createFile({String name = "", String code = ""}) {
    final newFile = {
      "id": (files.length - 1).toString(),
      "Name": name.isEmpty ? "ملف_جديد_${files.length + 1}.الف" : name,
      "Path": "",
      "Code": code,
    };
    setState(() {
      files.add(newFile);
      selectedFile.value = {
        "id": files.length - 1,
        "Name": newFile["Name"],
        "Path": newFile["Path"],
        "Code": newFile["Code"],
      };
      widget.currentCode.text = newFile["Code"] ?? "";
    });
    _saveFilesToStorage();
  }

  void addOrUpdateFile(Map<String, String> file, String type) async {
    final existingIndex = files.indexWhere(
      (f) =>
          f["Path"] != "" ? f['Path'] == file['Path'] : f["id"] == file["id"],
    );
    if (existingIndex >= 0) {
      if (type == "Update") {
        try {
          final oldFile = File(file["Path"]!);
          final dir = oldFile.parent.path;
          final newPath = "$dir/${file["Name"]}";

          if (await oldFile.exists()) {
            await oldFile.copy(newPath);
            await oldFile.delete();
          }

          file["Path"] = newPath;
          files[existingIndex] = file;
        } catch (e) {
          print(e);
        }
      } else if (type == "Close" || type == "Delete") {
        files.removeAt(existingIndex);
        if (files.isNotEmpty) {
          final newIndex = (existingIndex > 0) ? existingIndex - 1 : 0;
          final newFile = files[newIndex];
          selectedFile.value = {
            "id": newIndex,
            "Name": newFile["Name"],
            "Path": newFile["Path"],
            "Code": newFile["Code"],
          };
          setState(() {});
          if (type == "Delete") File(file["Path"]!).delete();
          widget.currentCode.text = newFile["Code"] ?? "";
          if (files[existingIndex]["Name"] != newFile["Name"]) {
            File(newFile["Path"]!).rename(newFile["Name"]!);
          }
        } else {
          createFile(name: defFile["Name"]!, code: defFile["Code"]!);
        }
      } else {
        createFile(name: defFile["Name"]!, code: defFile["Code"]!);
      }
    } else {
      files.add(file);
    }
    setState(() {});
    _saveFilesToStorage();
  }

  Future<void> _saveFilesToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('opened_files', jsonEncode(files));
    await prefs.setInt("lastFile", selectedFile.value["id"] ?? 0);
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _saveFilesToStorage();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        itemCount: files.length + 1,
        itemBuilder: (context, i) {
          if (i == files.length) {
            return _buildAddButton();
          }
          return _buildFileTab(i);
        },
      ),
    );
  }

  Widget _buildAddButton() {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: createFile,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Icon(Icons.add, color: ThemeColors.foreground),
        ),
      ),
    );
  }

  Widget _buildFileTab(int i) {
    final sel = selectedFile.value["id"] == i;
    return Container(
      margin: EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: sel
            ? Border.all(color: ThemeColors.primary.withOpacity(.1))
            : null,
        boxShadow: sel
            ? [BoxShadow(color: ThemeColors.primary, blurRadius: 5)]
            : [],
      ),
      child: Material(
        color: sel ? Color(0x10FFFFFF) : Colors.transparent,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () => _openFile(i),
          onLongPress: () => onLongPress(i, context, files, addOrUpdateFile),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: files[i]["Saved"] != null || files[i]["Path"] == ""
                        ? ThemeColors.foreground
                        : Colors.transparent,
                  ),
                ),
                SizedBox(
                  width: files[i]["Saved"] != null || files[i]["Path"] == ""
                      ? 5
                      : 0,
                ),
                Text(
                  files[i]["Name"]!,
                  style: TextStyle(
                    color: ThemeColors.foreground,
                    fontWeight: sel ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void onLongPress(
  int i,
  BuildContext context,
  List<Map<String, String>> files,
  void Function(Map<String, String>, String) addOrUpdateFile,
) {
  final nameController = TextEditingController(text: files[i]["Name"]);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: _buildFileOptions(
          i,
          ctx,
          files,
          addOrUpdateFile,
          nameController,
        ),
      ),
    ),
  );
}

Widget _buildFileOptions(
  int i,
  BuildContext context,
  List<Map<String, String>> files,
  void Function(Map<String, String>, String) addOrUpdateFile,
  TextEditingController nameController,
) {
  return Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      color: ThemeColors.background,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "تعديل الملف",
          style: TextStyle(
            color: ThemeColors.foreground,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        TextField(
          controller: nameController,
          textAlign: TextAlign.right,
          style: TextStyle(color: ThemeColors.foreground),
          decoration: InputDecoration(
            labelText: "اسم الملف",
            labelStyle: TextStyle(color: ThemeColors.foreground),
          ),
        ),

        SizedBox(height: 16),
        Text(
          files[i]["Path"]?.replaceAll("/storage/emulated/0", "~") ??
              "لا يوجد مسار",
          style: TextStyle(color: ThemeColors.foreground),
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ?files[i]["Path"] != ""
                ? TextButton.icon(
                    icon: Icon(LucideIcons.trash, color: Colors.red),
                    label: Text('حذف', style: TextStyle(color: Colors.red)),
                    onPressed: () {
                      Navigator.pop(context);
                      addOrUpdateFile(files[i], "Delete");
                    },
                  )
                : null,
            TextButton.icon(
              icon: Icon(LucideIcons.x, color: Colors.amber),
              label: Text('إغلاق', style: TextStyle(color: Colors.amber)),
              onPressed: () {
                Navigator.pop(context);
                addOrUpdateFile(files[i], "Close");
              },
            ),
            ElevatedButton.icon(
              icon: Icon(LucideIcons.save, size: 20),
              label: Text('حفظ التغييرات'),
              onPressed: () {
                final newName = nameController.text.trim();
                if (newName.isNotEmpty) {
                  Navigator.pop(context);
                  final updatedFile = {...files[i], "Name": newName};
                  addOrUpdateFile(updatedFile, "Update");
                }
              },
            ),
          ],
        ),
      ],
    ),
  );
}

Map<String, String> defFile = {
  "Name": "الأعداد_الاولية.الف",
  "Code": """
# برنامج لإيجاد الأعداد الأولية
دالة هل_اولي(عدد):
    اذا عدد < 2: ارجع
    اذا عدد == 2: اطبع(عدد); ارجع
    اذا ليس عدد \\\\ 2: ارجع
    لاجل مقسوم في مدى(3, صحيح(\\^عدد) + 1, 2):
        اذا ليس عدد \\\\ مقسوم: ارجع
    اطبع(عدد)

اطبع("*- هذا البرنامج يقوم بإيجاد الأعداد الأولية ضمن المدى المدخل له -*")
ن = صحيح(ادخل("ادخل عدد: "))
لاجل ب في مدى(ن): هل_اولي(ب)
""",
};
