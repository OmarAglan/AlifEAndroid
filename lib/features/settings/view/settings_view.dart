import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:input_quantity/input_quantity.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:provider/provider.dart";
import "../../../constants.dart";
import "../../../core/providers/settings_provider.dart";
import "../../../core/theme/colors.dart";
import "../../../core/theme/text.dart";
import "widgets/about.dart";

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Column(
      spacing: kMediumPadding,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(context),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: kSmallPadding),
          child: Column(
            spacing: kMediumPadding,
            children: [
              _buildNumberRow(
                context,
                title: l10n.fontSize,
                subTitle: "($kMediumFont)",
                value: settings.get<double>(AppSetting.fontSize),
                min: 10,
                max: 50,
                onChanged: (val) =>
                    settings.set(AppSetting.fontSize, val.toDouble()),
              ),
              _buildNumberRow(
                context,
                title: "حجم المسافة",
                subTitle: "($kCodeSpaceLength)",
                value: settings.get<int>(AppSetting.tapSize),
                min: 2,
                max: 10,
                onChanged: (val) =>
                    settings.set(AppSetting.tapSize, val.toInt()),
              ),
              ...[
                AppSetting.autoSave,
                AppSetting.enableSuggestions,
                AppSetting.enableFolding,
                AppSetting.lineWrap,
                AppSetting.enableVibration,
                AppSetting.enableVibration,
                AppSetting.customKeyboard,
              ].map((setting) {
                return _buildSwitchRow(
                  context,
                  title: _getSettingTitle(setting),
                  value: settings.get<bool>(setting),
                  onChanged: (val) => settings.set(setting, val),
                );
              }),
            ],
          ),
        ),
        const About(),
      ],
    );
  }

  String _getSettingTitle(AppSetting setting) {
    switch (setting) {
      case AppSetting.autoSave:
        return l10n.autoSave;
      case AppSetting.enableSuggestions:
        return "تفعيل الاقتراحات";
      case AppSetting.enableFolding:
        return "طي الشفرة";
      case AppSetting.lineWrap:
        return "طي الأسطر";
      case AppSetting.enableVibration:
        return "تفعيل الاهتزاز";
      case AppSetting.customKeyboard:
        return "لوحة مفاتيح طيف";
      default:
        return "";
    }
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.settings,
          style: TextStyle(color: context.foreground, fontSize: kSoLargeFont),
        ),
        const SizedBox(width: kSmallPadding),
        Icon(
          LucideIcons.settings,
          color: context.foreground,
          size: kSoLargeFont,
        ),
      ],
    );
  }

  Widget _buildSwitchRow(
    BuildContext context, {
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: ThemeText.title.copyWith(fontWeight: FontWeight.normal),
        ),
        Transform.scale(
          scale: 0.85,
          child: CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeColor: context.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildNumberRow(
    BuildContext context, {
    required String title,
    String? subTitle,
    required dynamic value,
    required num min,
    required num max,
    required Function(num) onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              title,
              style: ThemeText.title.copyWith(fontWeight: FontWeight.normal),
            ),
            if (subTitle != null) ...[
              const SizedBox(width: kSmallPadding),
              Text(subTitle, style: ThemeText.smallG),
            ],
          ],
        ),
        ScaleTransition(
          scale: const AlwaysStoppedAnimation(1.1),
          child: InputQty(
            initVal: value,
            maxVal: max,
            minVal: min,
            steps: 1,
            qtyFormProps: QtyFormProps(
              style: TextStyle(color: context.foreground),
              enableTyping: false,
            ),
            decoration: QtyDecorationProps(
              border: InputBorder.none,
              btnColor: context.text,
            ),
            onQtyChanged: (val) => val != null ? onChanged(val as num) : null,
          ),
        ),
      ],
    );
  }
}
