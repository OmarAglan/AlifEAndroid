import 'dart:io';
import 'package:alifeditor/core/theme/Colors.dart';
import 'package:alifeditor/generated/l10n.dart';
import 'package:alifeditor/widgets/BottomSheet.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:path_provider/path_provider.dart';

class Terminal extends StatefulWidget {
  const Terminal({
    super.key,
    required this.inputController,
    required this.output,
    required this.alifBinPath,
    required this.runAlifProcess,
    required this.onClearOutput,
    required this.onSendInput,
    required this.runAlifCode,
  });

  final TextEditingController inputController;
  final ValueNotifier<String> output;
  final String? alifBinPath;
  final Process? runAlifProcess;
  final VoidCallback onClearOutput;
  final Function(String) onSendInput;
  final VoidCallback runAlifCode;

  @override
  State<Terminal> createState() => _TerminalState();
}

class _TerminalState extends State<Terminal> {
  Process? runningProcess;
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void runCommandHandler() async {
    if (widget.runAlifProcess?.exitCode == null) {
      if (widget.inputController.text == "clear" ||
          widget.inputController.text == "مسح") {
        widget.output.value = "";
        widget.inputController.clear();
        FocusScope.of(context).requestFocus(_focusNode);
        return;
      } else {
        final process = await runCommand(
          widget.inputController.text.split(" "),
          null,
          widget.output,
        );

        if (process != null) {
          setState(() {
            runningProcess = process;
          });
          process.exitCode.then((_) {
            if (mounted) {
              setState(() {
                runningProcess = null;
              });
            }
          });
        }
      }
    } else {
      widget.onSendInput(widget.inputController.text);
    }

    widget.inputController.clear();
    FocusScope.of(context).requestFocus(_focusNode);
  }

  @override
  Widget build(BuildContext context) {
    return MyBottomsheet(
      child: Padding(
        padding: const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    S.of(context).terminal,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: ThemeColors.foreground,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.clear_all_rounded,
                          color: ThemeColors.foreground,
                          size: 30,
                        ),
                        onPressed: widget.onClearOutput,
                      ),
                      IconButton(
                        icon: Icon(
                          LucideIcons.play,
                          size: 20,
                          color: ThemeColors.foreground,
                        ),
                        onPressed: widget.runAlifCode,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ValueListenableBuilder<String>(
                valueListenable: widget.output,
                builder: (context, value, _) => SingleChildScrollView(
                  reverse: true,
                  child: SizedBox(
                    width: double.infinity,
                    child: SelectableText(
                      value.isEmpty ? '' : value,
                      style: TextStyle(
                        fontSize: 14,
                        color: ThemeColors.foreground,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    focusNode: _focusNode,
                    controller: widget.inputController,
                    onSubmitted: (_) => runCommandHandler(),
                    style: TextStyle(color: ThemeColors.foreground),
                    decoration: InputDecoration(
                      hintText: "ادخل هنا",
                      hintStyle: TextStyle(color: ThemeColors.secondary),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: runCommandHandler,
                  icon: Icon(
                    LucideIcons.arrowRight,
                    color: ThemeColors.foreground,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<Process?> runCommand(
  List<String> command,
  Map<String, String>? environment,
  ValueNotifier<String> output,
) async {
  try {
    final appDir = await getApplicationSupportDirectory();
    final userDir = Directory('${appDir.path}/المستخدم');
    if (!await userDir.exists()) await userDir.create(recursive: true);
    await Process.run("chmod", ["755", userDir.path]);
    output.value += "~ > ${command.join(" ")}\n";

    final process = await Process.start(
      command[0],
      command.sublist(1),
      environment: environment,
      workingDirectory: userDir.path,
    );

    process.stdout.transform(SystemEncoding().decoder).listen((data) {
      output.value += data;
    });

    process.stderr.transform(SystemEncoding().decoder).listen((data) {
      if (!data.toLowerCase().contains("warning")) output.value += "خطأ: $data";
    });

    process.exitCode.then((exitCode) {
      if (exitCode != 0) output.value += "حدث خطأ في الامر\n[رقم $exitCode]\n";
    });
    return process;
  } catch (e) {
    output.value += "استثناء أثناء التشغيل: $e\n";
    return null;
  }
}
