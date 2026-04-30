import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "../../../../constants.dart";
import "../../../../core/models/data_typs.dart";
import "../../../../core/providers/workspace_provider.dart";
import "../../../../core/services/files/open_file.dart";
import "../../../../core/utils/show_dialog.dart";
import "../../../../core/widgets/radio_input.dart";
import "edit_file_view.dart";

class OpenedFiles extends StatelessWidget {
  const OpenedFiles({super.key});

  void onLongPress(BuildContext context, dynamic id, WorkspaceProvider data) {
    final file = data.files[id];
    final TextEditingController controller = TextEditingController(
      text: file.name,
    );
    showCustomDialog(
      title: l10n.editFile,
      onConfirm: () => data.updateFile(
        context,
        id,
        FileAction.rename,
        newName: controller.text,
      ),
      child: EditSheet(file: file, controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kSmallPadding),
      child: Consumer<WorkspaceProvider>(
        builder: (context, workspce, child) => RadioInput(
          value: workspce.selectedFile.id,
          items: workspce.files.map((file) {
            return SelectEntity(
              value: file.id,
              name:
                  file.name +
                  (file.readOnly ? "!" : "") +
                  (!file.saved ? "*" : ""),
            );
          }).toList(),
          onLongPress: (id) => onLongPress(context, id, workspce),
          onChanged: (id) => openFile(id as int, context),
        ),
      ),
    );
  }
}
