import "dart:io";
import "../../../constants.dart";
import "../../../data/ide_data.dart";

enum BuiltIn { clear, pwd, cd, echo, date, ls, mkdir, touch, rm, help, exit }

class CommandDef {
  final BuiltIn id;
  final List<String> aliases;
  final String description;

  const CommandDef(this.id, this.aliases, this.description);
}

const List<CommandDef> _commands = [
  CommandDef(BuiltIn.clear, ["مسح", "clear"], "تنظيف الشاشة"),
  CommandDef(BuiltIn.pwd, ["مسار", "pwd"], "عرض مسار العمل الحالي"),
  CommandDef(BuiltIn.cd, ["انتقل", "cd"], "تغيير مسار العمل"),
  CommandDef(BuiltIn.ls, ["عرض", "ls"], "عرض محتويات المجلد الحالي"),
  CommandDef(BuiltIn.mkdir, ["مجلد", "mkdir"], "إنشاء مجلد جديد"),
  CommandDef(BuiltIn.touch, ["ملف", "touch"], "إنشاء ملف جديد فارغ"),
  CommandDef(BuiltIn.rm, ["حذف", "rm"], "حذف ملف أو مجلد"),
  CommandDef(BuiltIn.echo, ["طباعة", "اطبع", "echo"], "طباعة نص على الشاشة"),
  CommandDef(BuiltIn.date, ["تاريخ", "date"], "عرض الوقت والتاريخ الحالي"),
  CommandDef(BuiltIn.help, ["مساعدة", "help"], "عرض هذه القائمة"),
  CommandDef(BuiltIn.exit, ["إنهاء", "انهاء", "exit"], "إنهاء العملية الحالية"),
];

Future<bool> handleCommands(IdeData data, List<String> commandParts) async {
  if (commandParts.isEmpty) return false;

  final command = commandParts[0].toLowerCase();
  final args = commandParts.length > 1 ? commandParts.sublist(1) : <String>[];

  BuiltIn? matchedCmd;
  for (final cmd in _commands) {
    if (cmd.aliases.contains(command)) {
      matchedCmd = cmd.id;
      break;
    }
  }

  if (matchedCmd == null) return false;

  switch (matchedCmd) {
    case BuiltIn.clear:
      data.clearOutput();
      return true;
    case BuiltIn.pwd:
      data.addOutput(_getCurrentPath(data));
      return true;
    case BuiltIn.cd:
      await _handleCdCommand(data, args.isEmpty ? kHomeDir : args[0]);
      return true;
    case BuiltIn.echo:
      data.addOutput(args.join(" "));
      return true;
    case BuiltIn.date:
      data.addOutput(DateTime.now().toString());
      return true;
    case BuiltIn.ls:
      await _handleLsCommand(data, args);
      return true;
    case BuiltIn.mkdir:
      await _handleMkdirCommand(data, args);
      return true;
    case BuiltIn.touch:
      await _handleTouchCommand(data, args);
      return true;
    case BuiltIn.rm:
      await _handleRmCommand(data, args);
      return true;
    case BuiltIn.help:
      _showHelp(data);
      return true;
    case BuiltIn.exit:
      data.clearRunningProcess();
      data.addOutput("\n ---");
      return true;
  }
}

// ---------------------------------------------------------
// الدوال المساعدة (Helper Methods)
// ---------------------------------------------------------

String _getCurrentPath(IdeData data) {
  return data.workspacePath?.isNotEmpty == true
      ? data.workspacePath!
      : kHomeDir;
}

String _resolvePath(String currentPath, String targetDir) {
  if (targetDir.startsWith("/")) return targetDir;

  String newPath = Uri.file("$currentPath/").resolve(targetDir).toFilePath();
  if (newPath.endsWith("/") && newPath.length > 1) {
    newPath = newPath.substring(0, newPath.length - 1);
  }
  return newPath;
}

void _showHelp(IdeData data) {
  final buffer = StringBuffer("الأوامر الداخلية المتاحة:\n");
  for (final cmd in _commands) {
    final aliasesStr = cmd.aliases.join(" | ");
    buffer.writeln("$aliasesStr: ${cmd.description}");
  }
  data.addOutput(buffer.toString().trim(), isError: false);
}

Future<void> _handleCdCommand(IdeData data, String targetDir) async {
  final newPath = _resolvePath(_getCurrentPath(data), targetDir);
  final dir = Directory(newPath);

  if (await dir.exists()) {
    data.workspacePath = dir.path;
    data.addOutput("تم الانتقال إلى: ${dir.path}", isError: false);
    await _handleLsCommand(data, []);
  } else {
    data.addOutput("cd: $targetDir: لا يوجد مجلد بهذا الاسم", isError: true);
  }
  data.clearRunningProcess();
}

Future<void> _handleLsCommand(IdeData data, List<String> args) async {
  final targetDir = args.isEmpty
      ? _getCurrentPath(data)
      : _resolvePath(_getCurrentPath(data), args[0]);
  final dir = Directory(targetDir);

  if (!await dir.exists()) {
    data.addOutput("ls: $targetDir: لا يوجد مجلد بهذا الاسم", isError: true);
    return;
  }

  try {
    final List<FileSystemEntity> entities = await dir.list().toList();
    if (entities.isEmpty) return;

    final directories = entities
        .whereType<Directory>()
        .map((e) => "${e.path.split(Platform.pathSeparator).last}/")
        .toList();
    final files = entities
        .whereType<File>()
        .map((e) => e.path.split(Platform.pathSeparator).last)
        .toList();

    directories.sort();
    files.sort();

    final output = [...directories, ...files].join("  ");
    data.addOutput(output);
  } catch (e) {
    data.addOutput("ls: لا يمكن قراءة المحتوى: $e", isError: true);
  }
}

Future<void> _handleMkdirCommand(IdeData data, List<String> args) async {
  if (args.isEmpty) {
    data.addOutput("mkdir: يجب تحديد اسم المجلد", isError: true);
    return;
  }

  final newPath = _resolvePath(_getCurrentPath(data), args[0]);
  final dir = Directory(newPath);

  if (await dir.exists()) {
    data.addOutput("mkdir: المجلد '${args[0]}' موجود بالفعل", isError: true);
  } else {
    await dir.create(recursive: true);
  }
}

Future<void> _handleTouchCommand(IdeData data, List<String> args) async {
  if (args.isEmpty) {
    data.addOutput("touch: يجب تحديد اسم الملف", isError: true);
    return;
  }

  final newPath = _resolvePath(_getCurrentPath(data), args[0]);
  final file = File(newPath);

  if (!await file.exists()) {
    await file.create();
  } else {
    final now = DateTime.now();
    await file.setLastModified(now);
    await file.setLastAccessed(now);
  }
}

Future<void> _handleRmCommand(IdeData data, List<String> args) async {
  if (args.isEmpty) {
    data.addOutput("rm: يجب تحديد اسم الملف أو المجلد للحذف", isError: true);
    return;
  }

  final isRecursive = args.contains("-r") || args.contains("-rf");
  final targetName = args.last;
  final targetPath = _resolvePath(_getCurrentPath(data), targetName);

  final type = await FileSystemEntity.type(targetPath);

  try {
    if (type == FileSystemEntityType.file) {
      await File(targetPath).delete();
    } else if (type == FileSystemEntityType.directory) {
      if (isRecursive) {
        await Directory(targetPath).delete(recursive: true);
      } else {
        data.addOutput(
          "rm: '$targetName' مجلد، استخدم -r لحذفه",
          isError: true,
        );
      }
    } else {
      data.addOutput(
        "rm: $targetName: لا يوجد ملف أو مجلد بهذا الاسم",
        isError: true,
      );
    }
  } catch (e) {
    data.addOutput("rm: فشل الحذف: $e", isError: true);
  }
}

String getPromptPath(IdeData data) {
  final path = _getCurrentPath(data);
  if (path.startsWith(kHomeDir)) {
    return path.replaceFirst(kHomeDir, "~");
  }
  return path;
}
