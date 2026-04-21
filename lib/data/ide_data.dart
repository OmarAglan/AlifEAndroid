import "dart:convert";
import "dart:io";

import "package:code_forge/code_forge/controller.dart";
import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";
import "../constants.dart";
import "../core/services/files/open_file.dart";
import "../core/services/files/save_file.dart";
import "data_types.dart";

class IdeData extends ChangeNotifier {
  static const String appVersion = "1.1.0";
  static const String alifVersion = "5.3.0";

  SharedPreferences? _prefs;
  bool isReady = false;
  void setReady() {
    isReady = true;
    notifyListeners();
  }

  IdeData() {
    _selectedFile = const FileEntity(id: -1, name: "", code: "", saved: true);
    _init();
  }

  bool autoSave = true;
  double fontSize = kMediumFont;

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    _lastFile = _prefs?.getInt("lastFile") ?? 0;
    autoSave = _prefs?.getBool("autoSave") ?? true;
    fontSize = _prefs?.getDouble("fontSize") ?? kMediumFont;
    notifyListeners();
  }

  FocusNode focusNode = FocusNode();

  // files
  List<FileEntity> files = [];
  void addFile(FileEntity file) async {
    files.add(file);
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setString("opened_files", jsonEncode(files));
    notifyListeners();
  }

  void setFiles(List<FileEntity> files) {
    this.files = files;
    notifyListeners();
  }

  void updateFile(
    BuildContext context,
    int id,
    String type, {
    String? newName,
  }) async {
    if (id < 0 || id >= files.length) return;

    final file = files[id];
    if (type == "reName") {
      final updatedName = newName?.trim();
      if (updatedName == null || updatedName.isEmpty) return;

      final updatedFile = file.copyWith(name: updatedName);
      files[id] = updatedFile;

      if (file.path != null && file.path!.isNotEmpty) {
        final oldFile = File(file.path!);
        final dir = oldFile.parent.path;
        final newPath = "$dir/$updatedName";

        if (await oldFile.exists()) {
          try {
            final renamed = await oldFile.rename(newPath);
            files[id] = updatedFile.copyWith(path: renamed.path);
          } catch (_) {
            final copied = await oldFile.copy(newPath);
            await oldFile.delete();
            files[id] = updatedFile.copyWith(path: copied.path);
          }
        }
      }

      if (_selectedFile.id == id) setSelectedFile(files[id]);

      if (!context.mounted) return;
      openFile(id, context);
    } else if (type == "delete" || type == "close") {
      final removed = files.removeAt(id);
      if (type == "delete" &&
          removed.path != null &&
          removed.path!.isNotEmpty) {
        try {
          await File(removed.path!).delete();
        } catch (_) {
          // Ignore delete errors and keep working.
        }
      }

      if (!context.mounted) return;
      if (files.isNotEmpty) {
        final nextIndex = id >= files.length ? files.length - 1 : id;
        openFile(nextIndex, context);
      } else {
        const newFile = FileEntity(
          id: 0,
          name: "ملف_جديد_1.الف",
          code: "",
          saved: false,
        );
        files.add(newFile);
        openFile(0, context);
      }
    }
    saveFilesLocal(context);
    notifyListeners();
  }

  // output
  String output = "";
  void addOutput(String text, {bool newLine = true}) {
    output += "$text${newLine ? "\n" : ""}";
    notifyListeners();
  }

  void clearOutput() {
    output = "";
    notifyListeners();
  }

  void sendOutput(String input) {
    runningProcess?.stdin.writeln(input);
    addOutput(input);
  }

  // alif Path
  String? alifBinPath;
  void setAlifPath(String path) {
    alifBinPath = path;
    notifyListeners();
  }

  // run Alif
  Process? runningProcess;
  void editProcess(Process process) {
    runningProcess = process;
    notifyListeners();
  }

  void clearRunningProcess() {
    runningProcess = null;
    notifyListeners();
  }

  // selected file
  late FileEntity _selectedFile;
  FileEntity get selectedFile => _selectedFile;

  void setSelectedFile(FileEntity file) {
    _selectedFile = file;
    notifyListeners();
  }

  CodeForgeController code = CodeForgeController();
  void editCode(
    String newCode, {
    TextSelection? selection,
    bool markDirty = false,
  }) {
    if (code.text != newCode) code.text = newCode;
    if (selection != null) code.selection = selection;

    if (markDirty) {
      _selectedFile = _selectedFile.copyWith(code: newCode, saved: autoSave);
      final index = files.indexWhere((file) => file.id == _selectedFile.id);
      if (index >= 0) {
        files[index] = files[index].copyWith(code: newCode, saved: autoSave);
      }
    }

    notifyListeners();
  }

  // search
  bool searchActive = false;

  void openSearch() {
    searchActive = true;
    notifyListeners();
  }

  // settings
  int _lastFile = 15;
  int get lastFile => _lastFile;

  Future<void> setLastFile(int value) async {
    _lastFile = value;
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setInt("lastFile", value);
    notifyListeners();
  }

  Future<void> setAutoSave(bool value) async {
    autoSave = value;
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setBool("autoSave", value);
    notifyListeners();
  }

  Future<void> setFontSize(double value) async {
    fontSize = value;
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setDouble("fontSize", value);
    notifyListeners();
  }
}
