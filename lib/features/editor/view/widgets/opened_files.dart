import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:taif/core/services/files/create_file.dart";
import "package:taif/data/ide_data.dart";
import "package:taif/features/editor/view/widgets/custom_tap.dart";
import "package:taif/features/editor/view/widgets/edit_sheet.dart";

class OpenedFiles extends StatelessWidget {
  const OpenedFiles({super.key});

  void onLongPress(BuildContext context, int id) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => EditSheet(id: id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Row(
            children: [
              Consumer<IdeData>(
                builder: (context, data, child) => Row(
                  children: List.generate(data.files.length, (id) {
                    final bool sel = data.selectedFile.id == id;
                    final files = data.files;
                    final bool isNotSaved = !files[id].saved;
                    return CustomTap(
                      id: id,
                      isNotSaved: isNotSaved,
                      name: files[id].name,
                      onLongPress: onLongPress,
                      sel: sel,
                    );
                  }),
                ),
              ),
              IconButton(
                onPressed: () => createFile(context: context),
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
