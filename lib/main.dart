import "package:flutter/material.dart";
import "package:flutter_localizations/flutter_localizations.dart";
import "package:provider/provider.dart";
import "constants.dart";
import "core/theme/colors.dart";
import "data/ide_data.dart";
import "features/editor/view/editor_view.dart";
import "features/shortcuts/data/shortcuts_data.dart";
import "generated/l10n.dart";

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
        navigatorKey: navigatorKey,
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        onGenerateTitle: (context) => S.of(context).title,
        themeMode: ThemeMode.dark,
        theme: AppThemes.darkTheme,
        home: const EditorView(),
      ),
    );
  }
}
