import "package:flutter/material.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:provider/provider.dart";
import "package:taif/core/theme/colors.dart";
import "package:taif/core/theme/text.dart";
import "package:taif/core/widgets/custom_bottom_sheet.dart";
import "package:taif/data/ide_data.dart";
import "package:taif/features/editor/view/widgets/sheet_button.dart";
import "package:taif/generated/l10n.dart";

class EditSheet extends StatelessWidget {
  const EditSheet({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<IdeData>(context, listen: false);
    final texts = S.of(context);
    final TextEditingController controller = TextEditingController(
      text: data.files[id].name,
    );
    return CustomBottomSheet(
      padding: const EdgeInsets.all(20),
      child: Column(
        spacing: 16,
        children: [
          Text(texts.editFile, style: ThemeText.title),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: texts.fileName,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.white),
              ),
            ),
          ),
          SelectableText(
            data.files[id].path == ""
                ? texts.noPath
                : data.files[id].path!.replaceAll("/storage/emulated/0", "~"),
            style: const TextStyle(color: Colors.white),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SheetButton(
                title: texts.save,
                color: ThemeColors.background,
                bg: Colors.white,
                icon: LucideIcons.save,
                onTap: () => data.updateFile(
                  context,
                  id,
                  "reName",
                  newName: controller.text,
                ),
              ),
              if (data.files[id].path != "")
                SheetButton(
                  title: texts.close,
                  color: Colors.amber,
                  icon: LucideIcons.x,
                  onTap: () => data.updateFile(context, id, "close"),
                ),
              SheetButton(
                title: texts.delete,
                color: Colors.red,
                icon: LucideIcons.trash,
                onTap: () => data.updateFile(context, id, "delete"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
