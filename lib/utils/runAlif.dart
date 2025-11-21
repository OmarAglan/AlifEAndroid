import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:taif/core/data/ideData.dart';

Future<void> runAlifCode(BuildContext context) async {
  final data = Provider.of<IdeData>(context, listen: false);

  final file = data.selectedFile;
  final alifBinPath = data.alifBinPath!;
  if (alifBinPath == null) {
    data.addOutput("خطأ: لغة ألف ليست متاحة\n");
    return;
  }

  try {
    final aliflang = File(alifBinPath);

    if (Platform.isAndroid) {
      var status = await Permission.manageExternalStorage.status;
      await Process.run('chmod', ['755', aliflang.path]);
      final libDir = alifBinPath.replaceAll('/libalif.so', '');

      final isNotSaved = status.isDenied || file.path == "";
      var codePath = File("/");

      if (isNotSaved) {
        var tempDir = await getTemporaryDirectory();
        codePath = File('${tempDir.path}/${file.name}');
        await codePath.writeAsString(file.code);
      } else {
        codePath = File(file.path);
        final fileContent = await codePath.readAsString();
        if (fileContent != file.code) {
          data.addOutput("تحذير: لم يتم حفظ التعديلات الاخيرة ⚠️");
        }
      }

      final process = await Process.start(
        "/system/bin/linker64",
        [aliflang.path, codePath.path],
        environment: {'LD_LIBRARY_PATH': libDir},
      );
      data.editProcess(process);
      process.stdout.transform(SystemEncoding().decoder).listen((result) {
        data.addOutput(result);
      });
      process.stderr.transform(SystemEncoding().decoder).listen((result) {
        if (!result.toLowerCase().contains("warning")) {
          data.addOutput("خطأ: $result");
        }
      });
      process.exitCode.then((exitCode) {
        if (exitCode != 0) {
          data.addOutput("حدث خطأ في الشفرة\n[رقم $exitCode]\n");
        }
      });
    } else if (Platform.isLinux) {
      await Process.run('chmod', ['+x', aliflang.path]);

      final isSaved = file.path != "";
      late File codePath;

      if (isSaved) {
        codePath = File(file.path);
        final fileContent = await codePath.readAsString();
        if (fileContent != file.code) {
          data.addOutput(
            "تَحْذِير: لَمْ تَتِمّ حِفْظ التَّعْدِيلات الأَخِيرَة",
          );
        }
      }

      final process = await Process.start(aliflang.path, [
        isSaved ? "" : "-ص",
        isSaved ? codePath.path : file.code.toString(),
      ]);
      data.editProcess(process);

      process.stdout.transform(SystemEncoding().decoder).listen((result) {
        data.addOutput(result);
      });

      process.stderr.transform(SystemEncoding().decoder).listen((result) {
        if (!result.toLowerCase().contains("warning")) {
          data.addOutput("خَطَأ: $result");
        }
      });

      process.exitCode.then((exitCode) {
        if (exitCode != 0) {
          data.addOutput("حَدَثَ خَطَأ فِي الشَّفْرَة\n[رَقْم $exitCode]");
        }
      });
    } else {
      data.addOutput("النظام غير مدعوم");
    }
  } catch (e, s) {
    data.addOutput("استثناء أثناء التشغيل: $e\n$s");
  }
}
