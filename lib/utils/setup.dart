import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:taif/core/data/ideData.dart';

Future<void> setupAlif(BuildContext context) async {
  final data = Provider.of<IdeData>(context, listen: false);
  try {
    final appDir = await getApplicationSupportDirectory();
    final alifDir = Directory('${appDir.path}/alif');
    Directory libDir = Directory('');

    if (Platform.isAndroid) {
      if (!await alifDir.exists()) await alifDir.create(recursive: true);
      final arm64Dir = Directory('${alifDir.path}/arm64-v8a');
      libDir = Directory('${alifDir.path}/library');

      if (!await arm64Dir.exists()) await arm64Dir.create(recursive: true);
      if (!await libDir.exists()) await libDir.create(recursive: true);

      final filesToCopy = [
        'aliflang/arm64-v8a/libalif.so',
        'aliflang/arm64-v8a/libc++_shared.so',
        'aliflang/library/التبادل.aliflib',
        'aliflang/library/نظام_التشغيل.aliflib',
      ];

      for (final fileName in filesToCopy) {
        final data = await rootBundle.load('assets/$fileName');
        final bytes = data.buffer.asUint8List();
        final targetPath = fileName.contains('arm64-v8a')
            ? '${arm64Dir.path}/${fileName.split('/').last}'
            : '${libDir.path}/${fileName.split('/').last}';
        final file = File(targetPath);
        await file.writeAsBytes(bytes, flush: true);
      }

      data.setAlifPath('${arm64Dir.path}/libalif.so');
    } else if (Platform.isLinux) {
      final langDir = Directory('${alifDir.path}/lang');
      if (!await langDir.exists()) await langDir.create(recursive: true);
      final libraryDir = Directory('${langDir.path}/library');
      if (!await libraryDir.exists()) await libraryDir.create(recursive: true);

      final filesToCopy = [
        'aliflang/linux/amd64',
        'aliflang/library/التبادل.aliflib',
        'aliflang/library/نظام_التشغيل.aliflib',
      ];

      if (!File("${langDir.path}/amd64").existsSync()) {
        for (final fileName in filesToCopy) {
          final data = await rootBundle.load('assets/$fileName');
          final bytes = data.buffer.asUint8List();

          final targetPath = fileName.contains('linux')
              ? '${langDir.path}/${fileName.split('/').last}'
              : '${libraryDir.path}/${fileName.split('/').last}';

          final file = File(targetPath);
          await file.writeAsBytes(bytes, flush: true);
        }
      }

      data.setAlifPath('${langDir.path}/amd64');
    } else {
      data.addOutput("$appDir \n $alifDir");
    }
    data.addOutput("تم تحميل لغة ألف اصدار 5.1.0");
  } catch (e, s) {
    data.addOutput("خطأ أثناء تجهيز ملفات لغة ألف: $e\n$s");
  }
}
