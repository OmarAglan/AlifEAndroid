import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taif/core/data/ideData.dart';
import 'package:taif/utils/files/loadSavedFiles.dart';

import 'package:taif/utils/premissions.dart';
import 'package:taif/utils/setup.dart';
import 'package:taif/utils/updateApp.dart';
import 'package:taif/widgets/AppBar.dart';
import 'package:taif/widgets/IDE.dart';
import 'package:taif/widgets/OpenedFiles/openedFiles.dart';
import 'package:taif/widgets/Shortcuts.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await loadFilesFromStorage(context);
      await _loadSavedSettings();
      await requestStoragePermission(context);
      await setupAlif(context);
      await checkUpdate(context);
    });
  }

  Future<void> _loadSavedSettings() async {
    final data = Provider.of<IdeData>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    final savedFontSize = prefs.getInt('EditorFontSize');
    if (savedFontSize != null) data.setFontSize(savedFontSize);
    final savedAutoSave = prefs.getBool('EditorAutoSave');
    if (savedAutoSave != null) data.setAutoSave(savedAutoSave);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          children: [AlifAppBar(), OpenedFiles(), IDE(), KeyShortcuts()],
        ),
      ),
    );
  }
}
