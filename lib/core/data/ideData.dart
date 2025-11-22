import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taif/core/data/dataTypes.dart';
import 'package:taif/utils/files/openFile.dart';
import 'package:taif/utils/files/saveFile.dart';

class IdeData extends ChangeNotifier {
  SharedPreferences? _prefs;
  IdeData() {
    _init();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    _lastFile = _prefs?.getInt("lastFile") ?? 0;
    _autoSave = _prefs?.getBool("autoSave") ?? true;
    _fontSize = _prefs?.getInt("fontSize") ?? 16;
    notifyListeners();
  }

  FocusNode focusNode = FocusNode();

  // files
  List<Map<String, dynamic>> files = [];
  void addFile(Map<String, dynamic> file) async {
    files.add(file);
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setString("opened_files", jsonEncode(files));
    notifyListeners();
  }

  void setFiles(List<Map<String, dynamic>> files) {
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
      file["Name"] = newName;
      if (file["Path"] != "") {
        final oldFile = File(file["Path"]!);
        final dir = oldFile.parent.path;
        final newPath = "$dir/${file["Name"]}";

        if (await oldFile.exists()) {
          await oldFile.copy(newPath);
          await oldFile.delete();
        }

        file["Path"] = newPath;
      }
      openFile(id, context);
    } else if (type == "delete" || type == "close") {
      files.removeAt(id);
      openFile(id - 1, context);
      if (type == "delete" || file["Path"] != "") {
        File(file["Path"]!).delete();
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

  // selected file
  late SelectedFile _selectedFile;
  SelectedFile get selectedFile => _selectedFile;

  void setSelectedFile(SelectedFile file) {
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
