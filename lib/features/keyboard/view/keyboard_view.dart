import "package:flutter/material.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:provider/provider.dart";
import "../../../constants.dart";
import "../../../core/providers/workspace_provider.dart";
import "../../shortcuts/data/shortcuts_provider.dart";
import "../../shortcuts/view/shortcuts_view.dart";

class KeyboardView extends StatefulWidget {
  const KeyboardView({super.key});

  @override
  State<KeyboardView> createState() => _KeyboardViewState();
}

class _KeyboardViewState extends State<KeyboardView> {
  bool isArabic = true;
  bool isCap = false;
  bool isNum = true;

  @override
  Widget build(BuildContext context) {
    final workspace = context.watch<WorkspaceProvider>();
    final shortcuts = context.read<ShortcutsProvider>();
    final controller = workspace.codeController;
    final screenHeight = MediaQuery.of(context).size.height;

    final baseLayout = isArabic
        ? shortcuts.arabicLayout
        : shortcuts.englishLayout;

    final currentLayout = isNum
        ? [shortcuts.nums, ...baseLayout]
        : [...baseLayout];

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      alignment: Alignment.bottomCenter,
      child: workspace.enableKeybord
          ? Container(
              height: screenHeight * 0.3,
              padding: const EdgeInsets.only(
                top: 2,
                right: kSmallPadding,
                left: kSmallPadding,
              ),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Column(
                  children: [
                    ...currentLayout.asMap().entries.map((entry) {
                      final int rowIndex = entry.key;
                      final List<ShortcutsEntity> row = entry.value;

                      final List<Widget> rowChildren = row.map((item) {
                        final bool hasShortcut = item.insert != item.name;
                        final name = isCap
                            ? item.name.toUpperCase()
                            : item.name;

                        return Expanded(
                          child: ShortCutButton(
                            child: name,
                            shortcutLabel: hasShortcut ? item.insert : null,
                            onPressed: () {
                              controller.insertAtCurrentCursor(name);
                              setState(() => isCap = false);
                            },
                            onLongPress: hasShortcut
                                ? () => shortcuts.insertEntity(context, item)
                                : null,
                          ),
                        );
                      }).toList();

                      if (rowIndex == currentLayout.length - 1) {
                        rowChildren.insert(
                          0,
                          Expanded(
                            flex: 1,
                            child: ShortCutButton(
                              child: const Icon(LucideIcons.delete, size: 20),
                              onPressed: () => shortcuts.deleteFunc(context),
                            ),
                          ),
                        );

                        if (!isArabic) {
                          rowChildren.add(
                            Expanded(
                              flex: 1,
                              child: ShortCutButton(
                                child: const Icon(
                                  LucideIcons.arrowUp,
                                  size: 20,
                                ),
                                onPressed: () => setState(() => isCap = !isCap),
                              ),
                            ),
                          );
                        }
                      }

                      return Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: rowChildren,
                        ),
                      );
                    }),

                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: ShortCutButton(
                              child: const Icon(
                                LucideIcons.cornerDownLeft,
                                size: 20,
                              ),
                              onPressed: () =>
                                  controller.insertAtCurrentCursor("\n"),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: ShortCutButton(
                              child: ".",
                              onPressed: () =>
                                  controller.insertAtCurrentCursor("."),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: ShortCutButton(
                              child: isArabic ? "العربية" : "English",
                              onPressed: () =>
                                  controller.insertAtCurrentCursor(" "),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: ShortCutButton(
                              child: const Icon(LucideIcons.globe, size: 20),
                              onPressed: () =>
                                  setState(() => isArabic = !isArabic),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: ShortCutButton(
                              child: isArabic ? "،" : ",",
                              onPressed: () => controller.insertAtCurrentCursor(
                                isArabic ? "،" : ",",
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: ShortCutButton(
                              child: Text(isNum ? "ABC" : "?123"),
                              onPressed: () => setState(() => isNum = !isNum),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: kLargePadding),
                  ],
                ),
              ),
            )
          : const SizedBox(width: double.infinity, height: 0),
    );
  }
}
