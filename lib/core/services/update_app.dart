import "dart:convert";
import "package:flutter/material.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:package_info_plus/package_info_plus.dart";
import "package:http/http.dart" as http;
import "package:ota_update/ota_update.dart";
import "package:taif/core/theme/Colors.dart";
import "package:taif/core/theme/Text.dart";
import "package:taif/core/widgets/custom_bottom_sheet.dart";

String repoName = "iskepr/TaifIDE";
String appName = "app.apk";

Future<void> checkUpdate(BuildContext context) async {
  try {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String currentVersion = packageInfo.version;

    final response = await http.get(
      Uri.parse("https://api.github.com/repos/$repoName/releases/latest"),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final latestVersion = data["tag_name"];

      if (latestVersion != currentVersion) {
        if (!context.mounted) return;
        showModalBottomSheet(
          context: context,
          builder: (context) => CustomBottomSheet(
            padding: EdgeInsets.all(10),
            height: 300,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Icon(
                      LucideIcons.refreshCw,
                      size: 40,
                      color: ThemeColors.foreground,
                    ),
                    Text(
                      "تحديث متاح",
                      style: TextStyle(
                        color: ThemeColors.foreground,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "يوجد تحديث جديد للتطبيق يُفضل تحديث المُحرر لتلقي المميزات الجديدة",
                      textAlign: TextAlign.center,
                      style: ThemeText.title,
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text("من الاصدار $currentVersion إلى $latestVersion"),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                          ThemeColors.foreground,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _runOtaUpdate(
                          context,
                          "https://github.com/$repoName/releases/download/$latestVersion/$appName",
                        );
                      },
                      child: SizedBox(
                        width: double.infinity,
                        child: Center(
                          child: Text(
                            "تحديث وتثبيت",
                            style: TextStyle(
                              color: ThemeColors.background,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: IntrinsicWidth(
                        stepWidth: double.infinity,
                        child: Center(
                          child: Text("ليس الأن", style: ThemeText.title),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }
    }
  } catch (e) {
    print("حديث خطأ: $e");
  }
}

void _runOtaUpdate(BuildContext context, String url) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      String statusText = "جاري الاتصال...";
      double progressValue = 0.0;

      return StatefulBuilder(
        builder: (context, setState) {
          if (progressValue == 0.0 && statusText == "جاري الاتصال...") {
            try {
              OtaUpdate()
                  .execute(url, destinationFilename: appName)
                  .listen(
                    (OtaEvent event) {
                      setState(() {
                        if (event.status == OtaStatus.DOWNLOADING) {
                          statusText = "جاري التحميل: ${event.value}%";
                          progressValue =
                              (int.tryParse(event.value ?? "0") ?? 0) / 100;
                        } else if (event.status == OtaStatus.INSTALLING) {
                          statusText = "جاري التثبيت...";
                          progressValue = 1.0;
                          Navigator.pop(context);
                        } else {
                          statusText = event.status.toString();
                        }
                      });
                    },
                    onError: (e) {
                      setState(() {
                        statusText = "فشل التحميل: $e";
                      });
                      Future.delayed(const Duration(seconds: 3), () {
                        if (context.mounted) Navigator.pop(context);
                      });
                    },
                  );
            } catch (e) {
              print("فشل التحميل: $e");
              Navigator.pop(context);
            }
          }

          return AlertDialog(
            title: const Text("تحديث التطبيق"),
            content: Column(
              spacing: 20,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(statusText),
                LinearProgressIndicator(value: progressValue),
              ],
            ),
          );
        },
      );
    },
  );
}
