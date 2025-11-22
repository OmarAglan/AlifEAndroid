import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:taif/core/data/ideData.dart';
import 'package:taif/core/theme/Colors.dart';
import 'package:taif/generated/l10n.dart';
import 'package:taif/widgets/BottomSheet.dart';

class Editsheet extends StatelessWidget {
  const Editsheet({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<IdeData>(context, listen: false);
    final texts = S.of(context);
    TextEditingController controller = TextEditingController(
      text: data.files[id]["Name"],
    );
    return MyBottomsheet(
      padding: EdgeInsets.only(
        top: 10,
        right: 10,
        left: 10,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        children: [
          Text(
            texts.editFile,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
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
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SelectableText(
            data.files[id]["Path"] == ""
                ? texts.noPath
                : data.files[id]["Path"]!.replaceAll(
                    RegExp(
                      r'^(/storage/emulated/0|/home/' +
                          Platform.environment['HOME']! +
                          r'/)',
                    ),
                    '~',
                  ),
            style: TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: ThemeColors.foreground,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TextButton.icon(
                  onPressed: () {
                    data.updateFile(
                      context,
                      id,
                      "reName",
                      newName: controller.text,
                    );
                    Navigator.pop(context);
                  },
                  icon: Icon(LucideIcons.save, color: ThemeColors.background),
                  label: Text(
                    texts.save,
                    style: TextStyle(color: ThemeColors.background),
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  data.updateFile(context, id, "close");
                  Navigator.pop(context);
                },
                icon: Icon(LucideIcons.x, color: Colors.amber),
                label: Text(texts.close, style: TextStyle(color: Colors.amber)),
              ),
              TextButton.icon(
                onPressed: () {
                  data.updateFile(context, id, "delete");
                  Navigator.pop(context);
                },
                icon: Icon(LucideIcons.trash, color: Colors.red),
                label: Text(texts.delete, style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
