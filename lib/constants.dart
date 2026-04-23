// Fonts Family
import "dart:io";

import "package:flutter/material.dart";
import "generated/l10n.dart";

const String kMainFont = "Tajawal";

// Fonts Size
const double kSoSmallFont = 12;
const double kSmallFont = 14;
const double kMediumFont = 16;
const double kLargeFont = 20;
const double kSoLargeFont = 24;

// Paddings
const double kSmallPadding = 5;
const double kMediumPadding = 10;
const double kLargePadding = 15;
const double kDefaultPadding = 20;

// Border Radius
const double kSoSmallBorderRadius = 15;
const double kSmallBorderRadius = 26;
const double kMediumBorderRadius = 30;
const double kLargeBorderRadius = 50;
const double kCircleBorderRadius = 100;

// Animations Durations & Curves
const Duration kAnimationFasterDuration = Duration(milliseconds: 200);
const Duration kAnimationDuration = Duration(milliseconds: 350);
const Duration kAnimationSlowerDuration = Duration(milliseconds: 500);

const Curve kCurveEaseInOut = Curves.easeInOut;
const Curve kCurveEaseOutBack = Curves.easeOutBack;

// ide
const int kCodeSpaceLength = 4;
final String kCodeSpace = " " * kCodeSpaceLength;

// directories
final String kHomeDir = Platform.isAndroid
    ? "/storage/emulated/0"
    : Platform.isLinux
    ? "${Platform.environment["HOME"]}"
    : "";
const String kAlifBin = "الف";
const String kTempFileName = "ملفkمؤقت.الف";
const String kLinkerPath = "/system/bin/linker64";
const String kLibAlifSuffix = "/libalif.so";

// Global Variables
final S l10n = S.current;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> messengerKey =
    GlobalKey<ScaffoldMessengerState>();
