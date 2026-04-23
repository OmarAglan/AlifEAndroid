import "dart:io";
import "package:flutter/material.dart";
import "package:path_provider/path_provider.dart";
import "package:provider/provider.dart";
import "../../../constants.dart";
import "../../../data/ide_data.dart";
import "handle_commands.dart";

Future<void> runCommand(BuildContext context, String commandInput) async {
  final data = Provider.of<IdeData>(context, listen: false);
  final input = commandInput.trim();

  if (input.isEmpty) return;

  if (data.runningProcess?.exitCode != null) {
    data.clearRunningProcess();
    data.addOutput("\n ---");
    return;
  }

  final commandParts = input.split(" ").map((c) => c.trim()).toList();
  final isAlifCommand = commandParts[0] == kAlifBin;

  data.startNewTerminalSession();

  try {
    if (isAlifCommand) {
      await _runAlifCommand(data, commandParts);
    } else {
      await _runGeneralCommand(data, commandParts);
    }
  } catch (e, s) {
    debugPrint("استثناء: $e\n$s");
    data.addOutput("استثناء أثناء التشغيل: $e", isError: true);
    data.clearRunningProcess();
  }
}

Future<void> _runAlifCommand(IdeData data, List<String> commandParts) async {
  final binPath = data.alifBinPath;
  if (binPath == null) {
    data.addOutput("لم يتم العثور على مسار لغة ألف", isError: true);
    return;
  }

  final alifFile = File(binPath);
  if (!await alifFile.exists()) {
    data.addOutput("لم يتم العثور على ملف تشغيل اللغة", isError: true);
    return;
  }

  await _ensureExecutablePermissions(alifFile.path);
  await _prepareUserDirectory();
  final codeFile = await _prepareCodeFile(data);

  final isAndroid = Platform.isAndroid;
  final executable = isAndroid ? kLinkerPath : binPath;
  final libDir = binPath.replaceAll(kLibAlifSuffix, "");

  final List<String> processArgs = [];
  if (isAndroid) processArgs.add(binPath);

  final isFileCommand = commandParts.length == 1 && commandParts[0] == kAlifBin;
  if (isFileCommand) {
    processArgs.add(codeFile.path);
  } else if (commandParts.length > 1) {
    processArgs.addAll(commandParts.sublist(1));
  }

  final workingDir = (data.workspacePath?.isNotEmpty == true)
      ? data.workspacePath!
      : File(codeFile.path).parent.path;

  final outputName = isFileCommand
      ? data.selectedFile.name
      : (commandParts.length > 1 ? commandParts[1] : "");

  final prompt = getPromptPath(data);
  data.addOutput("$prompt > $kAlifBin $outputName");

  final env = isAndroid ? {"LD_LIBRARY_PATH": libDir} : <String, String>{};
  await _executeAndListen(data, executable, processArgs, workingDir, env);
}

Future<void> _runGeneralCommand(IdeData data, List<String> commandParts) async {
  final isBuiltIn = await handleCommands(data, commandParts);
  if (isBuiltIn) return;

  final executable = commandParts[0];
  final processArgs = commandParts.length > 1
      ? commandParts.sublist(1)
      : <String>[];
  final workingDir = (data.workspacePath?.isNotEmpty == true)
      ? data.workspacePath!
      : kHomeDir;

  final prompt = getPromptPath(data);
  data.addOutput("$prompt > ${[executable, ...processArgs].join(" ")}");

  await _executeAndListen(data, executable, processArgs, workingDir, {});
}

Future<File> _prepareCodeFile(IdeData data) async {
  final fileData = data.selectedFile;
  final isSaved = fileData.path?.isNotEmpty == true;

  if (isSaved) {
    final file = File(fileData.path!);
    final content = await file.readAsString();
    if (content != fileData.code) {
      data.addOutput("لم يتم حفظ التعديلات الأخيرة", isError: false);
    }
    return file;
  } else {
    final tempDir = await getTemporaryDirectory();
    final fileName = fileData.name.isNotEmpty ? fileData.name : kTempFileName;
    final tempFile = File("${tempDir.path}/$fileName");
    await tempFile.writeAsString(fileData.code);
    return tempFile;
  }
}

Future<void> _prepareUserDirectory() async {
  final appDir = await getApplicationSupportDirectory();
  final userDir = Directory("${appDir.path}/المستخدم");
  if (!await userDir.exists()) {
    await userDir.create(recursive: true);
  }
  await _ensureExecutablePermissions(userDir.path);
}

Future<void> _ensureExecutablePermissions(String path) async {
  if (Platform.isLinux || Platform.isAndroid || Platform.isMacOS) {
    await Process.run("chmod", ["755", path]);
  }
}

Future<void> _executeAndListen(
  IdeData data,
  String executable,
  List<String> args,
  String workingDir,
  Map<String, String> environment,
) async {
  final process = await Process.start(
    executable,
    args,
    environment: environment,
    workingDirectory: workingDir,
  );

  data.editProcess(process);

  final stderrFuture = process.stderr
      .transform(const SystemEncoding().decoder)
      .forEach((result) {
        data.addOutput(
          result.trim(),
          isError: !result.toLowerCase().contains("warning"),
        );
      });

  final stdoutFuture = process.stdout
      .transform(const SystemEncoding().decoder)
      .forEach((result) {
        data.terminalFocus.requestFocus();
        final lines = result.trim().split("\n");

        if (lines.isNotEmpty &&
            lines.last.isNotEmpty &&
            lines.last.trim().endsWith(":")) {
          data.updateTerminalHint(lines.last.replaceAll(":", "").trim());
        }

        data.addOutput(result, newLine: false);
      });

  await Future.wait([stdoutFuture, stderrFuture]);

  final exitCode = await process.exitCode;
  if (exitCode != 0) {
    data.addOutput("انتهت العملية برمز خطأ [$exitCode]", isError: true);
  }

  data.clearRunningProcess();
}
