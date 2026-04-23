import "dart:io";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:path_provider/path_provider.dart";
import "package:provider/provider.dart";
import "package:shared_preferences/shared_preferences.dart";
import "../../constants.dart";
import "../../data/ide_data.dart";

Future<void> setupAlif(BuildContext context) async {
  final data = Provider.of<IdeData>(context, listen: false);
  const alifVersion = IdeData.alifVersion;

  try {
    final prefs = await SharedPreferences.getInstance();
    final installedVersion = prefs.getString("alif_version") ?? "";
    final bool needsUpdate = installedVersion != alifVersion;
    final String updateMessage =
        "${l10n.successUpdateAlifVersionFrom} $installedVersion ${l10n.to} $alifVersion";

    final appDir = await getApplicationSupportDirectory();
    final alifDir = Directory("${appDir.path}/alif");
    final libDir = Directory("${alifDir.path}/library");

    if (needsUpdate && await alifDir.exists()) {
      await alifDir.delete(recursive: true);
    }

    if (!await alifDir.exists()) await alifDir.create(recursive: true);
    if (!await libDir.exists()) await libDir.create(recursive: true);

    String finalPath = "";
    final List<String> filesToCopy = [
      "aliflang/library/التبادل.aliflib",
      "aliflang/library/العشوائي.aliflib",
      "aliflang/library/نظام_التشغيل.aliflib",
    ];

    if (Platform.isAndroid) {
      filesToCopy.addAll([
        "aliflang/arm64-v8a/libalif.so",
        "aliflang/arm64-v8a/libc++_shared.so",
      ]);
      finalPath = "${alifDir.path}/libalif.so";
    } else if (Platform.isLinux) {
      filesToCopy.add("aliflang/linux/amd64");
      finalPath = "${alifDir.path}/amd64";
    } else {
      return;
    }

    if (needsUpdate) {
      await Future.wait(
        filesToCopy.map((fileName) async {
          final assetData = await rootBundle.load("assets/$fileName");
          final bytes = assetData.buffer.asUint8List();

          final isLibraryFile = fileName.endsWith(".aliflib");
          final targetPath = isLibraryFile
              ? "${libDir.path}/${fileName.split('/').last}"
              : "${alifDir.path}/${fileName.split('/').last}";

          await File(targetPath).writeAsBytes(bytes, flush: true);
        }),
      );

      if (Platform.isLinux) await Process.run("chmod", ["+x", finalPath]);

      await prefs.setString("alif_version", alifVersion);
      if (installedVersion.isNotEmpty) data.addOutput(updateMessage);
    }

    if (finalPath.isNotEmpty) {
      data.setAlifPath(finalPath);
      data.addOutput("${l10n.successInstallAlifVersion} $alifVersion");
    }
  } catch (e, s) {
    data.addOutput("$e", isError: true);
    debugPrint("خطأ: $e\n$s");
  }
}
