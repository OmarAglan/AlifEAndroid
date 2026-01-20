import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taif/data/ide_data.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> setupAlif(BuildContext context) async {
  final data = Provider.of<IdeData>(context, listen: false);

  try {
    final prefs = await SharedPreferences.getInstance();
    final installedVersion = prefs.getString('alif_version') ?? "";

    bool needsUpdate = installedVersion != data.alifVersion;

    final appDir = await getApplicationSupportDirectory();
    final alifDir = Directory('${appDir.path}/alif');

    if (needsUpdate && await alifDir.exists()) {
      await alifDir.delete(recursive: true);
    }

    if (!await alifDir.exists()) await alifDir.create(recursive: true);

    String finalPath = "";

    if (Platform.isAndroid) {
      final arm64Dir = Directory('${alifDir.path}/arm64-v8a');
      final libDir = Directory('${alifDir.path}/library');

      if (!await arm64Dir.exists()) await arm64Dir.create(recursive: true);
      if (!await libDir.exists()) await libDir.create(recursive: true);

      final filesToCopy = [
        'aliflang/arm64-v8a/libalif.so',
        'aliflang/arm64-v8a/libc++_shared.so',
        'aliflang/library/التبادل.aliflib',
        'aliflang/library/نظام_التشغيل.aliflib',
      ];

      if (needsUpdate) {
        for (final fileName in filesToCopy) {
          final assetData = await rootBundle.load('assets/$fileName');
          final bytes = assetData.buffer.asUint8List();
          final targetPath = fileName.contains('arm64-v8a')
              ? '${arm64Dir.path}/${fileName.split('/').last}'
              : '${libDir.path}/${fileName.split('/').last}';
          await File(targetPath).writeAsBytes(bytes, flush: true);
        }
        await prefs.setString('alif_version', data.alifVersion);
        data.addOutput("تم تحديث ملفات اللغة بنجاح");
      }
      finalPath = '${arm64Dir.path}/libalif.so';
    } else if (Platform.isLinux) {
      final langDir = Directory('${alifDir.path}/lang');
      final libraryDir = Directory('${alifDir.path}/library');

      if (!await langDir.exists()) await langDir.create(recursive: true);
      if (!await libraryDir.exists()) await libraryDir.create(recursive: true);

      if (needsUpdate) {
        final filesToCopy = [
          'aliflang/linux/amd64',
          'aliflang/library/التبادل.aliflib',
          'aliflang/library/نظام_التشغيل.aliflib',
        ];
        for (final fileName in filesToCopy) {
          final assetData = await rootBundle.load('assets/$fileName');
          final bytes = assetData.buffer.asUint8List();
          final targetPath = fileName.contains('linux')
              ? '${langDir.path}/${fileName.split('/').last}'
              : '${libraryDir.path}/${fileName.split('/').last}';
          await File(targetPath).writeAsBytes(bytes, flush: true);
        }
        await prefs.setString('alif_version', data.alifVersion);
        data.addOutput("تم تحديث ملفات اللغة بنجاح");
      }
      finalPath = '${langDir.path}/amd64';
    }

    if (finalPath.isNotEmpty) {
      data.setAlifPath(finalPath);
      data.addOutput("تم تثبيت لغة ألف اصدار ${data.alifVersion}");
    }
  } catch (e, s) {
    data.addOutput("حدث خطأ: $e");
    print("خطأ: $e\n$s");
  }
}
