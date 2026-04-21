import "package:flutter/material.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:url_launcher/url_launcher.dart";

import "../../../../constants.dart";
import "../../../../core/theme/colors.dart";
import "../../../../core/theme/text.dart";
import "../../../../data/ide_data.dart";

class About extends StatelessWidget {
  const About({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(
          spacing: kMediumPadding,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  LucideIcons.cpu,
                  color: context.secondary,
                  size: kSmallFont,
                ),
                const SizedBox(width: kSmallPadding),
                const Text(
                  "لغة ألف نـ5 النسخة ${IdeData.alifVersion}",
                  style: ThemeText.smallG,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  LucideIcons.info,
                  color: context.secondary,
                  size: kSoSmallFont,
                ),
                const SizedBox(width: kSmallPadding),
                const Text(
                  "محرر طيف النسخة ${IdeData.appVersion} (تجريبية)",
                  style: ThemeText.smallG,
                ),
              ],
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              icon: Icon(
                LucideIcons.github,
                color: context.secondary,
                size: 13,
              ),
              onPressed: () =>
                  _launchUrl("https://github.com/iskepr/AlifEAndroid"),
              label: const Text("الشفرة على جيت هاب", style: ThemeText.smallG),
            ),
            TextButton.icon(
              icon: Icon(LucideIcons.earth, color: context.secondary, size: 13),
              onPressed: () =>
                  _launchUrl("https://skepr.vercel.app/?from=TaifIDE"),
              label: const Text("تطـوير محـمـد سكيبر", style: ThemeText.smallG),
            ),
          ],
        ),
      ],
    );
  }
}

Future<void> _launchUrl(String url) async {
  final Uri uri = Uri.parse(url);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    throw Exception("Could not launch $url");
  }
}
