import "dart:io";
import "package:flutter/material.dart";
import "package:path_provider/path_provider.dart";
import "package:provider/provider.dart";
import "../../constants.dart";
import "../../data/ide_data.dart";

Future<void> runCommand(BuildContext context, String commandInput) async {
  final data = Provider.of<IdeData>(context, listen: false);

  if (commandInput.trim().isEmpty) return;

  final command = commandInput.split(" ").map((c) => c.trim()).toList();
  final bool isAlif = command[0] == "alif" || command[0] == "الف";

  final file = data.selectedFile;
  data.startNewTerminalSession();

  if (data.runningProcess?.exitCode != null) {
    data.clearRunningProcess();
    data.addOutput("\n ---");
    return;
  }

  if (isAlif && data.alifBinPath == null) {
    data.addOutput("لم يتم العثور على اللغة", isError: true);
    return;
  }

  try {
    late File codePath;
    Directory? userDir;

    if (isAlif) {
      final aliflang = File(data.alifBinPath!);

      if (!await aliflang.exists()) {
        data.addOutput("لم يتم العثور على ملف اللغة", isError: true);
        return;
      }
      await Process.run("chmod", ["755", aliflang.path]);

      final appDir = await getApplicationSupportDirectory();
      userDir = Directory("${appDir.path}/المستخدم");
      if (!await userDir.exists()) await userDir.create(recursive: true);
      await Process.run("chmod", ["755", userDir.path]);
    }

    final bool isSaved = file.path != null && file.path!.isNotEmpty;

    if (isSaved) {
      codePath = File(file.path!);
      final fileContent = await codePath.readAsString();
      if (fileContent != file.code) {
        data.addOutput("لم يتم حفظ التعديلات الاخيرة", isError: false);
      }
    } else {
      final tempDir = await getTemporaryDirectory();
      final fileName = (file.name.isNotEmpty) ? file.name : "ملف_مؤقت.الف";
      codePath = File("${tempDir.path}/$fileName");
      await codePath.writeAsString(file.code);
    }

    String firstC;
    final List<String> processArguments = [];
    String? libDir;

    if (isAlif) {
      libDir = data.alifBinPath!.replaceAll("/libalif.so", "");
      if (Platform.isAndroid) {
        firstC = "/system/bin/linker64";
        processArguments.add(data.alifBinPath!);
      } else {
        firstC = data.alifBinPath!;
      }

      if (command.length > 1 && command[1] == "ملف") {
        processArguments.add(codePath.path);
      } else if (command.length > 1) {
        processArguments.addAll(command.sublist(1));
      }
    } else {
      firstC = command[0];
      if (command.length > 1) {
        processArguments.addAll(command.sublist(1));
      }
    }

    final String outputCommandName = (command.length > 1 && command[1] == "ملف")
        ? file.name
        : (command.length > 1 ? command[1] : "");

    data.addOutput(
      "~ >  ${isAlif ? "الف $outputCommandName" : [firstC, ...processArguments].join(" ")}",
    );

    final process = await Process.start(
      firstC,
      processArguments,
      environment: (isAlif && Platform.isAndroid && libDir != null)
          ? {"LD_LIBRARY_PATH": libDir}
          : {},
      workingDirectory: isAlif ? File(file.path!).parent.path : kHomeDir,
    );

    data.editProcess(process);
    process.stderr.transform(const SystemEncoding().decoder).listen((result) {
      data.addOutput(
        result.trim(),
        isError: !result.toLowerCase().contains("warning"),
      );
    });
    process.stdout.transform(const SystemEncoding().decoder).listen((result) {
      data.terminalFocus.requestFocus();
      final lines = result.trim().split("\n");
      if (lines.isNotEmpty && lines.last.isNotEmpty) {
        data.updateTerminalHint(lines.last.replaceAll(":", ""));
      }
      data.addOutput(result, newLine: false);
    });
    process.exitCode.then((exitCode) {
      if (exitCode != 0) {
        data.addOutput("في الشفرة [رقم $exitCode]", isError: true);
      }
      data.clearRunningProcess();
      data.updateTerminalHint(null);
    });
  } catch (e, s) {
    debugPrint("استثناء: $e\n$s");
    data.addOutput("استثناء أثناء التشغيل: $e");
    data.clearRunningProcess();
  }
}
