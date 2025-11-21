import 'dart:io';
import 'package:provider/provider.dart';
import 'package:taif/core/data/ideData.dart';
import 'package:taif/core/theme/Colors.dart';
import 'package:taif/generated/l10n.dart';
import 'package:taif/utils/runAlif.dart';
import 'package:taif/widgets/BottomSheet.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:path_provider/path_provider.dart';

class Terminal extends StatelessWidget {
  Terminal({super.key});
  TextEditingController inputController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  void runCommandHandler(IdeData data, BuildContext context) async {
    if (data.runningProcess?.exitCode == null) {
      if (inputController.text == "clear" || inputController.text == "مسح") {
        data.clearOutput();
        inputController.clear();
        FocusScope.of(context).requestFocus(_focusNode);
        return;
      } else {
        // final process = await runCommand(
        //   inputController.text.split(" "),
        //   null,
        //   output,
        // );
        // if (process != null) {
        //   setState(() {
        //     runningProcess = process;
        //   });
        //   process.exitCode.then((_) {
        //     if (mounted) {
        //       setState(() {
        //         runningProcess = null;
        //       });
        //     }
        //   });
        // }
      }
    } else {
      data.sendOutput(inputController.text);
    }
    inputController.clear();
    FocusScope.of(context).requestFocus(_focusNode);
  }

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<IdeData>(context, listen: false);

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
                        onPressed: data.clearOutput,
                      ),
                      IconButton(
                        icon: Icon(
                          LucideIcons.play,
                          size: 20,
                          color: ThemeColors.foreground,
                        ),
                        onPressed: () => runAlifCode(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                reverse: true,
                child: SizedBox(
                  width: double.infinity,
                  child: Consumer<IdeData>(
                    builder: (context, data, child) => SelectableText(
                      data.output,
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
                    controller: inputController,
                    onSubmitted: (_) => runCommandHandler(data, context),
                    style: TextStyle(color: ThemeColors.foreground),
                    decoration: InputDecoration(
                      hintText: "ادخل هنا",
                      hintStyle: TextStyle(color: ThemeColors.secondary),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => runCommandHandler(data, context),
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
