import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../../../core/providers/workspace_provider.dart";
import "../../../core/services/files/load_saved_files.dart";
import "../../../core/services/premissions.dart";
import "../../../core/utils/setup_alif.dart";
import "../../../core/widgets/custom_app_bar.dart";
import "../../keyboard/view/keyboard_view.dart";
import "../../shortcuts/view/shortcuts_view.dart";
import "widgets/ide_view.dart";
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await loadFilesFromStorage(context);
      await requestStoragePermission();
      if (!mounted) return;
      await setupAlif(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final workspace = context.watch<WorkspaceProvider>();

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/Background.webp"),
            fit: BoxFit.cover,
            alignment: Alignment.topLeft,
          ),
        ),
        child: Column(
          spacing: 1,
          children: [
            const CustomAppBar(),
            const OpenedFiles(),
            const IDEView(),
            SafeArea(
              top: false,
              bottom: !workspace.focusNode.hasFocus,
              child: const Column(children: [ShortcutsView(), KeyboardView()]),
            ),
          ],
        ),
      ),
    );
  }
}
