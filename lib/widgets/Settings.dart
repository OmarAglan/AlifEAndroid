import 'package:provider/provider.dart';
import 'package:taif/core/data/ideData.dart';
import 'package:taif/core/theme/Colors.dart';
import 'package:taif/core/theme/Text.dart';
import 'package:taif/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:input_quantity/input_quantity.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<IdeData>(context, listen: false);
    final texts = S.of(context);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              texts.settings,
              style: TextStyle(color: ThemeColors.foreground, fontSize: 25),
            ),
            const SizedBox(width: 5),
            Icon(LucideIcons.settings, color: ThemeColors.foreground, size: 25),
          ],
        ),
        Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(texts.fontSize, style: ThemeText.title),
                      const SizedBox(width: 5),
                      Text("(15)", style: ThemeText.smallG),
                    ],
                  ),
                  ScaleTransition(
                    scale: AlwaysStoppedAnimation(1.1),
                    child: InputQty(
                      initVal: data.fontSize,
                      maxVal: 50,
                      minVal: 10,
                      steps: 1,
                      qtyFormProps: QtyFormProps(
                        style: TextStyle(color: ThemeColors.foreground),
                        enableTyping: false,
                      ),
                      decoration: QtyDecorationProps(border: InputBorder.none),
                      onQtyChanged: (val) async {
                        int newSize;
                        if (val is num) {
                          newSize = val.toInt();
                        } else {
                          final parsed = int.tryParse(val.toString());
                          if (parsed == null) return;
                          newSize = parsed;
                        }
                        data.setFontSize(newSize);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(texts.autoSave, style: ThemeText.title),
                  Consumer<IdeData>(
                    builder: (context, data, child) => Switch(
                      value: data.autoSave,
                      onChanged: (value) => data.setAutoSave(value),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
