import "package:provider/provider.dart";
import "package:taif/core/widgets/custom_bottom_sheet.dart";
import "package:taif/data/ide_data.dart";
import "package:taif/core/theme/Colors.dart";
import "package:taif/core/theme/Text.dart";
import "package:taif/features/settings/view/widgets/about.dart";
import "package:taif/generated/l10n.dart";
import "package:flutter/material.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:input_quantity/input_quantity.dart";

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<IdeData>(context, listen: false);
    final txt = S.of(context);

    return CustomBottomSheet(
      padding: const EdgeInsets.all(10),
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    txt.settings,
                    style: TextStyle(
                      color: ThemeColors.foreground,
                      fontSize: 25,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Icon(
                    LucideIcons.settings,
                    color: ThemeColors.foreground,
                    size: 25,
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  spacing: 10,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(txt.fontSize, style: ThemeText.title),
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
                            decoration: QtyDecorationProps(
                              border: InputBorder.none,
                            ),
                            onQtyChanged: (val) async {
                              double newSize;
                              if (val is num) {
                                newSize = val.toDouble();
                              } else {
                                final parsed = double.tryParse(val.toString());
                                if (parsed == null) return;
                                newSize = parsed;
                              }
                              data.setFontSize(newSize);
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(txt.autoSave, style: ThemeText.title),
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
          ),
          const About(),
        ],
      ),
    );
  }
}
