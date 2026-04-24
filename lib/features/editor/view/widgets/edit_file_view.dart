import "package:flutter/material.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:provider/provider.dart";
import "../../../../constants.dart";
import "../../../../core/services/share_code_image.dart";
import "../../../../core/theme/colors.dart";
import "../../../../core/theme/material.dart";
import "../../../../core/utils/show_dialog.dart";
import "../../../../data/data_types.dart";
import "../../../../data/ide_data.dart";

class EditSheet extends StatelessWidget {
  const EditSheet({super.key, required this.file, required this.controller});

  final FileEntity file;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<IdeData>(context, listen: false);
    final bool hasPath = file.path != null && file.path!.isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: kMediumPadding,
      children: [
        MyMaterial(
          theme: MyMaterialTheme.border,
          child: TextField(
            controller: controller,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: l10n.fileName,
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.all(kMediumPadding),
            ),
          ),
        ),
        SelectableText(
          hasPath ? file.path!.replaceAll(kHomeDir, "~") : l10n.noPath,
          textAlign: TextAlign.center,
          style: TextStyle(color: context.secondary, fontSize: 12),
        ),
        Row(
          spacing: kSmallPadding,
          children: [
            Expanded(
              child: DialogButton(
                title: l10n.delete,
                color: Colors.red,
                icon: LucideIcons.trash,
                onTap: () => showCustomDialog(
                  title: "حذف الملف",
                  subtitle: "هل متاكد من حذف الملف؟",
                  onConfirm: () {
                    data.updateFile(context, file.id, FileAction.delete);
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
            if (hasPath)
              Expanded(
                child: DialogButton(
                  title: "إغلاق",
                  color: Colors.amber,
                  icon: LucideIcons.x,
                  onTap: () {
                    data.updateFile(context, file.id, FileAction.close);
                    Navigator.pop(context);
                  },
                ),
              ),
          ],
        ),
        Row(
          spacing: kSmallPadding,
          children: [
            Expanded(
              child: DialogButton(
                title: file.readOnly ? "للقراءة" : "للكتابة",
                color: file.readOnly ? Colors.red : Colors.green,
                icon: file.readOnly ? LucideIcons.penOff : LucideIcons.pen,
                onTap: () {
                  data.updateFile(context, file.id, FileAction.toggleReadOnly);
                  Navigator.pop(context);
                },
              ),
            ),
            Expanded(
              child: DialogButton(
                title: "مشاركة",
                color: context.text,
                icon: LucideIcons.share,
                onTap: () => ShareAsImageService.shareCodeAsImage(context),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
