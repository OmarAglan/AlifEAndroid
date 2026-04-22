import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:provider/provider.dart";

import "../../../../constants.dart";
import "../../../../core/theme/colors.dart";
import "../../../../core/utils/show_error.dart";
import "../../../../data/data_types.dart";
import "../../../../data/ide_data.dart";

class TerminalOutputs extends StatelessWidget {
  const TerminalOutputs({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<IdeData>(
      builder: (context, data, child) {
        final Map<int, List<TerminalLine>> sessions = {};
        for (var line in data.outputLines) {
          sessions.putIfAbsent(line.sessionId, () => []).add(line);
        }

        final sessionIds = sessions.keys.toList().reversed.toList();

        return ListView.builder(
          reverse: true,
          itemCount: sessionIds.length,
          itemBuilder: (context, index) {
            final sessionId = sessionIds[index];
            final List<TerminalLine> sessionLines = sessions[sessionId]!;
            final String fullSessionText = sessionLines
                .map((e) => e.text)
                .join("\n");

            final List<Widget> groupedWidgets = [];
            if (sessionLines.isNotEmpty) {
              List<TerminalLine> currentGroup = [];
              bool? lastType = sessionLines[0].isError;

              for (var line in sessionLines) {
                if (line.isError == lastType) {
                  currentGroup.add(line);
                } else {
                  groupedWidgets.add(
                    _buildGroupedText(context, currentGroup, lastType),
                  );
                  currentGroup = [line];
                  lastType = line.isError;
                }
              }
              groupedWidgets.add(
                _buildGroupedText(context, currentGroup, lastType),
              );
            }

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(kSmallPadding),
                decoration: BoxDecoration(
                  color: sessionId % 2 == 0
                      ? Colors.white.withAlpha(5)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(kSmallPadding),
                ),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: groupedWidgets,
                    ),
                    if (sessionLines.length > 1)
                      PositionedDirectional(
                        top: 0,
                        end: 0,
                        child: IconButton(
                          onPressed: () async {
                            await Clipboard.setData(
                              ClipboardData(text: fullSessionText),
                            );
                            showMessage(
                              "تم نسخ مخرجات العملية بالكامل",
                              isError: false,
                            );
                          },
                          icon: const Icon(LucideIcons.copy, size: kLargeFont),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGroupedText(
    BuildContext context,
    List<TerminalLine> group,
    bool? type,
  ) {
    final String combinedText = group.map((e) => e.text).join("\n");

    return SelectableText(
      combinedText,
      style: TextStyle(
        fontSize: kSmallFont,
        color: type == true
            ? context.error
            : type == false
            ? context.warning
            : null,
        fontWeight: type != null ? FontWeight.bold : FontWeight.normal,
        height: 1.5,
      ),
    );
  }
}
