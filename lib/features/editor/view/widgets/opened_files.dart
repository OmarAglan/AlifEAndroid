import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "../../../../constants.dart";
import "../../../../core/services/files/create_file.dart";
import "../../../../core/services/files/open_file.dart";
import "../../../../core/services/files/open_file_from_storage.dart";
import "../../../../core/utils/show_dialog.dart";
import "../../../../core/widgets/radio_input.dart";
import "../../../../data/ide_data.dart";
import "edit_file_view.dart";

class OpenedFiles extends StatelessWidget {
  const OpenedFiles({super.key});

  void onLongPress(BuildContext context, dynamic id, IdeData data) {
    final file = data.files[id];
    final TextEditingController controller = TextEditingController(
      text: file.name,
    );
    showCustomDialog(
      title: l10n.editFile,
      onConfirm: () =>
          data.updateFile(context, id, "reName", newName: controller.text),
      child: EditSheet(file: file, controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kSmallPadding),
      child: Consumer<IdeData>(
        builder: (context, data, child) {
          return RadioInput(
            value: data.selectedFile.id,
            items: data.files.map((file) {
              return SelectEntity(
                value: file.id,
                name:
                    file.name +
                    (!file.saved ? "*" : "") +
                    (file.readOnly ? "!" : ""),
              );
            }).toList(),
            onAdd: () => createFile(context: context),
            onOpen: data.workspacePath != null
                ? () => openFileFromStorage(
                    context,
                    rootPath: data.workspacePath!,
                    startPath: data.workspacePath,
                  )
                : null,
            onLongPress: (id) => onLongPress(context, id, data),
            onChanged: (id) => openFile(id as int, context),
          );
        },
      ),
    );
  }
}
