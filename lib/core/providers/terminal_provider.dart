import "dart:io";
import "package:flutter/material.dart";

import "../../constants.dart";
import "../models/data_typs.dart";
import "settings_provider.dart";

class TerminalProvider extends ChangeNotifier {
  late final FocusNode terminalFocus;
  final SettingsProvider _settings;

  final List<TerminalLine> outputLines = [];
  String get output => outputLines.map((e) => e.text).join("\n");

  int currentSessionId = 0;
  String terminalHint = "أدخل الأمر...";
  Process? runningProcess;

  TerminalProvider(this._settings) {
    terminalFocus = FocusNode();
  }

  void startNewTerminalSession() {
    currentSessionId++;
    notifyListeners();
  }

  void addOutput(String text, {bool newLine = true, bool? isError}) {
    final prefix = (isError == true) || text.contains(l10n.error)
        ? "${l10n.error}: "
        : (isError == false) || text.contains(l10n.warning)
        ? "${l10n.warning}: "
        : "";

    if (outputLines.isEmpty) {
      outputLines.add(TerminalLine(text: "", sessionId: currentSessionId));
    }

    final String lastLineText = outputLines.removeLast().text;

    final String fullText =
        lastLineText +
        (lastLineText.isEmpty ? prefix : "") +
        text +
        (newLine ? "\n" : "");

    final List<String> rawLines = fullText.split("\n");

    for (int i = 0; i < rawLines.length; i++) {
      String processedLine = rawLines[i];
      if (processedLine.contains("\r")) {
        processedLine = processedLine.substring(
          processedLine.lastIndexOf("\r") + 1,
        );
      }

      if (i < rawLines.length - 1) {
        outputLines.add(
          TerminalLine(
            text: processedLine,
            sessionId: currentSessionId,
            isError: isError,
          ),
        );
      } else {
        if (fullText.endsWith("\n") && processedLine.isEmpty) {
          outputLines.add(TerminalLine(text: "", sessionId: currentSessionId));
        } else {
          outputLines.add(
            TerminalLine(
              text: processedLine,
              sessionId: currentSessionId,
              isError: isError,
            ),
          );
        }
      }
    }

    if (outputLines.length > 300) {
      outputLines.removeRange(0, outputLines.length - 300);
    }

    notifyListeners();
    _settings.runVibration(
      pattern: isError == true
          ? [0, 100, 50, 100]
          : isError == false
          ? [0, 100]
          : [0, 50],
      duration: isError == false ? 100 : 0,
    );
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

  @override
  void dispose() {
    terminalFocus.dispose();
    runningProcess?.kill();
    super.dispose();
  }
}
