import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taif/core/data/ideData.dart';
import 'package:taif/utils/files/createFile.dart';
import 'package:taif/widgets/OpenedFiles/editSheet.dart';
import 'package:taif/widgets/OpenedFiles/tap.dart';

class OpenedFiles extends StatelessWidget {
  const OpenedFiles({super.key});

  void onLongPress(BuildContext context, int id) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Editsheet(id: id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Row(
            children: [
              Consumer<IdeData>(
                builder: (context, data, child) => Row(
                  children: List.generate(data.files.length, (id) {
                    bool sel = data.selectedFile.id == id;
                    final files = data.files;
                    bool isNotSaved = !(files[id]["Saved"] ?? false);
                    return Tap(
                      id: id,
                      isNotSaved: isNotSaved,
                      name: files[id]["Name"],
                      onLongPress: onLongPress,
                      sel: sel,
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
      ),
    );
  }
}
