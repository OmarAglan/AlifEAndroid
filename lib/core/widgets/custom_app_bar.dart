import 'dart:io';
import 'package:provider/provider.dart';
import 'package:taif/data/ide_data.dart';
import 'package:taif/core/theme/Colors.dart';
import 'package:taif/core/theme/Text.dart';
import 'package:taif/features/settings/view/settings_view.dart';
import 'package:taif/generated/l10n.dart';
import 'package:taif/features/terminal/view/terminal_view.dart';
import 'package:taif/core/utils/file_picker.dart';
import 'package:taif/core/services/files/create_file.dart';
import 'package:taif/core/services/files/open_file.dart';
import 'package:taif/core/services/files/save_file.dart';
import 'package:taif/core/services/run_command.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key});

  Future<void> openFileFromStorage(BuildContext context) async {
    final data = Provider.of<IdeData>(context, listen: false);
    try {
      showFileManagerModal(context, (selectedPath) async {
        final file = File(selectedPath);
        final code = await file.readAsString();
        final fileName = selectedPath.split(Platform.pathSeparator).last;

        final existingIndex = data.files.indexWhere(
          (f) => f.path == selectedPath,
        );

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
      });
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
            padding: EdgeInsets.only(top: 10, right: 10, left: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => SettingsView(),
                    );
                  },
                  child: Text(S.of(context).title, style: ThemeText.title),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        LucideIcons.terminal,
                        color: ThemeColors.foreground,
                        size: 20,
                      ),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => TerminalView(),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        LucideIcons.play,
                        color: ThemeColors.foreground,
                        size: 20,
                      ),
                      onPressed: () => {
                        context.read<IdeData>().clearOutput(),
                        runCommand(context, "الف ملف"),
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => TerminalView(),
                        ),
                      },
                    ),

                    IconButton(
                      icon: Icon(
                        LucideIcons.save,
                        color: ThemeColors.foreground,
                        size: 20,
                      ),
                      onPressed: () => saveFileToStorage(context),
                      onLongPress: () =>
                          saveFileToStorage(context, asNew: true),
                    ),
                    IconButton(
                      icon: Icon(
                        LucideIcons.folderOpen,
                        color: ThemeColors.foreground,
                        size: 20,
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
