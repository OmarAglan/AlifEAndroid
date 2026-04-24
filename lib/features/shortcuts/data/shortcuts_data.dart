import "dart:convert";
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:shared_preferences/shared_preferences.dart";
import "../../../constants.dart";
import "../../../core/providers/workspace_provider.dart";

class ShortcutsProvider extends ChangeNotifier {
  late SharedPreferences prefs;

  ShortcutsProvider() {
    _initShortcuts();
  }

  List<ShortcutsEntity> shortcuts = [];

  final List<ShortcutsEntity> _defaultShortcuts = [
    ShortcutsEntity(id: 1, name: "↹", insert: kCodeSpace),
    ShortcutsEntity(id: 2, name: "(", closing: ")"),
    ShortcutsEntity(id: 3, name: '"', closing: '"'),
    ShortcutsEntity(id: 4, name: "'", closing: "'"),
    ShortcutsEntity(id: 5, name: "="),
    ShortcutsEntity(id: 6, name: ":"),
    ShortcutsEntity(id: 7, name: "-"),
    ShortcutsEntity(id: 8, name: "+"),
    ShortcutsEntity(id: 9, name: ")"),
    ShortcutsEntity(id: 10, name: "[", closing: "]"),
    ShortcutsEntity(id: 11, name: "]"),
    ShortcutsEntity(id: 12, name: "{", closing: "}"),
    ShortcutsEntity(id: 13, name: "}"),
    ShortcutsEntity(id: 14, name: "#", closing: ""),
    ShortcutsEntity(id: 15, name: ","),
    ShortcutsEntity(id: 16, name: "\\"),
    ShortcutsEntity(id: 17, name: "*"),
    ShortcutsEntity(id: 18, name: "^"),
    ShortcutsEntity(id: 19, name: "<", closing: ">"),
    ShortcutsEntity(id: 20, name: ">"),
    ShortcutsEntity(id: 21, name: "_"),
    ShortcutsEntity(id: 22, name: "⏎", insert: "\\س"),
  ];

  void _initShortcuts() async {
    prefs = await SharedPreferences.getInstance();
    shortcuts = List.from(_defaultShortcuts);
    final String? savedCounts = prefs.getString(kKeyShortcutsCounts);

    if (savedCounts != null) {
      final Map<String, dynamic> countsMap = jsonDecode(savedCounts);
      for (var item in shortcuts) {
        final String idKey = item.id.toString();
        if (countsMap.containsKey(idKey)) item.usageCount = countsMap[idKey];
      }
    }

    _sortShortcuts();
    notifyListeners();
  }

  void insertText(BuildContext context, int index) {
    final workspace = context.read<WorkspaceProvider>();
    final controller = workspace.codeController;
    final shortcut = shortcuts[index];
    final selection = controller.selection;

    if (shortcut.insert == kCodeSpace) {
      // اضافة المسافة التلقائية
      controller.indent();
    } else if (shortcut.closing != null) {
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

    _updateUsage(index);
  }

  void _updateUsage(int index) {
    shortcuts[index].usageCount++;
    _saveCountsOnly();
  }

  void _sortShortcuts() =>
      shortcuts.sort((a, b) => b.usageCount.compareTo(a.usageCount));

  Future<void> _saveCountsOnly() async {
    final Map<String, int> countsMap = {};
    for (var item in shortcuts) {
      if (item.usageCount > 0) countsMap[item.id.toString()] = item.usageCount;
    }
    await prefs.setString(kKeyShortcutsCounts, jsonEncode(countsMap));
  }
}

class ShortcutsEntity {
  final int id;
  final String name;
  final String insert;
  final String? closing;
  int usageCount;

  ShortcutsEntity({
    required this.id,
    required this.name,
    String? insert,
    this.closing,
    this.usageCount = 0,
  }) : insert = insert ?? name;
}
