import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:taif/data/ide_data.dart';

Future<void> runCommand(BuildContext context, String commandInput) async {
  final data = Provider.of<IdeData>(context, listen: false);

  final command = commandInput.split(" ").map((c) => c.trim()).toList();
  final bool isAlif = command[0] == 'alif' || command[0] == 'الف';

  final file = data.selectedFile;
  final alifBinPath = data.alifBinPath!;

  try {
    final aliflang = File(alifBinPath);
    await Process.run('chmod', ['755', aliflang.path]);

    final appDir = await getApplicationSupportDirectory();
    final userDir = Directory('${appDir.path}/المستخدم');
    if (!await userDir.exists()) await userDir.create(recursive: true);
    await Process.run("chmod", ["755", userDir.path]);

    late File codePath;
    final isSaved = file.path != "";
    if (isSaved) {
      codePath = File(file.path!);
      final fileContent = await codePath.readAsString();
      if (fileContent != file.code) {
        data.addOutput("تَحْذِير: لَمْ تَتِمّ حِفْظ التَّعْدِيلات الأَخِيرَة");
      }
    } else {
      var tempDir = await getTemporaryDirectory();
      codePath = File('${tempDir.path}/${file.name}');
      await codePath.writeAsString(file.code);
    }

    final libDir = alifBinPath.replaceAll('/libalif.so', '');
    String firstC;
    final List<String> processArguments = [];

    if (isAlif) {
      if (Platform.isAndroid) {
        firstC = "/system/bin/linker64";
        processArguments.add(aliflang.path);
      } else {
        firstC = aliflang.path;
      }
    } else {
      firstC = command[0];
    }

    if (isAlif && command.length == 1) {
      processArguments.add(codePath.path);
    } else {
      processArguments.addAll(command.sublist(1));
    }

    data.addOutput(
      "~ > ${isAlif ? "الف ${data.selectedFile.name}" : [firstC, ...processArguments].join(" ")}",
    );

    print(firstC);
    print(processArguments);

    final process = await Process.start(
      firstC,
      processArguments,
      environment: Platform.isAndroid ? {'LD_LIBRARY_PATH': libDir} : {},
      workingDirectory: isAlif ? null : userDir.path,
    );

    data.editProcess(process);
    process.stdout.transform(SystemEncoding().decoder).listen((result) {
      data.addOutput(result, newLine: false);
    });
    process.stderr.transform(SystemEncoding().decoder).listen((result) {
      if (!result.toLowerCase().contains("warning")) {
        data.addOutput("خَطَأ: $result");
      }
      data.clearRunningProcess();
    });
    process.exitCode.then((exitCode) {
      if (exitCode != 0) {
        data.addOutput("حَدَثَ خَطَأ فِي الشَّفْرَة\n[رَقْم $exitCode]");
      }
      data.clearRunningProcess();
    });
  } catch (e, s) {
    data.addOutput("استثناء أثناء التشغيل: $e\n$s");
  }
}
