import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

import "../../constants.dart";

class SettingsProvider extends ChangeNotifier {
  SharedPreferences? _prefs;
  bool isReady = false;
  bool autoSave = true;
  double fontSize = kMediumFont;
  String? alifBinPath;

  SettingsProvider() { _init(); }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    autoSave = _prefs?.getBool(kKeyAutoSave) ?? true;
    fontSize = _prefs?.getDouble(kKeyFontSize) ?? kMediumFont;
    isReady = true;
    notifyListeners();
  }

  void setAlifPath(String path) {
    alifBinPath = path;
    notifyListeners();
  }

  void setAutoSave(bool value) {
    autoSave = value;
    _prefs?.setBool(kKeyAutoSave, value);
    notifyListeners();
  }

  void setFontSize(double value) {
    fontSize = value;
    _prefs?.setDouble(kKeyFontSize, value);
    notifyListeners();
  }
}