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
    // متابعة أي تعديل على الشفرة
    widget.currentCode.addListener(() {
      _hasChanges = true;
    });
    _loadFilesFromStorage();
    _startAutoSave();
  }

  Future<void> _loadFilesFromStorage() async {
    final prefs = await SharedPreferences.getInstance();

    // عرض الملفات المفتوحة سابقا
    final savedFiles = prefs.getString('opened_files');
    final lastFile = prefs.getInt("lastFile");
    if (savedFiles != null) {
      final decoded = jsonDecode(savedFiles);
      try {
        if (decoded is List) {
          files = decoded.map<Map<String, String>>((item) {
            return {
              "Name": item["Name"].toString(),
              "Path": item["Path"].toString(),
              "Code": item["Code"].toString(),
            };
          }).toList();
        }

        selectedFile.value = {
          "id": lastFile,
          "Name": files[lastFile!]["Name"],
          "Path": files[lastFile]["Path"],
          "Code": files[lastFile]["Code"],
        };
        _openFile(lastFile);
      } catch (e) {
        print("خطأ في قراءة البيانات المخزنة: $e");
      }
    } else {
      createFile(
        name: "الأعداد_الاولية.الف",
        code: """
# هذا البرنامج يقوم بطباعة الأعداد الاولية ضمن المدى المعطى له
دالة هل_اولي(عدد):
    اذا عدد < 2:
        ارجع
    اذا عدد == 2:
        اطبع(عدد)
        ارجع
    اذا ليس عدد \\\\ 2:
        ارجع
    لاجل مقسوم في مدى(3, صحيح(\\^عدد) + 1, 2):
        اذا ليس عدد \\\\ مقسوم:
            ارجع
    اطبع(عدد)

اطبع("*- هذا البرنامج يقوم بإيجاد الأعداد الأولية ضمن المدى المدخل له -*")
ن = صحيح(ادخل("ادخل عدد: "))
لاجل ب في مدى(ن):
    هل_اولي(ب)
اطبع(م"تم إيجاد الاعداد الاولية ضمن العدد { ن }")
""",
      );
    }
  }

  void _startAutoSave() {
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_hasChanges &&
          selectedFile.value["id"] >= 0 &&
          selectedFile.value["id"] < files.length) {
        files[selectedFile.value["id"]]["Code"] = widget.currentCode.text;
        files[selectedFile.value["id"]]["Path"] = selectedFile.value["Path"];
        selectedFile.value = {
          "id": selectedFile.value["id"],
          "Name": selectedFile.value["Name"],
          "Path": selectedFile.value["Path"],
          "Code": widget.currentCode.text,
        };
        if (widget.autoSave.value) {
          File(
            files[selectedFile.value["id"]]["Path"]!,
          ).writeAsString(files[selectedFile.value["id"]]["Code"] ?? "");
        }
        _saveFilesToStorage();
        _hasChanges = false;
      }
    });
  }

  void _openFile(int fileIndex) async {
    if (fileIndex < 0 || fileIndex >= files.length) return;
    var status = await Permission.manageExternalStorage.status;

    if (!status.isDenied) {
      final defaultDir = Directory(
        '/storage/emulated/0/Documents/شفرات لغة الف',
      );
      if (!await defaultDir.exists()) await defaultDir.create(recursive: true);

      final tempFile = File('${defaultDir.path}/${files[fileIndex]["Name"]}');
      await tempFile.writeAsString(files[fileIndex]["Code"] ?? "");
    }

    final prefs = await SharedPreferences.getInstance();

    // تغيير المؤشر للملف الجديد
    await prefs.setInt("lastFile", fileIndex);

    final openedFile = files[fileIndex];
    widget.currentCode.clear();
    widget.currentCode.text = openedFile["Code"] ?? "";
    selectedFile.value = {
      "id": fileIndex,
      "Name": openedFile["Name"],
      "Path": openedFile["Path"] ?? "",
      "Code": openedFile["Code"] ?? "",
    };

    setState(() {});
    widget.currentCode.text = openedFile["Code"] ?? "";

    await _saveFilesToStorage();
    widget.onFileSelected?.call(fileIndex);
  }

  void addOrUpdateFile(Map<String, String> file) {
    final existingIndex = files.indexWhere((f) => f['Path'] == file['Path']);
    setState(() {
      if (existingIndex >= 0) {
        files[existingIndex] = file;
      } else {
        files.add(file);
      }
    });
    _saveFilesToStorage();
  }

  @override
  void didUpdateWidget(OpenedFiles oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedFile != selectedFile.value["id"]) {
      selectedFile.value["id"] = widget.selectedFile;
    }
  }

  Future<void> _saveFilesToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(files);
    await prefs.setString('opened_files', encoded);
    await prefs.setInt("lastFile", selectedFile.value["id"] ?? 0);
    if (widget.autoSave.value) {
      File(
        files[selectedFile.value["id"]]["Path"]!,
      ).writeAsString(files[selectedFile.value["id"]]["Code"] ?? "");
    }
  }

  void createFile({String name = "", String code = ""}) {
    final newFile = {
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

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _saveFilesToStorage();
    super.dispose();
  }

  void removeFile(int index) async {
    setState(() {
      files.removeAt(index);
      if (selectedFile.value["id"] == index) {
        if (files.isNotEmpty) {
          selectedFile.value = {
            "id": index - 1,
            "Name": files[index - 1]["Name"],
            "Path": files[index - 1]["Path"],
            "Code": files[index - 1]["Code"],
          };
          widget.currentCode.text = files[index - 1]["Code"] ?? "";
        } else {
          selectedFile.value = {"id": 0, "Name": "", "Path": "", "Code": ""};
          widget.currentCode.clear();
        }
      } else if (selectedFile.value["id"] > index) {
        selectedFile.value["id"]--;
      }
    });

    await _saveFilesToStorage();
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
            // زر انشاء ملف جديد
            return Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(15),
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: () {
                  createFile();
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Icon(Icons.add, color: Colors.white),
                ),
              ),
            );
          }
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
                        offset: const Offset(0, 0),
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
                onLongPress: () =>
                    onLongPress(i, context, files, removeFile, addOrUpdateFile),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    files[i]["Name"]!,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: sel ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

void onLongPress(
  int i,
  BuildContext context,
  List<Map<String, String>> files,
  void Function(int) removeFile,
  void Function(Map<String, String>) addOrUpdateFile,
) {
  final nameController = TextEditingController(text: files[i]["Name"]);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return SafeArea(
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return WillPopScope(
              onWillPop: () {
                nameController.dispose();
                return Future.value(true);
              },
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
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
                              hintStyle: TextStyle(color: Colors.white54),
                              border: OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white54),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          files[i]["Path"] == ""
                              ? "لا يوجد مسار"
                              : files[i]["Path"]!.replaceAll(
                                  "/storage/emulated/0",
                                  "~",
                                ),
                          style: TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton.icon(
                              icon: const Icon(
                                LucideIcons.trash,
                                color: Colors.red,
                              ),
                              label: const Text(
                                'حذف',
                                style: TextStyle(color: Colors.red),
                              ),
                              onPressed: () {
                                nameController.dispose();
                                Navigator.pop(context);
                                removeFile(i);
                              },
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              icon: const Icon(
                                LucideIcons.x,
                                color: Colors.amber,
                              ),
                              label: const Text(
                                'إغلاق',
                                style: TextStyle(color: Colors.amber),
                              ),
                              onPressed: () {
                                nameController.dispose();
                                Navigator.pop(context);
                                removeFile(i);
                              },
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              icon: const Icon(LucideIcons.save, size: 20),
                              label: const Text('حفظ التغييرات'),
                              onPressed: () {
                                final newName = nameController.text.trim();
                                if (newName.isNotEmpty) {
                                  nameController.dispose();
                                  Navigator.pop(context);
                                  addOrUpdateFile({
                                    ...files[i],
                                    "Name": newName,
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    },
  );
}
