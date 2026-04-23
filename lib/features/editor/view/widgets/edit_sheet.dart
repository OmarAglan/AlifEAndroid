import "package:flutter/material.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:provider/provider.dart";
import "../../../../constants.dart";
import "../../../../core/theme/colors.dart";
import "../../../../core/theme/text.dart";
import "../../../../data/ide_data.dart";
import "sheet_button.dart";

class EditSheet extends StatelessWidget {
  const EditSheet({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<IdeData>(context, listen: false);
    final file = data.files[id];

    final TextEditingController controller = TextEditingController(
      text: file.name,
    );

    final bool hasPath = file.path != null && file.path!.isNotEmpty;

    return Column(
      spacing: 16,
      children: [
        Text(l10n.editFile, style: ThemeText.title),
        const SizedBox(height: 16),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: l10n.fileName,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.white),
            ),
          ),
        ),
        SelectableText(
          hasPath ? file.path!.replaceAll(kHomeDir, "~") : l10n.noPath,
          style: const TextStyle(color: Colors.white),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SheetButton(
              title: l10n.save,
              color: context.background,
              bg: Colors.white,
              icon: LucideIcons.save,
              onTap: () {
                data.updateFile(
                  context,
                  id,
                  "reName",
                  newName: controller.text,
                );
                Navigator.pop(context);
              },
            ),
            if (hasPath)
              SheetButton(
                title: l10n.close,
                color: Colors.amber,
                icon: LucideIcons.x,
                onTap: () {
                  data.updateFile(context, id, "close");
                  Navigator.pop(context);
                },
              ),
            SheetButton(
              title: file.readOnly ? "للقرائة فقط" : "للقراءة والكتابة",
              color: file.readOnly ? Colors.red : Colors.green,
              icon: file.readOnly ? LucideIcons.penOff : LucideIcons.pen,
              onTap: () {
                data.updateFile(context, id, "readOnly");
                Navigator.pop(context);
              },
            ),
            SheetButton(
              title: l10n.delete,
              color: Colors.red,
              icon: LucideIcons.trash,
              onTap: () {
                data.updateFile(context, id, "delete");
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ],
    );
  }
}
