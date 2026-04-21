import "package:flutter/material.dart";
import "package:input_quantity/input_quantity.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:provider/provider.dart";
import "../../../constants.dart";
import "../../../core/theme/colors.dart";
import "../../../core/theme/text.dart";
import "../../../core/widgets/custom_bottom_sheet.dart";
import "../../../data/ide_data.dart";
import "widgets/about.dart";

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<IdeData>(context, listen: false);

    return CustomBottomSheet(
      padding: const EdgeInsets.all(kMediumPadding),
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
                    l10n.settings,
                    style: TextStyle(
                      color: context.foreground,
                      fontSize: kSoLargeFont,
                    ),
                  ),
                  const SizedBox(width: kSmallPadding),
                  Icon(
                    LucideIcons.settings,
                    color: context.foreground,
                    size: kSoLargeFont,
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(kMediumPadding),
                child: Column(
                  spacing: kMediumPadding,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(l10n.fontSize, style: ThemeText.title),
                            const SizedBox(width: kSmallPadding),
                            const Text(
                              "($kSmallFont)",
                              style: ThemeText.smallG,
                            ),
                          ],
                        ),
                        ScaleTransition(
                          scale: const AlwaysStoppedAnimation(1.1),
                          child: InputQty(
                            initVal: data.fontSize,
                            maxVal: 50,
                            minVal: 10,
                            steps: 1,
                            qtyFormProps: QtyFormProps(
                              style: TextStyle(color: context.foreground),
                              enableTyping: false,
                            ),
                            decoration: const QtyDecorationProps(
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
                        Text(l10n.autoSave, style: ThemeText.title),
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
