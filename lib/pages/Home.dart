import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:alifeditor/utils/premissions.dart';
import 'package:alifeditor/widgets/AppBar.dart';
import 'package:alifeditor/widgets/IDE.dart';
import 'package:alifeditor/widgets/Shortcuts.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController code = TextEditingController(text: "");
  final FocusNode editorFocus = FocusNode();
  TextEditingController inputController = TextEditingController();
  final ValueNotifier<Process?> runningProcess = ValueNotifier(null);
  final ValueNotifier<String> output = ValueNotifier("");

  final ValueNotifier<Map<dynamic, dynamic>> selectedFile = ValueNotifier({});

  final ValueNotifier<double> fontSize = ValueNotifier<double>(15);
  final ValueNotifier<bool> autoSave = ValueNotifier<bool>(true);

  late Future<void> setupFuture;
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await _loadSavedSettings();
      await requestStoragePermission(context);
      await setupAlif();
    });
  }

  Future<void> _loadSavedSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final savedFontSize = prefs.getDouble('EditorFontSize');
    if (savedFontSize != null) fontSize.value = savedFontSize;
    final savedAutoSave = prefs.getBool('EditorAutoSave');
    if (savedAutoSave != null) autoSave.value = savedAutoSave;
  }

  String? alifBinPath;

  Future<void> setupAlif() async {
    try {
      final appDir = await getApplicationSupportDirectory();
      final alifDir = Directory('${appDir.path}/alif');

      if (Platform.isAndroid) {
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
        output.value += ("تم تحميل لغة ألف اصدار 5.1.0\n");
      } else {
        output.value += ("$appDir \n $alifDir \n");
      }
    } catch (e, s) {
      output.value += ("خطأ أثناء تجهيز ملفات لغة ألف: $e\n$s");
    }
  }

  Future<void> runAlifCode() async {
    final file = selectedFile.value;
    if (alifBinPath == null) {
      output.value += ("خطأ: لغة ألف ليست متاحة\n");
      return;
    }
    var status = await Permission.manageExternalStorage.status;
    try {
      final aliflang = File(alifBinPath!);

      if (Platform.isAndroid) {
        await Process.run('chmod', ['755', aliflang.path]);
        final libDir = alifBinPath!.replaceAll('/libalif.so', '');

        final isNotSaved = status.isDenied || file["Path"] == "";
        var codePath = File("/");

        if (isNotSaved) {
          var tempDir = await getTemporaryDirectory();
          codePath = File('${tempDir.path}/${file["Name"]}');
          await codePath.writeAsString(file["Code"] ?? "");
        } else {
          codePath = File(file["Path"]);
          final fileContent = await codePath.readAsString();
          if (fileContent != file["Code"]) {
            output.value += ("تحذير: لم يتم حفظ التعديلات الاخيرة ⚠️\n");
          }
        }

        final process = await Process.start(
          "/system/bin/linker64",
          [aliflang.path, codePath.path],
          environment: {'LD_LIBRARY_PATH': libDir},
        );
        runningProcess.value = process;
        process.stdout.transform(SystemEncoding().decoder).listen((data) {
          output.value += (data);
        });
        process.stderr.transform(SystemEncoding().decoder).listen((data) {
          if (!data.toLowerCase().contains("warning")) {
            output.value += ("خطأ: $data");
          }
        });
        process.exitCode.then((exitCode) {
          if (exitCode != 0) {
            output.value += ("حدث خطأ في الشفرة\n[رقم $exitCode]\n");
          }
        });
      } else {
        output.value += "النظام غير مدعوم\n";
      }
    } catch (e, s) {
      output.value += ("استثناء أثناء التشغيل: $e\n$s");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
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
    );
  }
}
