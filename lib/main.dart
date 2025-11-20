import 'package:alifeditor/core/theme/Colors.dart';
import 'package:alifeditor/generated/l10n.dart';
import 'package:alifeditor/pages/Home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() => runApp(
  MaterialApp(
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
