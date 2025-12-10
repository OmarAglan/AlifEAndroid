import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taif/data/ide_data.dart';
import 'package:taif/core/services/files/load_saved_files.dart';

import 'package:taif/core/services/premissions.dart';
import 'package:taif/core/utils/setup.dart';
import 'package:taif/core/widgets/custom_app_bar.dart';
import 'package:taif/features/editor/view/widgets/ide.dart';
import 'package:taif/features/editor/view/widgets/opened_files.dart';
import 'package:taif/features/shortcuts/view/shortcuts_view.dart';

class EditorView extends StatefulWidget {
  const EditorView({super.key});

  @override
  State<EditorView> createState() => _EditorViewState();
}

class _EditorViewState extends State<EditorView> {
  @override
  void initState() {
    super.initState();
    final ideData = Provider.of<IdeData>(context, listen: false);
    init(context, ideData);
    ideData.setReady();
  }

  void init(BuildContext context, IdeData ideData) async {
    await loadFilesFromStorage(context, ideData);
    await _loadSavedSettings(ideData);
    await requestStoragePermission(context);
    await setupAlif(context);
  }

  Future<void> _loadSavedSettings(data) async {
    final prefs = await SharedPreferences.getInstance();
    final savedFontSize = prefs.getInt('EditorFontSize');
    if (savedFontSize != null) data.setFontSize(savedFontSize);
    final savedAutoSave = prefs.getBool('EditorAutoSave');
    if (savedAutoSave != null) data.setAutoSave(savedAutoSave);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/Background.webp"),
            fit: BoxFit.cover,
            alignment: Alignment.topLeft,
          ),
        ),
        child: Column(
          spacing: 1,
          children: [CustomAppBar(), OpenedFiles(), IDE(), ShortcutsView()],
        ),
      ),
    );
  }
}
