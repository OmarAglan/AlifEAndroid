import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:vibration/vibration.dart";
import "../../constants.dart";

enum AppSetting {
  fontSize,
  editorFont,
  autoSave,
  enableFolding,
  enableGuideLines,
  enableSuggestions,
  customKeyboard,
  lineWrap,
  tapSize,
  enableVibration,
  alifBinPath,
  gitBinPath,
}

extension AppSettingExt on AppSetting {
  String get key => name;

  dynamic get defaultValue {
    switch (this) {
      case AppSetting.fontSize:
        return kMediumFont;
      case AppSetting.editorFont:
        return kMainFont;
      case AppSetting.autoSave:
      case AppSetting.enableVibration:
      case AppSetting.customKeyboard:
        return true;
      case AppSetting.tapSize:
        return kCodeSpaceLength;
      case AppSetting.alifBinPath:
      case AppSetting.gitBinPath:
        return null;
      default:
        return false;
    }
  }
}

class SettingsProvider extends ChangeNotifier {
  SharedPreferences? _prefs;
  bool isReady = false;

  String get alifBinPath => get(AppSetting.alifBinPath);

  final Map<AppSetting, dynamic> _values = {};

  SettingsProvider() {
    for (var setting in AppSetting.values) {
      _values[setting] = setting.defaultValue;
    }
    _init();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();

    for (var setting in AppSetting.values) {
      if (_prefs!.containsKey(setting.key)) {
        _values[setting] = _prefs!.get(setting.key);
      }
    }

    isReady = true;
    notifyListeners();
  }

  T get<T>(AppSetting setting) => (_values[setting] as T);

  void set(AppSetting setting, dynamic value) {
    if (_values[setting] == value) return;

    _values[setting] = value;

    if (_prefs != null && value != null) {
      if (value is bool) {
        _prefs!.setBool(setting.key, value);
      } else if (value is int) {
        _prefs!.setInt(setting.key, value);
      } else if (value is double) {
        _prefs!.setDouble(setting.key, value);
      } else if (value is String) {
        _prefs!.setString(setting.key, value);
      }
    }

    notifyListeners();
  }

  // vibration
  void runVibration({required List<int> pattern, int duration = 0}) {
    if (!get<bool>(AppSetting.enableVibration)) return;
    Vibration.hasVibrator().then((has) {
      if (has == true) Vibration.vibrate(pattern: pattern, duration: duration);
    });
  }
}
