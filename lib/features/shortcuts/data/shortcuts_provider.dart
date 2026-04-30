import "package:code_forge/code_forge.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:provider/provider.dart";
import "../../../core/providers/workspace_provider.dart";

class ShortcutsProvider extends ChangeNotifier {
  final List<ShortcutsEntity> nums = [
    ShortcutsEntity(name: "0", insert: "(", closing: ")"),
    ShortcutsEntity(name: "9", insert: ")"),
    ShortcutsEntity(name: "8", insert: "*"),
    ShortcutsEntity(name: "7", insert: "&"),
    ShortcutsEntity(name: "6", insert: "^"),
    ShortcutsEntity(name: "5", insert: "%"),
    ShortcutsEntity(name: "4", insert: "\$"),
    ShortcutsEntity(name: "3", insert: "#"),
    ShortcutsEntity(name: "2", insert: "@"),
    ShortcutsEntity(name: "1", insert: "!"),
  ];

  final List<List<SymbolData>> symbolsTemplate = [
    [
      SymbolData("[", closing: "]"),
      SymbolData("]"),
      SymbolData("{", closing: "}"),
      SymbolData("}"),
      SymbolData("|"),
      SymbolData("\\"),
      SymbolData("/"),
      SymbolData("~"),
      SymbolData("`", closing: "`"),
      SymbolData("_"),
      SymbolData("+"),
    ],
    [
      SymbolData("'", closing: "'"),
      SymbolData('"', closing: '"'),
      SymbolData(":"),
      SymbolData(";"),
      SymbolData("=="),
      SymbolData("="),
      SymbolData("!="),
      SymbolData("&&"),
      SymbolData("||"),
      SymbolData("-"),
      SymbolData("?"),
    ],
    [
      SymbolData("."),
      SymbolData(","),
      SymbolData("<"),
      SymbolData(">"),
      SymbolData("!"),
      SymbolData("؟"),
      SymbolData("%"),
      SymbolData("#"),
      SymbolData("@"),
      SymbolData("\$"),
    ],
  ];

  final List<List<String>> arabicNames = [
    ["ج", "ح", "خ", "ه", "ع", "غ", "ف", "ق", "ث", "ص", "ض"],
    ["ط", "ك", "م", "ن", "ت", "ا", "ل", "ب", "ي", "س", "ش"],
    ["د", "ظ", "ز", "و", "ة", "ى", "ر", "ؤ", "ء", "ذ"],
  ];

  final List<List<String>> englishNames = [
    ["p", "o", "i", "u", "y", "t", "r", "e", "w", "q"],
    ["l", "k", "j", "h", "g", "f", "d", "s", "a"],
    ["m", "n", "b", "v", "c", "x", "z"],
  ];

  List<List<ShortcutsEntity>> buildLayout(
    List<List<String>> names,
    List<List<SymbolData>> templates,
  ) {
    return List.generate(names.length, (rowIndex) {
      return List.generate(names[rowIndex].length, (charIndex) {
        final symbol = templates[rowIndex][charIndex];
        return ShortcutsEntity(
          name: names[rowIndex][charIndex],
          insert: symbol.insert,
          closing: symbol.closing,
        );
      });
    });
  }

  List<List<ShortcutsEntity>> get arabicLayout =>
      buildLayout(arabicNames, symbolsTemplate);
  List<List<ShortcutsEntity>> get englishLayout =>
      buildLayout(englishNames, symbolsTemplate);

  void insert(
    BuildContext context, {
    ShortcutsEntity? shortcut,
    String? char,
  }) async {
    final workspace = context.read<WorkspaceProvider>();
    final controller = workspace.codeController;
    final selection = controller.selection;
    final String input = shortcut?.insert ?? char ?? "";

    if (input.isEmpty && (shortcut?.closing == null)) return;

    if (shortcut != null &&
        shortcut.closing != null &&
        selection.start != selection.end) {
      final selectedText = controller.text.substring(
        selection.start,
        selection.end,
      );
      final wrappedText =
          "${shortcut.insert}${shortcut.insert == "#" ? " " : ""}$selectedText${shortcut.closing}";
      controller.replaceRange(selection.start, selection.end, wrappedText);
      controller.selection = TextSelection(
        baseOffset: selection.start,
        extentOffset: selection.start + wrappedText.length,
      );
      return;
    }

    final currentText = controller.text;
    final offset = selection.extentOffset;

    // ignore: invalid_use_of_protected_member
    controller.updateEditingValueWithDeltas([
      TextEditingDeltaInsertion(
        oldText: currentText,
        textInserted: input,
        insertionOffset: offset,
        selection: TextSelection.collapsed(offset: offset + input.length),
        composing: TextRange.empty,
      ),
    ]);
  }

  void deleteFunc(BuildContext context) {
    final controller = context.read<WorkspaceProvider>().codeController;
    final selection = controller.selection;
    final text = controller.text;

    if (selection.start != selection.end) {
      controller.replaceRange(selection.start, selection.end, "");
      return;
    }

    if (selection.start > 0) {
      if (selection.start < text.length) {
        final charBefore = text[selection.start - 1];
        final charAfter = text[selection.start];
        const pairs = {
          "(": ")",
          "{": "}",
          "[": "]",
          "<": ">",
          '"': '"',
          "'": "'",
          "`": "`",
        };
        if (pairs[charBefore] == charAfter) {
          controller.replaceRange(selection.start - 1, selection.start + 1, "");
          return;
        }
      }
      controller.replaceRange(selection.start - 1, selection.start, "");
    }
  }

  void moveCursorHorizontal(CodeForgeController controller, int direction) {
    const isRTL = true;
    // ignore: dead_code
    final int adjustedDirection = isRTL ? -direction : direction;
    final int newOffset = controller.selection.baseOffset + adjustedDirection;
    if (newOffset >= 0 && newOffset <= controller.text.length) {
      controller.selection = TextSelection.collapsed(offset: newOffset);
    }
  }

  void moveCursorVertical(CodeForgeController controller, int direction) {
    final offset = controller.selection.extentOffset;

    // 1. السطر الحالي
    final int currentLine = controller.getLineAtOffset(offset);

    // 2. العمود الحالي (Column)
    // بنجيب بداية السطر ونطرحها من الـ offset الكلي
    final int lineStart = controller.getLineStartOffset(currentLine);
    final int column = offset - lineStart;

    // 3. السطر المستهدف (فوق أو تحت)
    final int targetLine = (currentLine + direction).clamp(
      0,
      controller.lineCount - 1,
    );

    if (targetLine == currentLine) return; // لو مفيش تغيير م تعملش حاجة

    // 4. حساب الـ Offset الجديد في السطر المستهدف
    final int targetLineStart = controller.getLineStartOffset(targetLine);
    final String targetLineText = controller.getLineText(targetLine);

    // أهم حتة: نضمن إننا م نطلعش برا طول السطر الجديد (Clamping)
    final int newColumn = column.clamp(0, targetLineText.length);
    final int newOffset = targetLineStart + newColumn;

    // 5. تحديث المؤشر (استخدم silent عشان م تضربش IME)
    controller.setSelectionSilently(TextSelection.collapsed(offset: newOffset));
  }
}

class ShortcutsEntity {
  final int id;
  final String name;
  final String insert;
  final String? closing;
  int usageCount;

  ShortcutsEntity({
    this.id = 0,
    required this.name,
    String? insert,
    this.closing,
    this.usageCount = 0,
  }) : insert = insert ?? name;
}

class SymbolData {
  final String insert;
  final String? closing;
  SymbolData(this.insert, {this.closing});
}
