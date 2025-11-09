import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OpenedFiles extends StatefulWidget {
  const OpenedFiles({
    super.key,
    required this.currentCode,
    required this.output,
    required this.selectedFile,
    this.onFileSelected,
    required this.autoSave,
  });

  final TextEditingController currentCode;
  final ValueNotifier<String> output;
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
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
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

    final status = await Permission.manageExternalStorage.status;
    if (!status.isDenied) {
      final defaultDir = Directory(
        '/storage/emulated/0/Documents/شفرات لغة الف',
      );
      if (!await defaultDir.exists()) await defaultDir.create(recursive: true);

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
        reverse: true,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildFileTab(int i) {
    final sel = selectedFile.value["id"] == i;
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: sel ? Border.all(color: const Color(0x509F45D3)) : null,
        boxShadow: sel
            ? [
                BoxShadow(
                  color: Colors.purpleAccent.withOpacity(0.5),
                  blurRadius: 5,
                ),
              ]
            : [],
      ),
      child: Material(
        color: sel ? const Color(0x10FFFFFF) : Colors.transparent,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () => _openFile(i),
          onLongPress: () => onLongPress(i, context, files, addOrUpdateFile),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: files[i]["Saved"] != null || files[i]["Path"] == ""
                        ? Colors.white70
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
                    color: Colors.white,
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
    padding: const EdgeInsets.all(16),
    decoration: const BoxDecoration(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      color: Color(0xFF081433),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "تعديل الملف",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Directionality(
          textDirection: TextDirection.rtl,
          child: TextField(
            controller: nameController,
            textAlign: TextAlign.right,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: "اسم الملف",
              labelStyle: TextStyle(color: Colors.white70),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          files[i]["Path"]?.replaceAll("/storage/emulated/0", "~") ??
              "لا يوجد مسار",
          style: const TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ?files[i]["Path"] != ""
                ? TextButton.icon(
                    icon: const Icon(LucideIcons.trash, color: Colors.red),
                    label: const Text(
                      'حذف',
                      style: TextStyle(color: Colors.red),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      addOrUpdateFile(files[i], "Delete");
                    },
                  )
                : null,
            TextButton.icon(
              icon: const Icon(LucideIcons.x, color: Colors.amber),
              label: const Text('إغلاق', style: TextStyle(color: Colors.amber)),
              onPressed: () {
                Navigator.pop(context);
                addOrUpdateFile(files[i], "Close");
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(LucideIcons.save, size: 20),
              label: const Text('حفظ التغييرات'),
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

const Map<String, String> defFile = {
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
