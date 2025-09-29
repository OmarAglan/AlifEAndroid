import 'dart:io';
import 'package:alifeditor/utils/premissions.dart';
import 'package:alifeditor/widgets/AppBar.dart';
import 'package:alifeditor/widgets/IDE.dart';
import 'package:alifeditor/widgets/Shortcuts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(
  MaterialApp(
    debugShowCheckedModeBanner: false,
    title: "مُحرر طيف",
    theme: ThemeData(fontFamily: 'Tajawal'),
    home: AlifRunner(),
  ),
);

class AlifRunner extends StatefulWidget {
  const AlifRunner({super.key});

  @override
  State<AlifRunner> createState() => _AlifRunnerState();
}

class _AlifRunnerState extends State<AlifRunner> {
  TextEditingController code = TextEditingController(text: "");
  final FocusNode editorFocus = FocusNode();
  final ValueNotifier<String> output = ValueNotifier("");
  TextEditingController inputController = TextEditingController();
  final ValueNotifier<Process?> runningProcess = ValueNotifier(null);

  final ValueNotifier<Map<dynamic, dynamic>> selectedFile = ValueNotifier({});

  final ValueNotifier<double> fontSize = ValueNotifier<double>(15);
  final ValueNotifier<bool> autoSave = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();
    _loadSavedFontSize();
    setupAlif();
    requestStoragePermission(context);
  }

  Future<void> _loadSavedFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    final savedFontSize = prefs.getDouble('EditorFontSize');
    if (savedFontSize != null) {
      fontSize.value = savedFontSize;
    }
  }

  String? alifBinPath;

  Future<void> setupAlif() async {
    try {
      final appDir = await getApplicationSupportDirectory();
      final alifDir = Directory('${appDir.path}/alif');

      if (!await alifDir.exists()) await alifDir.create(recursive: true);
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

      for (final fileName in filesToCopy) {
        final data = await rootBundle.load('assets/$fileName');
        final bytes = data.buffer.asUint8List();
        final targetPath = fileName.contains('arm64-v8a')
            ? '${arm64Dir.path}/${fileName.split('/').last}'
            : '${libDir.path}/${fileName.split('/').last}';
        final file = File(targetPath);
        await file.writeAsBytes(bytes, flush: true);
      }

      alifBinPath = '${arm64Dir.path}/libalif.so';
      output.value += "تم تحميل لغة ألف اصدار 5.1.0\n";
    } catch (e, s) {
      output.value += "خطأ أثناء تجهيز ملفات لغة ألف: $e\n$s";
    }
  }

  Future<void> runAlifCode() async {
    if (alifBinPath == null) {
      output.value += "خطأ: لغة ألف ليست متاحة\n";
      return;
    }
    var status = await Permission.manageExternalStorage.status;
    try {
      final aliflang = File(alifBinPath!);
      await Process.run('chmod', ['755', aliflang.path]);
      final libDir = alifBinPath!.replaceAll('/libalif.so', '');

      final tempDir = status.isDenied
          ? await getTemporaryDirectory()
          : Directory('/storage/emulated/0/Documents/شفرات لغة الف');
      final tempFile = File('${tempDir.path}/${selectedFile.value["Name"]}');
      await tempFile.writeAsString(selectedFile.value["Code"] ?? "");
      final codePath = selectedFile.value["Path"] == ""
          ? tempFile.path
          : selectedFile.value["Path"];

      final process = await Process.start(
        "/system/bin/linker64",
        [aliflang.path, codePath],
        environment: {'LD_LIBRARY_PATH': libDir},
      );
      runningProcess.value = process;
      process.stdout.transform(SystemEncoding().decoder).listen((data) {
        output.value += data;
      });
      process.stderr.transform(SystemEncoding().decoder).listen((data) {
        if (!data.toLowerCase().contains("warning")) {
          output.value += "خطأ: $data";
        }
      });
      process.exitCode.then((exitCode) {
        if (exitCode != 0) {
          output.value += "حدث خطأ في الشفرة\n[رقم $exitCode]\n";
        }
      });
    } catch (e, s) {
      output.value += "استثناء أثناء التشغيل: $e\n$s";
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF081433),
        body: DecoratedBox(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/Background.webp"),
              fit: BoxFit.cover,
              alignment: Alignment.topLeft,
            ),
          ),
          child: Column(
            children: [
              AlifAppBar(
                controller: code,
                inputController: inputController,
                output: output,
                alifBinPath: alifBinPath,
                runningProcess: runningProcess,
                runAlifCode: runAlifCode,
                selectedFile: selectedFile,
                fontSize: fontSize,
                autoSave: autoSave,
              ),
              IDE(controller: code, focusNode: editorFocus, fontSize: fontSize),
              KeyShortcuts(controller: code, focusNode: editorFocus),
            ],
          ),
        ),
      ),
    );
  }
}
