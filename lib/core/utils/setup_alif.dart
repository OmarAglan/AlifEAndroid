import "dart:io";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:path_provider/path_provider.dart";
import "package:provider/provider.dart";
import "package:shared_preferences/shared_preferences.dart";
import "../../constants.dart";
import "../providers/settings_provider.dart";
import "../providers/terminal_provider.dart";

Future<void> setupAlif(BuildContext context) async {
  final terminal = context.read<TerminalProvider>();
  try {
    final prefs = await SharedPreferences.getInstance();
    final installedVersion = prefs.getString(kKeyAlifVersion) ?? "";
    final bool needsUpdate = installedVersion != kAlifVersion;
    final String updateMessage =
        "${l10n.successUpdateAlifVersionFrom} $installedVersion ${l10n.to} $kAlifVersion";

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
        "aliflang/arm64-v8a/alif_lsp",
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

      await prefs.setString(kKeyAlifVersion, kAlifVersion);
      if (installedVersion.isNotEmpty) terminal.addOutput(updateMessage);
    }

    if (finalPath.isNotEmpty) {
      if (!context.mounted) return;
      context.read<SettingsProvider>().setAlifPath(finalPath);
      terminal.addOutput("${l10n.successInstallAlifVersion} $kAlifVersion");
    }
  } catch (e, s) {
    terminal.addOutput("$e", isError: true);
    debugPrint("خطأ: $e\n$s");
  }
}
