import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taif/data/data_types.dart';
import 'package:taif/core/services/files/open_file.dart';
import 'package:taif/core/services/files/save_file.dart';

class IdeData extends ChangeNotifier {
  SharedPreferences? _prefs;
  bool isReady = false;
  void setReady() {
    isReady = true;
    notifyListeners();
  }

  Future<void> init(BuildContext context) async {
    _prefs = await SharedPreferences.getInstance();
    _lastFile = _prefs?.getInt("lastFile") ?? 0;
    _autoSave = _prefs?.getBool("autoSave") ?? true;
    _fontSize = _prefs?.getInt("fontSize") ?? 16;
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
    final file = files[id];
    if (type == "reName") {
      file.name = newName!;
      if (file.path != "") {
        final oldFile = File(file.path ?? "");
        final dir = oldFile.parent.path;
        final newPath = "$dir/${file.name}";

        if (await oldFile.exists()) {
          await oldFile.copy(newPath);
          await oldFile.delete();
        }

        file.path = newPath;
      }
      openFile(id, context);
    } else if (type == "delete" || type == "close") {
      files.removeAt(id);
      openFile(id - 1, context);
      if (type == "delete" || file.path != "") {
        File(file.path!).delete();
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

  TextEditingController code = TextEditingController();
  void editCode(String newCode, {TextSelection? selection}) {
    if (code.text != newCode) {
      code.text = newCode;
    }
    if (selection != null) {
      code.selection = selection;
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

  bool _autoSave = true;
  bool get autoSave => _autoSave;

  Future<void> setAutoSave(bool value) async {
    _autoSave = value;
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setBool("autoSave", value);
    notifyListeners();
  }

  int _fontSize = 15;
  int get fontSize => _fontSize;

  Future<void> setFontSize(int value) async {
    _fontSize = value;
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setInt("fontSize", value);
    notifyListeners();
  }
}
