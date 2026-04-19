import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:taif/core/theme/colors.dart";
import "package:taif/core/theme/text.dart";
import "package:taif/features/shortcuts/data/shortcuts_data.dart";

class ShortcutsView extends StatelessWidget {
  const ShortcutsView({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<ShortcutsData>();
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: List.generate(
              data.shortcuts.length,
              (index) => Padding(
                padding: const EdgeInsets.all(1),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 0,
                    maxWidth: 37,
                    maxHeight: 30,
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0x601A2340),
                      foregroundColor: ThemeColors.foreground,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      textStyle: ThemeText.mid,
                    ),
                    onPressed: () => data.insertText(
                      context,
                      data.shortcuts[index].insert,
                      index,
                    ),
                    child: Text(
                      data.shortcuts[index].name,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
