import "dart:ui" as ui;

import "package:code_forge/code_forge/controller.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "key_entity.dart";

class CodeController extends CodeForgeController {
  CodeController({super.lspConfig}) {
    suggestionsNotifier.addListener(_autoSelectFirstSuggestion);
  }
  void _autoSelectFirstSuggestion() {
    if (suggestionsNotifier.value != null &&
        suggestionsNotifier.value!.isNotEmpty) {
      currentlySelectedSuggestion ??= 0;
    }
  }

  void insert(BuildContext context, {KeyEntity? shortcut, String? char}) async {
    final String input = shortcut?.insert ?? char ?? "";

    if (input.isEmpty && (shortcut?.closing == null)) return;

    if (input == "\n") {
      if (suggestionsNotifier.value != null &&
          suggestionsNotifier.value!.isNotEmpty) {
        ServicesBinding.instance.keyEventManager.handleKeyData(
          ui.KeyData(
            type: ui.KeyEventType.down,
            logical: LogicalKeyboardKey.enter.keyId,
            physical: PhysicalKeyboardKey.enter.usbHidUsage,
            timeStamp: Duration.zero,
            character: "\n",
            synthesized: true,
          ),
        );
        return;
      }
    }

    if (shortcut != null &&
        shortcut.closing != null &&
        selection.start != selection.end) {
      final selectedText = text.substring(selection.start, selection.end);
      final wrappedText =
          "${shortcut.insert}${shortcut.insert == "#" ? " " : ""}$selectedText${shortcut.closing}";
      replaceRange(selection.start, selection.end, wrappedText);
      selection = TextSelection(
        baseOffset: selection.start,
        extentOffset: selection.start + wrappedText.length,
      );
      return;
    }

    final offset = selection.extentOffset;

    // ignore: invalid_use_of_protected_member
    updateEditingValueWithDeltas([
      TextEditingDeltaInsertion(
        oldText: text,
        textInserted: input,
        insertionOffset: offset,
        selection: TextSelection.collapsed(offset: offset + input.length),
        composing: TextRange.empty,
      ),
    ]);
  }

  @override
  void backspace() {
    if (readOnly) return;

    final sel = selection;

    if (!sel.isCollapsed) {
      super.backspace();
      return;
    }

    if (sel.start > 0) {
      final charBefore = text[sel.start - 1];
      final charAfter = (sel.start < text.length) ? text[sel.start] : "";
      const pairs = {
        "(": ")",
        "{": "}",
        "[": "]",
        '"': '"',
        "'": "'",
        "«": "»",
      };

      if (pairs[charBefore] == charAfter) {
        replaceRange(sel.start - 1, sel.start + 1, "");
        return;
      }

      super.backspace();
    }
  }

  @override
  Future<void> callSignatureHelp() async {
    if (openedFile == null || lspConfig == null) return;

    try {
      await super.callSignatureHelp();
    } catch (e) {
      debugPrint("SignatureHelp Safety: $e");
    }
  }

  @override
  void notifyListeners() {
    try {
      super.notifyListeners();
    } catch (e) {
      debugPrint("NotifyListeners Safety: $e");
    }
  }
}
