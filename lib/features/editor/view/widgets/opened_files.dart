import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "../../../../constants.dart";
import "../../../../core/services/files/create_file.dart";
import "../../../../core/services/files/open_file.dart";
import "../../../../core/widgets/radio_input.dart";
import "../../../../core/widgets/show_bottom_sheet.dart";
import "../../../../data/ide_data.dart";
import "edit_sheet.dart";

class OpenedFiles extends StatelessWidget {
  const OpenedFiles({super.key});

  void onLongPress(BuildContext context, dynamic id) {
    showMyBottomSheet(
      context: context,
      child: EditSheet(id: id as int),
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
                name: file.name + (!file.saved ? "*" : ""),
              );
            }).toList(),
            onAdd: () => createFile(context: context),
            // onOpen: () {},
            onLongPress: (id) => onLongPress(context, id),
            onChanged: (id) => openFile(id as int, context),
          );
        },
      ),
    );
  }
}
