import "package:flutter/material.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:provider/provider.dart";
import "package:taif/core/theme/colors.dart";
import "package:taif/core/theme/text.dart";
import "package:taif/data/ide_data.dart";
import "package:url_launcher/url_launcher.dart";

class About extends StatelessWidget {
  const About({super.key});

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<IdeData>(context, listen: false);
    return Column(
      children: [
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  LucideIcons.cpu,
                  color: ThemeColors.secondary,
                  size: ThemeText.smallF,
                ),
                const SizedBox(width: 5),
                Text(
                  "لغة ألف نـ5 النسخة ${data.alifVersion}",
                  style: ThemeText.smallG,
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.info, color: ThemeColors.secondary, size: 13),
                SizedBox(width: 5),
                Text(
                  "محرر طيف النسخة 1.0.0 (تجريبية)",
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
              icon: const Icon(
                LucideIcons.github,
                color: ThemeColors.secondary,
                size: 13,
              ),
              onPressed: () =>
                  _launchUrl("https://github.com/iskepr/AlifEAndroid"),
              label: const Text("الشفرة على جيت هاب", style: ThemeText.smallG),
            ),
            TextButton.icon(
              icon: const Icon(
                LucideIcons.earth,
                color: ThemeColors.secondary,
                size: 13,
              ),
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
