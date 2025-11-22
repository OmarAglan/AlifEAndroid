import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taif/core/data/ideData.dart';
import 'package:taif/core/theme/Colors.dart';
import 'package:taif/utils/files/createFile.dart';
import 'package:taif/utils/files/openFile.dart';

class OpenedFiles extends StatelessWidget {
  const OpenedFiles({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Consumer<IdeData>(
              builder: (context, data, child) => Row(
                children: List.generate(data.files.length, (id) {
                  bool sel = data.selectedFile.id == id;
                  final files = data.files;
                  bool isNotSaved = !(files[id]["Saved"] ?? false);
                  return GestureDetector(
                    onTap: () => openFile(id, context),
                    // onLongPress: () =>
                    //     onLongPress(i, context, files, addOrUpdateFile),
                    child: Container(
                      margin: EdgeInsets.all(5),
                      padding: EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: sel
                            ? [
                                BoxShadow(
                                  color: ThemeColors.primary,
                                  blurRadius: 5,
                                ),
                              ]
                            : [],
                      ),
                      child: Row(
                        children: [
                          if (isNotSaved)
                            Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: ThemeColors.foreground,
                              ),
                            ),
                          if (isNotSaved) SizedBox(width: 5),
                          Text(files[id]["Name"]),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
            IconButton(
              onPressed: () => createFile(context: context),
              icon: Icon(Icons.add_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
