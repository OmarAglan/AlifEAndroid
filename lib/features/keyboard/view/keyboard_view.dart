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
  double _dragOffsetDx = 0;
  double _dragOffsetDy = 0;
  static const double _threshold = 15.0;

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
      child: workspace.isKeyboardEnabled
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
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                          flex: 2,
                          child: ShortCutButton(
                            child: name,
                            shortcutLabel: hasShortcut ? item.insert : null,
                            onPressed: () {
                              shortcuts.insert(context, char: name);
                              setState(() => isCap = false);
                            },
                            onLongPress: hasShortcut
                                ? () =>
                                      shortcuts.insert(context, shortcut: item)
                                : null,
                          ),
                        );
                      }).toList();

                      if (rowIndex == currentLayout.length - 1) {
                        rowChildren.insert(
                          0,
                          Expanded(
                            flex: 3,
                            child: ShortCutButton(
                              isRepeatable: true,
                              onPressed: () => shortcuts.deleteFunc(context),
                              child: const Icon(LucideIcons.delete, size: 20),
                            ),
                          ),
                        );

                        if (!isArabic) {
                          rowChildren.add(
                            Expanded(
                              flex: 2,
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
                                  shortcuts.insert(context, char: "\n"),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: ShortCutButton(
                              child: ".",
                              onPressed: () =>
                                  shortcuts.insert(context, char: "."),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: ShortCutButton(
                              child: isArabic ? "العربية" : "English",
                              onPressed: () =>
                                  shortcuts.insert(context, char: " "),
                              onPanUpdate: (details) {
                                _dragOffsetDx += details.delta.dx;
                                _dragOffsetDy += details.delta.dy;

                                if (_dragOffsetDx.abs() > _threshold) {
                                  shortcuts.moveCursorHorizontal(
                                    controller,
                                    _dragOffsetDx > 0 ? 1 : -1,
                                  );
                                  _dragOffsetDx = 0;
                                }
                                if (_dragOffsetDy.abs() > _threshold) {
                                  shortcuts.moveCursorVertical(
                                    controller,
                                    _dragOffsetDy > 0 ? 1 : -1,
                                  );
                                  _dragOffsetDy = 0;
                                }
                              },
                              onPanEnd: (_) {
                                _dragOffsetDx = 0;
                                _dragOffsetDy = 0;
                              },
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
                              onPressed: () => shortcuts.insert(
                                context,
                                char: isArabic ? "،" : ",",
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

                    SizedBox(
                      child: IconButton(
                        onPressed: () => workspace.toggleKeyboard(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: kDefaultPadding,
                          vertical: kSmallPadding,
                        ),
                        icon: const Icon(LucideIcons.chevronDown),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox(width: double.infinity, height: 0),
    );
  }
}
