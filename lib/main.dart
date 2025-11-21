import 'package:taif/core/data/ideData.dart';
import 'package:taif/core/theme/Colors.dart';
import 'package:taif/generated/l10n.dart';
import 'package:taif/pages/Home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

void main() => runApp(Taif());

class Taif extends StatelessWidget {
  const Taif({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => IdeData(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: Locale("ar"),
        localizationsDelegates: [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        title: "مُحرر طيف",
        theme: ThemeData(
          fontFamily: 'Tajawal',
          brightness: Brightness.dark,
          scaffoldBackgroundColor: ThemeColors.background,
        ),
        home: Home(),
      ),
    );
  }
}
