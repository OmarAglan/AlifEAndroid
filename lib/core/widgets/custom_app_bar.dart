import "dart:io";

import "package:flutter/material.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:provider/provider.dart";

import "../../constants.dart";
import "../../data/ide_data.dart";
import "../../features/settings/view/settings_view.dart";
import "../../features/terminal/view/terminal_view.dart";
import "../services/files/create_file.dart";
import "../services/files/open_file.dart";
import "../services/files/save_file.dart";
import "../../features/terminal/functions/run_command.dart";
import "../theme/colors.dart";
import "../theme/text.dart";
import "../utils/file_picker.dart";
import "show_bottom_sheet.dart";

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key});

  Future<void> openFileFromStorage(BuildContext context) async {
    final data = Provider.of<IdeData>(context, listen: false);
    try {
      showFileManagerModal(
        context,
        (selectedPath) async {
          final file = File(selectedPath);
          final code = await file.readAsString();
          final fileName = selectedPath.split(Platform.pathSeparator).last;

          final existingIndex = data.files.indexWhere(
            (f) => f.path == selectedPath,
          );

          if (!context.mounted) return;
          if (existingIndex >= 0) {
            openFile(existingIndex, context);
          } else {
            createFile(
              name: fileName,
              path: selectedPath,
              code: code,
              context: context,
            );
          }
        },
        onFolderSelected: (folderPath) {
          data.setWorkspacePath(folderPath);
        },
      );
    } catch (e) {
      data.addOutput("خطأ أثناء الفتح: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: kMediumPadding,
              right: kMediumPadding,
              left: kMediumPadding,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    showMyBottomSheet(
                      context: context,
                      child: const SettingsView(),
                    );
                  },
                  child: Text(l10n.title, style: ThemeText.title),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        LucideIcons.terminal,
                        color: context.foreground,
                        size: kLargeFont,
                      ),
                      onPressed: () => showTerminalView(context),
                    ),
                    IconButton(
                      icon: Icon(
                        LucideIcons.play,
                        color: context.foreground,
                        size: kLargeFont,
                      ),
                      onPressed: () => {
                        context.read<IdeData>().clearOutput(),
                        runCommand(context, kAlifBin),
                        showTerminalView(context),
                      },
                    ),

                    IconButton(
                      icon: Icon(
                        LucideIcons.save,
                        color: context.foreground,
                        size: kLargeFont,
                      ),
                      onPressed: () => saveFileToStorage(context),
                      onLongPress: () =>
                          saveFileToStorage(context, asNew: true),
                    ),
                    IconButton(
                      icon: Icon(
                        LucideIcons.folderOpen,
                        color: context.foreground,
                        size: kLargeFont,
                      ),
                      onPressed: () => openFileFromStorage(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
