import "package:flutter/material.dart";
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
  final List<List<ShortcutsEntity>> arabicLayout = [
    [
      ShortcutsEntity(name: "ج", insert: "[", closing: "]"),
      ShortcutsEntity(name: "ح", insert: "]"),
      ShortcutsEntity(name: "خ", insert: "{", closing: "}"),
      ShortcutsEntity(name: "ه", insert: "}"),
      ShortcutsEntity(name: "ع"),
      ShortcutsEntity(name: "غ"),
      ShortcutsEntity(name: "ف"),
      ShortcutsEntity(name: "ق"),
      ShortcutsEntity(name: "ث"),
      ShortcutsEntity(name: "ص"),
      ShortcutsEntity(name: "ض"),
    ],
    [
      ShortcutsEntity(name: "ط", insert: "|"),
      ShortcutsEntity(name: "ك", insert: "'", closing: "'"),
      ShortcutsEntity(name: "م", insert: '"', closing: '"'),
      ShortcutsEntity(name: "ن", insert: "="),
      ShortcutsEntity(name: "ت", insert: "=="),
      ShortcutsEntity(name: "ا", insert: "!="),
      ShortcutsEntity(name: "ل", insert: "%"),
      ShortcutsEntity(name: "ب", insert: "&&"),
      ShortcutsEntity(name: "ي", insert: "\\س"),
      ShortcutsEntity(name: "س", insert: "/"),
      ShortcutsEntity(name: "ش", insert: "\\"),
    ],
    [
      ShortcutsEntity(name: "د", insert: "+"),
      ShortcutsEntity(name: "ظ", insert: "-"),
      ShortcutsEntity(name: "ز", insert: "_"),
      ShortcutsEntity(name: "و", insert: "<"),
      ShortcutsEntity(name: "ة", insert: ">"),
      ShortcutsEntity(name: "ى", insert: "ئ"),
      ShortcutsEntity(name: "ر", insert: "~"),
      ShortcutsEntity(name: "ؤ", insert: "`", closing: "`"),
      ShortcutsEntity(name: "ء", insert: "\"", closing: "\""),
      ShortcutsEntity(name: "ذ", insert: "?"),
    ],
  ];

  final List<List<ShortcutsEntity>> englishLayout = [
    [
      ShortcutsEntity(name: "q", insert: "1"),
      ShortcutsEntity(name: "w", insert: "2"),
      ShortcutsEntity(name: "e", insert: "3"),
      ShortcutsEntity(name: "r", insert: "4"),
      ShortcutsEntity(name: "t", insert: "5"),
      ShortcutsEntity(name: "y", insert: "6"),
      ShortcutsEntity(name: "u", insert: "7"),
      ShortcutsEntity(name: "i", insert: "8"),
      ShortcutsEntity(name: "o", insert: "9"),
      ShortcutsEntity(name: "p", insert: "0"),
    ],
    [
      ShortcutsEntity(name: "a", insert: "@"),
      ShortcutsEntity(name: "s", insert: "#"),
      ShortcutsEntity(name: "d", insert: "\$"),
      ShortcutsEntity(name: "f", insert: "_"),
      ShortcutsEntity(name: "g", insert: "&"),
      ShortcutsEntity(name: "h", insert: "-"),
      ShortcutsEntity(name: "j", insert: "+"),
      ShortcutsEntity(name: "k", insert: "(", closing: ")"),
      ShortcutsEntity(name: "l", insert: ")"),
    ],
    [
      ShortcutsEntity(name: "z", insert: "*"),
      ShortcutsEntity(name: "x", insert: "\"", closing: "\""),
      ShortcutsEntity(name: "c", insert: "'", closing: "'"),
      ShortcutsEntity(name: "v", insert: ":"),
      ShortcutsEntity(name: "b", insert: ";"),
      ShortcutsEntity(name: "n", insert: "!"),
      ShortcutsEntity(name: "m", insert: "?"),
    ],
  ];

  void insertEntity(BuildContext context, ShortcutsEntity shortcut) {
    final workspace = context.read<WorkspaceProvider>();
    final controller = workspace.codeController;
    final selection = controller.selection;

    if (shortcut.closing != null) {
      if (selection.start != selection.end) {
        // تحويط النص المحدد
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
      } else {
        // اضافة مكان المؤشر فتح واغلاق
        controller.insertAtCurrentCursor(shortcut.insert + shortcut.closing!);
        final currentOffset = controller.selection.extentOffset;
        controller.selection = TextSelection.collapsed(
          offset: currentOffset - shortcut.closing!.length,
        );
      }
    } else {
      if (selection.start != selection.end) {
        // تبديل النص المحدد
        controller.replaceRange(
          selection.start,
          selection.end,
          shortcut.insert,
        );
      } else {
        // اضافة مكان المؤشر
        controller.insertAtCurrentCursor(shortcut.insert);
      }
    }
  }

  void deleteFunc(BuildContext context) {
    final workspace = context.read<WorkspaceProvider>();
    final controller = workspace.codeController;

    final selection = controller.selection;
    final text = controller.text;

    if (selection.start != selection.end) {
      controller.replaceRange(selection.start, selection.end, "");
      return;
    }

    if (selection.start > 0) {
      bool deletedPair = false;

      if (selection.start < text.length) {
        final charBefore = text.substring(selection.start - 1, selection.start);
        final charAfter = text.substring(selection.start, selection.start + 1);

        const pairs = {
          "(": ")",
          "{": "}",
          "[": "]",
          "<": ">",
          '"': '"',
          "'": "'",
          "`": "`",
        };

        // اذا الحرف الذي قبل المؤشر له قفلة مطابقة للي بعد المؤشر
        if (pairs.containsKey(charBefore) && pairs[charBefore] == charAfter) {
          controller.replaceRange(selection.start - 1, selection.start + 1, "");
          deletedPair = true;
        }
      }

      if (!deletedPair) {
        controller.replaceRange(selection.start - 1, selection.start, "");
      }
    }
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
