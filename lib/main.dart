import "package:taif/core/theme/Colors.dart";
import "package:taif/data/ide_data.dart";
import "package:taif/features/shortcuts/data/shortcuts_data.dart";
import "package:taif/generated/l10n.dart";
import "package:taif/features/editor/view/editor_view.dart";
import "package:flutter/material.dart";
import "package:flutter_localizations/flutter_localizations.dart";
import "package:provider/provider.dart";

void main() => runApp(const Taif());

class Taif extends StatelessWidget {
  const Taif({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => IdeData()),
        ChangeNotifierProvider(create: (_) => ShortcutsData()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: const Locale("ar"),
        localizationsDelegates: [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        title: "مُحرر طيف",
        theme: ThemeData(
          fontFamily: "Tajawal",
          brightness: Brightness.dark,
          scaffoldBackgroundColor: ThemeColors.background,
        ),
        home: const EditorView(),
      ),
    );
  }
}
