import "dart:io";
import "package:flutter/material.dart";
import "package:vibration/vibration.dart";

import "../../constants.dart";
import "../models/data_typs.dart";

class TerminalProvider extends ChangeNotifier {
  late final FocusNode terminalFocus;

  final List<TerminalLine> outputLines = [];
  String get output => outputLines.join("\n");

  int currentSessionId = 0;
  String terminalHint = "أدخل الأمر...";
  Process? runningProcess;

  TerminalProvider() {
    terminalFocus = FocusNode();
  }

  void startNewTerminalSession() {
    currentSessionId++;
    notifyListeners();
  }

  void addOutput(String text, {bool newLine = true, bool? isError}) {
    final prefix = isError == true
        ? "${l10n.error}: "
        : (isError == false ? "${l10n.warning}: " : "");
    final toAdd = "$prefix$text${newLine ? "\n" : ""}";

    if (outputLines.isEmpty) {
      outputLines.add(TerminalLine(text: "", sessionId: currentSessionId));
    }

    final combined = outputLines.removeLast().text + toAdd;
    final newTextLines = combined.split(RegExp(r"\r?\n"));

    for (var lineText in newTextLines) {
      outputLines.add(
        TerminalLine(
          text: lineText,
          sessionId: currentSessionId,
          isError: isError,
        ),
      );
    }

    if (outputLines.length > 300) {
      outputLines.removeRange(0, outputLines.length - 300);
    }

    notifyListeners();
    _triggerHapticFeedback(isError);
  }

  void clearOutput() {
    outputLines.clear();
    currentSessionId = 0;
    notifyListeners();
  }

  void sendOutput(String input) {
    runningProcess?.stdin.writeln(input);
    addOutput(input);
  }

  void updateTerminalHint(String? hint) {
    terminalHint = hint ?? "أدخل الأمر...";
    notifyListeners();
  }

  void editProcess(Process process) {
    runningProcess = process;
    notifyListeners();
  }

  void clearRunningProcess() {
    runningProcess?.kill();
    runningProcess = null;
    terminalHint = "أدخل الأمر...";
    notifyListeners();
  }

  void _triggerHapticFeedback(bool? isError) {
    if (isError == null) return;
    Vibration.hasVibrator().then((has) {
      if (has == true) {
        Vibration.vibrate(
          pattern: isError ? [0, 100, 50, 100] : [],
          duration: isError ? 0 : 50,
        );
      }
    });
  }

  @override
  void dispose() {
    terminalFocus.dispose();
    runningProcess?.kill();
    super.dispose();
  }
}
