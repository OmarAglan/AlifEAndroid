import "dart:convert";
import "dart:io";

import "package:code_forge/code_forge.dart";
import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:vibration/vibration.dart";

import "../constants.dart";
import "../core/services/files/open_file.dart";
import "../core/services/files/save_file.dart";
import "data_types.dart";

class IdeData extends ChangeNotifier {
  static const String appVersion = "v1.1.0";
  static const String alifVersion = "v5.3.0";

  SharedPreferences? _prefs;

  late final CodeForgeController code;
  late final FindController findController;
  late final UndoRedoController undoController;
  late final FocusNode terminalFocus;

  bool isReady = false;
  void setReady() {
    isReady = true;
    notifyListeners();
  }

  IdeData() {
    code = CodeForgeController();
    findController = FindController(code);
    undoController = UndoRedoController();
    terminalFocus = FocusNode();
    _selectedFile = const FileEntity(id: -1, name: "", code: "", saved: true);
    _init();
  }

  bool autoSave = true;
  double fontSize = kMediumFont;

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    _lastFile = _prefs?.getInt(kKeyLastFile) ?? 0;
    autoSave = _prefs?.getBool(kKeyAutoSave) ?? true;
    fontSize = _prefs?.getDouble(kKeyFontSize) ?? kMediumFont;
    workspacePath = _prefs?.getString(kKeyWorkspacePath);
    notifyListeners();
  }

  FocusNode focusNode = FocusNode();

  // files
  List<FileEntity> files = [];
  void addFile(FileEntity file) async {
    files.add(file);
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs?.setString(kKeyOpenedFiles, jsonEncode(files));
    notifyListeners();
  }

  void setFiles(List<FileEntity> files) {
    this.files = files;
    notifyListeners();
  }

  void updateFile(
    BuildContext context,
    int id,
    FileAction type, {
    String? newName,
  }) async {
    if (id < 0 || id >= files.length) return;
    var file = files[id];

    if (type == FileAction.rename && newName?.trim().isNotEmpty == true) {
      final String? newPath = file.path != null
          ? "${File(file.path!).parent.path}/${newName!.trim()}"
          : null;
      if (newPath != null && await File(file.path!).exists()) {
        try {
          await File(file.path!).rename(newPath);
        } catch (_) {
          await File(file.path!).copy(newPath);
          await File(file.path!).delete();
        }
        file = file.copyWith(path: newPath);
      }
      files[id] = file.copyWith(name: newName!.trim());
      if (_selectedFile.id == id) setSelectedFile(files[id]);
      if (context.mounted) openFile(id, context);
    } else if (type == FileAction.delete || type == FileAction.close) {
      final removed = files.removeAt(id);
      if (_selectedFile.id == removed.id) _selectedFile = FileEntity.empty();

      if (type == FileAction.delete && removed.path?.isNotEmpty == true) {
        try {
          final f = File(removed.path!).absolute;
          if (f.existsSync()) f.deleteSync(recursive: true);
        } catch (_) {}
      }

      if (!context.mounted) return;
      if (files.isNotEmpty) {
        openFile(id >= files.length ? files.length - 1 : id, context);
      } else {
        files.add(
          const FileEntity(
            id: 0,
            name: "ملف_جديد_1.الف",
            code: "",
            saved: false,
          ),
        );
        openFile(0, context);
      }
    } else if (type == FileAction.toggleReadOnly) {
      files[id] = file.copyWith(readOnly: !file.readOnly);
      code.readOnly = files[id].readOnly;
    }

    if (context.mounted) saveFilesLocal(context);
    notifyListeners();
  }

  // output
  final List<TerminalLine> outputLines = [];
  String get output => outputLines.join("\n");

  int _currentSessionId = 0;
  int get currentSessionId => _currentSessionId;

  void startNewTerminalSession() {
    _currentSessionId++;
    notifyListeners();
  }

  void addOutput(String text, {bool newLine = true, bool? isError}) {
    String prefix = "";
    if (isError == true) {
      prefix = "${l10n.error}: ";
    } else if (isError == false) {
      prefix = "${l10n.warning}: ";
    }

    final String toAdd = "$prefix$text${newLine ? "\n" : ""}";

    if (outputLines.isEmpty) {
      outputLines.add(TerminalLine(text: "", sessionId: _currentSessionId));
    }

    final lastLineObj = outputLines.removeLast();
    final String combined = lastLineObj.text + toAdd;

    final List<String> newTextLines = combined.split(RegExp(r"\r?\n"));

    for (var lineText in newTextLines) {
      outputLines.add(
        TerminalLine(
          text: lineText,
          sessionId: _currentSessionId,
          isError: isError,
        ),
      );
    }

    const maxLines = 300;
    if (outputLines.length > maxLines) {
      outputLines.removeRange(0, outputLines.length - maxLines);
    }

    notifyListeners();
    _triggerHapticFeedback(isError);
  }

  void clearOutput() {
    outputLines.clear();
    _currentSessionId = 0;
    notifyListeners();
  }

  void _triggerHapticFeedback(bool? isError) {
    if (isError == null) return;
    Vibration.hasVibrator().then((has) {
      if (has == true) {
        if (isError) {
          Vibration.vibrate(pattern: [0, 100, 50, 100]);
        } else {
          Vibration.vibrate(duration: 50);
        }
      }
    });
  }

  void sendOutput(String input) {
    runningProcess?.stdin.writeln(input);
    addOutput(input);
  }

  String terminalHint = l10n.enterCommand;
  void updateTerminalHint(String? hint) {
    terminalHint = hint ?? l10n.enterCommand;
    notifyListeners();
  }

  // alif Path
  String? alifBinPath;
  void setAlifPath(String path) {
    alifBinPath = path;
    notifyListeners();
  }

  // workspace path
  String? workspacePath;
  void setWorkspacePath(String? path) {
    workspacePath = path;
    if (path != null) _prefs?.setString(kKeyWorkspacePath, path);
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
    updateTerminalHint(null);
    notifyListeners();
  }

  // selected file
  late FileEntity _selectedFile;
  FileEntity get selectedFile => _selectedFile;

  void setSelectedFile(FileEntity file) {
    if (_selectedFile.id != -1) {
      final currentIndex = files.indexWhere((f) => f.id == _selectedFile.id);
      if (currentIndex != -1) {
        files[currentIndex] = files[currentIndex].copyWith(
          cursor: [code.selection.start, code.selection.end],
        );
      }
    }

    _selectedFile = file;
    code.readOnly = file.readOnly;

    Future.microtask(() {
      final int start = file.cursor[0].clamp(0, code.text.length);
      final int end = file.cursor[1].clamp(0, code.text.length);
      code.selection = TextSelection(baseOffset: start, extentOffset: end);
    });

    notifyListeners();
  }

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
  void toggleSearch() {
    findController.isActive = !findController.isActive;
    if (findController.isActive) {
      Future.microtask(() => findController.findInputFocusNode.requestFocus());
    } else {
      findController.clear();
      focusNode.requestFocus();
    }

    notifyListeners();
  }

  // settings
  int _lastFile = 0;
  int get lastFile => _lastFile;

  Future<void> setLastFile(int value) async {
    _lastFile = value;
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs?.setInt(kKeyLastFile, value);
    notifyListeners();
  }

  Future<void> setAutoSave(bool value) async {
    autoSave = value;
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs?.setBool(kKeyAutoSave, value);
    notifyListeners();
  }

  Future<void> setFontSize(double value) async {
    fontSize = value;
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs?.setDouble(kKeyFontSize, value);
    notifyListeners();
  }
}
