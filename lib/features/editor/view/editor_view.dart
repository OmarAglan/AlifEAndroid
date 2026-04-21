import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../../../core/services/files/load_saved_files.dart";
import "../../../core/services/premissions.dart";
import "../../../core/utils/setup.dart";
import "../../../core/widgets/custom_app_bar.dart";
import "../../../data/ide_data.dart";
import "../../shortcuts/view/shortcuts_view.dart";
import "widgets/ide.dart";
import "widgets/opened_files.dart";

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      init(context, ideData);
    });
  }

  void init(BuildContext context, IdeData ideData) async {
    await loadFilesFromStorage(context, ideData);
    if (!context.mounted) return;
    await requestStoragePermission(context);
    if (!context.mounted) return;
    await setupAlif(context);
    ideData.setReady();
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
