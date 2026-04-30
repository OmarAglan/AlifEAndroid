import "package:code_forge/code_forge.dart";
import "package:flutter/material.dart";
import "../../editor/models/key_entity.dart";

class ShortcutsProvider extends ChangeNotifier {
  final List<KeyEntity> nums = [
    KeyEntity(name: "0", insert: "(", closing: ")"),
    KeyEntity(name: "9", insert: ")"),
    KeyEntity(name: "8", insert: "*"),
    KeyEntity(name: "7", insert: "&"),
    KeyEntity(name: "6", insert: "^"),
    KeyEntity(name: "5", insert: "%"),
    KeyEntity(name: "4", insert: "\$"),
    KeyEntity(name: "3", insert: "#"),
    KeyEntity(name: "2", insert: "@"),
    KeyEntity(name: "1", insert: "!"),
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

  List<List<KeyEntity>> buildLayout(
    List<List<String>> names,
    List<List<SymbolData>> templates,
  ) {
    return List.generate(names.length, (rowIndex) {
      return List.generate(names[rowIndex].length, (charIndex) {
        final symbol = templates[rowIndex][charIndex];
        return KeyEntity(
          name: names[rowIndex][charIndex],
          insert: symbol.insert,
          closing: symbol.closing,
        );
      });
    });
  }

  List<List<KeyEntity>> get arabicLayout =>
      buildLayout(arabicNames, symbolsTemplate);
  List<List<KeyEntity>> get englishLayout =>
      buildLayout(englishNames, symbolsTemplate);

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
