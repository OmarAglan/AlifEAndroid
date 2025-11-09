import 'dart:convert';
import 'dart:io';
import 'package:alifeditor/pages/About.dart';
import 'package:alifeditor/utils/filePicker.dart';
import 'package:alifeditor/widgets/OpenedFiles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_saver/file_saver.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/Terminal.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AlifAppBar extends StatefulWidget {
  const AlifAppBar({
    super.key,
    required this.controller,
    required this.inputController,
    required this.output,
    required this.alifBinPath,
    required this.runningProcess,
    required this.runAlifCode,
    required this.selectedFile,
    required this.fontSize,
    required this.autoSave,
  });

  final TextEditingController controller;
  final TextEditingController inputController;
  final ValueNotifier<String> output;
  final String? alifBinPath;
  final ValueNotifier<Process?> runningProcess;
  final VoidCallback runAlifCode;
  final ValueNotifier<Map<dynamic, dynamic>> selectedFile;

  final ValueNotifier<double> fontSize;
  final ValueNotifier<bool> autoSave;

  @override
  State<AlifAppBar> createState() => _AlifAppBarState();
}

class _AlifAppBarState extends State<AlifAppBar> {
  final GlobalKey<OpenedFilesState> _openedFilesKey =
      GlobalKey<OpenedFilesState>();

  @override
  Widget build(BuildContext context) {
    ValueNotifier<String> output = widget.output;
    TextEditingController controller = widget.controller;
    TextEditingController inputController = widget.inputController;
    String? alifBinPath = widget.alifBinPath;
    ValueNotifier<Process?> runningProcess = widget.runningProcess;
    VoidCallback runAlifCode = widget.runAlifCode;
    ValueNotifier<Map<dynamic, dynamic>> selectedFile = widget.selectedFile;

    Future<void> saveCode(String code) async {
      if (selectedFile.value["Path"] == "") {
        try {
          final bytes = Uint8List.fromList(utf8.encode(code));
          final path = await FileSaver.instance.saveAs(
            name:
                (selectedFile.value["Name"] == null ||
                    selectedFile.value["Name"].isEmpty)
                ? 'شفرة'
                : selectedFile.value["Name"].toString().replaceAll(
                    RegExp(r'\.(الف|alif|aliflib)$'),
                    "",
                  ),
            bytes: bytes,
            fileExtension: "الف",
            mimeType: MimeType.other,
          );
          if (path == null || path.isEmpty) {
            output.value += "تم إلغاء الحفظ.\n";
            return;
          }

          final prefs = await SharedPreferences.getInstance();
          // جلب الملفات
          final savedFiles = prefs.getString('opened_files');
          final List<Map<String, String>> filesList = savedFiles != null
              ? List<Map<String, String>>.from(
                  jsonDecode(savedFiles).map(
                    (item) => {
                      "Name": item["Name"].toString(),
                      "Path": item["Path"].toString(),
                      "Code": item["Code"].toString(),
                    },
                  ),
                )
              : [];

          print(filesList);

          final fileData = {
            "Name": selectedFile.value["Name"].toString(),
            "Path": path,
            "Code": code,
          };
          filesList[filesList.indexWhere(
                (p) => p["Name"] == selectedFile.value["Name"].toString(),
              )] =
              fileData;

          await prefs.setString('opened_files', jsonEncode(filesList));

          // تحديث واجهة المستخدم
          _openedFilesKey.currentState?.files = filesList;
          setState(
            () => selectedFile.value = {
              ...selectedFile.value,
              "Path": path,
              "Code": code,
            },
          );
          print(filesList);

          output.value += "تم الحفظ في: $path\n";
        } catch (e) {
          output.value += "خطأ أثناء الحفظ: $e\n";
        }
      } else {
        File(
          selectedFile.value["Path"]!,
        ).writeAsString(selectedFile.value["Code"]);
      }
    }

    Future<void> openFile() async {
      try {
        showFileManagerModal(context, (selectedPath) async {
          final file = File(selectedPath);
          final code = await file.readAsString();
          final fileName = selectedPath.split(Platform.pathSeparator).last;

          final prefs = await SharedPreferences.getInstance();
          // جلب الملفات القديمة
          final savedFiles = prefs.getString('opened_files');
          final List<Map<String, String>> filesList = savedFiles != null
              ? List<Map<String, String>>.from(
                  jsonDecode(savedFiles).map(
                    (item) => {
                      "Name": item["Name"].toString(),
                      "Path": item["Path"].toString(),
                      "Code": item["Code"].toString(),
                    },
                  ),
                )
              : [];

          final existingIndex = filesList.indexWhere(
            (f) => f["Path"] == selectedPath,
          );

          if (existingIndex >= 0) {
            selectedFile.value = {
              ...filesList[existingIndex],
              "id": existingIndex,
            };
            setState(
              () =>
                  controller.text = filesList[existingIndex]["Code"].toString(),
            );
          } else {
            final fileData = {
              "Name": fileName,
              "Path": selectedPath,
              "Code": code,
            };

            filesList.add(fileData);
            await prefs.setString('opened_files', jsonEncode(filesList));
            // تحديث واجهة المستخدم
            _openedFilesKey.currentState?.addOrUpdateFile(fileData, "");
            selectedFile.value = {...fileData, "id": filesList.length - 1};
            setState(() => controller.text = code);
          }
        });
      } catch (e) {
        output.value += "خطأ أثناء الفتح: $e\n";
      }
    }

    return Padding(
      padding: const EdgeInsets.only(top: 10, right: 10, left: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      LucideIcons.folderOpen,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: openFile,
                  ),
                  IconButton(
                    icon: const Icon(
                      LucideIcons.save,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () => saveCode(controller.text),
                  ),
                  IconButton(
                    icon: const Icon(
                      LucideIcons.play,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () => {
                      output.value = '',
                      runAlifCode(),
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) => Terminal(
                          inputController: inputController,
                          output: output,
                          alifBinPath: alifBinPath,
                          runAlifProcess: runningProcess.value,
                          runAlifCode: runAlifCode,
                          onClearOutput: () => output.value = '',
                          onSendInput: (input) {
                            runningProcess.value?.stdin.writeln(input);
                            output.value += "$input\n";
                            inputController.clear();
                          },
                        ),
                      ),
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      LucideIcons.terminal,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) => Terminal(
                          inputController: inputController,
                          output: output,
                          alifBinPath: alifBinPath,
                          runAlifProcess: runningProcess.value,
                          runAlifCode: runAlifCode,
                          onClearOutput: () => output.value = '',
                          onSendInput: (input) {
                            runningProcess.value?.stdin.writeln(input);
                            output.value += "$input\n";
                            inputController.clear();
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => About(
                      fontSize: widget.fontSize,
                      autoSave: widget.autoSave,
                    ),
                  );
                },
                child: Text(
                  "مُحرر طيف",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          OpenedFiles(
            key: _openedFilesKey,
            currentCode: controller,
            output: output,
            selectedFile: selectedFile,
            autoSave: widget.autoSave,
            onFileSelected: (index) {
              selectedFile.value = {...selectedFile.value, "id": index};
            },
          ),
        ],
      ),
    );
  }
}
