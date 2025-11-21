import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taif/core/data/dataTypes.dart';

class IdeData extends ChangeNotifier {
  late SharedPreferences _prefs;
  IdeData() {
    _init();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    _lastFile = _prefs.getInt("lastFile") ?? 0;
    _autoSave = _prefs.getBool("autoSave") ?? true;
    _fontSize = _prefs.getInt("fontSize") ?? 16;
    notifyListeners();
  }

  FocusNode focusNode = FocusNode();

  List<Map<String, dynamic>> files = [];
  void addFile(Map<String, dynamic> file) {
    files.add(file);
    notifyListeners();
  }

  // output
  String output = "";
  void addOutput(String text) {
    output += "$text\n";
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
  void editCode(newCode) {
    code.text = newCode;
    notifyListeners();
  }

  // settings
  int _lastFile = 15;
  int get lastFile => _lastFile;

  Future<void> setLastFile(int value) async {
    _lastFile = value;
    await _prefs.setInt("lastFile", value);
    notifyListeners();
  }

  bool _autoSave = true;
  bool get autoSave => _autoSave;

  Future<void> setAutoSave(bool value) async {
    _autoSave = value;
    await _prefs.setBool("autoSave", value);
    notifyListeners();
  }

  int _fontSize = 15;
  int get fontSize => _fontSize;

  Future<void> setFontSize(int value) async {
    _fontSize = value;
    await _prefs.setInt("fontSize", value);
    notifyListeners();
  }
}
