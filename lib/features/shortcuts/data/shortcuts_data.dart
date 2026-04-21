import "dart:convert";
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:shared_preferences/shared_preferences.dart";
import "../../../data/ide_data.dart";

class ShortcutsData extends ChangeNotifier {
  late SharedPreferences prefs;

  ShortcutsData() {
    _initShortcuts();
  }

  List<ShortcutsEntity> shortcuts = [];

  final List<ShortcutsEntity> _defaultShortcuts = [
    ShortcutsEntity(id: 1, name: "↹", insert: "  "),
    ShortcutsEntity(id: 2, name: "("),
    ShortcutsEntity(id: 3, name: '"'),
    ShortcutsEntity(id: 4, name: "'"),
    ShortcutsEntity(id: 5, name: "="),
    ShortcutsEntity(id: 6, name: ":"),
    ShortcutsEntity(id: 7, name: "-"),
    ShortcutsEntity(id: 8, name: "+"),
    ShortcutsEntity(id: 9, name: ")"),
    ShortcutsEntity(id: 10, name: "["),
    ShortcutsEntity(id: 11, name: "]"),
    ShortcutsEntity(id: 12, name: "{"),
    ShortcutsEntity(id: 13, name: "}"),
    ShortcutsEntity(id: 14, name: "#"),
    ShortcutsEntity(id: 15, name: ","),
    ShortcutsEntity(id: 16, name: "\\"),
    ShortcutsEntity(id: 17, name: "*"),
    ShortcutsEntity(id: 18, name: "^"),
    ShortcutsEntity(id: 19, name: "<"),
    ShortcutsEntity(id: 20, name: ">"),
    ShortcutsEntity(id: 21, name: "_"),
    ShortcutsEntity(id: 22, name: "⏎", insert: "\\س"),
  ];

  void _initShortcuts() async {
    prefs = await SharedPreferences.getInstance();

    shortcuts = List.from(_defaultShortcuts);
    final String? savedCounts = prefs.getString("shortcuts_counts");

    if (savedCounts != null) {
      final Map<String, dynamic> countsMap = jsonDecode(savedCounts);
      for (var item in shortcuts) {
        final String idKey = item.id.toString();
        if (countsMap.containsKey(idKey)) {
          item.usageCount = countsMap[idKey];
        }
      }
    }

    _sortShortcuts();
    notifyListeners();
  }

  void insertText(BuildContext context, String value, int index) {
    final ideData = Provider.of<IdeData>(context, listen: false);

    final text = ideData.code.text;
    final selection = ideData.code.selection;

    final newText = text.replaceRange(selection.start, selection.end, value);
    final newPos = selection.start + value.length;

    ideData.code.value = ideData.code.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newPos),
    );

    _updateUsage(index);
  }

  void _updateUsage(int index) {
    shortcuts[index].usageCount++;
    _sortShortcuts();
    _saveCountsOnly();
    notifyListeners();
  }

  void _sortShortcuts() {
    shortcuts.sort((a, b) => b.usageCount.compareTo(a.usageCount));
  }

  Future<void> _saveCountsOnly() async {
    final Map<String, int> countsMap = {};

    for (var item in shortcuts) {
      if (item.usageCount > 0) {
        countsMap[item.id.toString()] = item.usageCount;
      }
    }

    await prefs.setString("shortcuts_counts", jsonEncode(countsMap));
  }
}

class ShortcutsEntity {
  final int id;
  final String name;
  final String insert;
  int usageCount;

  ShortcutsEntity({
    required this.id,
    required this.name,
    String? insert,
    this.usageCount = 0,
  }) : insert = insert ?? name;
}
