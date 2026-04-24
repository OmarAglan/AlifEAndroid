import "dart:io";
import "package:flutter/material.dart";
import "package:path_provider/path_provider.dart";
import "package:provider/provider.dart";

import "../../../constants.dart";
import "../../../core/providers/settings_provider.dart";
import "../../../core/providers/terminal_provider.dart";
import "../../../core/providers/workspace_provider.dart";
import "handle_commands.dart";

Future<void> runCommand(BuildContext context, String commandInput) async {
  final workspace = context.read<WorkspaceProvider>();
  final terminal = context.read<TerminalProvider>();
  final settings = context.read<SettingsProvider>();

  final input = commandInput.trim();

  if (input.isEmpty) return;

  if (terminal.runningProcess?.exitCode != null) {
    terminal.clearRunningProcess();
    terminal.addOutput("\n ---");
    return;
  }

  final commandParts = input.split(" ").map((c) => c.trim()).toList();
  final isAlifCommand = commandParts[0] == kAlifBin;

  terminal.startNewTerminalSession();

  try {
    if (isAlifCommand) {
      await _runAlifCommand(settings, workspace, terminal, commandParts);
    } else {
      await _runGeneralCommand(context, workspace, terminal, commandParts);
    }
  } catch (e, s) {
    debugPrint("استثناء: $e\n$s");
    terminal.addOutput("استثناء أثناء التشغيل: $e", isError: true);
    terminal.clearRunningProcess();
  }
}

Future<void> _runAlifCommand(
  SettingsProvider settings,
  WorkspaceProvider workspace,
  TerminalProvider terminal,
  List<String> commandParts,
) async {
  final binPath = settings.alifBinPath;
  if (binPath == null) {
    terminal.addOutput("لم يتم العثور على مسار لغة ألف", isError: true);
    return;
  }

  final alifFile = File(binPath);
  if (!await alifFile.exists()) {
    terminal.addOutput("لم يتم العثور على ملف تشغيل اللغة", isError: true);
    return;
  }

  await _ensureExecutablePermissions(alifFile.path);
  await _prepareUserDirectory();
  final codeFile = await _prepareCodeFile(workspace, terminal);

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

  final workingDir = (workspace.workspacePath?.isNotEmpty == true)
      ? workspace.workspacePath!
      : File(codeFile.path).parent.path;

  final outputName = isFileCommand
      ? workspace.selectedFile.name
      : (commandParts.length > 1 ? commandParts[1] : "");

  // لازم تعدل دالة getPromptPath عشان تقبل WorkspaceProvider
  final prompt = getPromptPath(workspace);
  terminal.addOutput("$prompt > $kAlifBin $outputName");

  final env = isAndroid ? {"LD_LIBRARY_PATH": libDir} : <String, String>{};
  await _executeAndListen(
    workspace,
    terminal,
    executable,
    processArgs,
    workingDir,
    env,
  );
}

Future<void> _runGeneralCommand(
  BuildContext context,
  WorkspaceProvider workspace,
  TerminalProvider terminal,
  List<String> commandParts,
) async {
  // مررنا الـ context هنا عشان الدالة دي تعتمد على نفسها وتقرا اللي هي عايزاه
  final isBuiltIn = await handleCommands(context, commandParts);
  if (isBuiltIn) return;

  final executable = commandParts[0];
  final processArgs = commandParts.length > 1
      ? commandParts.sublist(1)
      : <String>[];
  final workingDir = (workspace.workspacePath?.isNotEmpty == true)
      ? workspace.workspacePath!
      : kHomeDir;

  final prompt = getPromptPath(workspace);
  terminal.addOutput("$prompt > ${[executable, ...processArgs].join(" ")}");

  await _executeAndListen(
    workspace,
    terminal,
    executable,
    processArgs,
    workingDir,
    {},
  );
}

Future<File> _prepareCodeFile(
  WorkspaceProvider workspace,
  TerminalProvider terminal,
) async {
  final fileData = workspace.selectedFile;
  final isSaved = fileData.path?.isNotEmpty == true;

  if (isSaved) {
    final file = File(fileData.path!);
    final content = await file.readAsString();
    if (content != fileData.code) {
      terminal.addOutput("لم يتم حفظ التعديلات الأخيرة", isError: false);
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
  WorkspaceProvider workspace,
  TerminalProvider terminal,
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

  terminal.editProcess(process);

  final stderrFuture = process.stderr
      .transform(const SystemEncoding().decoder)
      .forEach((result) {
        terminal.addOutput(
          result.trim(),
          isError: !result.toLowerCase().contains("warning"),
        );
      });

  final stdoutFuture = process.stdout
      .transform(const SystemEncoding().decoder)
      .forEach((result) {
        terminal.terminalFocus.requestFocus();
        final lines = result.trim().split("\n");

        if (lines.isNotEmpty &&
            lines.last.isNotEmpty &&
            lines.last.trim().endsWith(":")) {
          terminal.updateTerminalHint(lines.last.replaceAll(":", "").trim());
        }

        terminal.addOutput(result, newLine: false);
      });

  await Future.wait([stdoutFuture, stderrFuture]);

  final exitCode = await process.exitCode;
  if (exitCode != 0) {
    terminal.addOutput("انتهت العملية برمز خطأ [$exitCode]", isError: true);
  }

  terminal.clearRunningProcess();
}
