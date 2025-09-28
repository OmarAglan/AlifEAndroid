import 'dart:io';
import 'package:alifeditor/utils/premissions.dart';
import 'package:alifeditor/widgets/AppBar.dart';
import 'package:alifeditor/widgets/IDE.dart';
import 'package:alifeditor/widgets/Shortcuts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
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
  late String runtimeDir;
  Future<void> setupAlif() async {
    const platform = MethodChannel('alif/native');
    try {
      final langDir = await platform.invokeMethod<String>('prepareAlifRuntime');
      if (langDir == null) {
        output.value += "خطأ: ملف لغة الف مش متاح!\n";
        return;
      }

      alifBinPath = langDir;
      output.value += "تم تحميل لغة ألف اصدار 5.1.0\n";
    } catch (e, s) {
      output.value += "خطأ أثناء جلب مسار لغة ألف: $e\n$s";
    }
  }

  Future<void> runAlifCode() async {
    if (alifBinPath == null) {
      output.value += "خطأ: لغة ألف ليست متاحة\n";
      return;
    }
    try {
      final aliflang = File(alifBinPath!);
      await Process.run('chmod', ['755', aliflang.path]);
      final libDir = alifBinPath!.replaceAll('/libalif.so', '');

      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/${selectedFile.value["Name"]}');
      await tempFile.writeAsString(selectedFile.value["Code"] ?? "");
      final codePath = selectedFile.value["Path"] == ""
          ? tempFile.path
          : selectedFile.value["Path"];

      print("----------------------------- $codePath : ${selectedFile.value}");

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
