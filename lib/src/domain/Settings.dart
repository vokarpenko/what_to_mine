// ignore_for_file: prefer_initializing_formals

import 'dart:convert';

// Настройки приложния
class Settings {
  bool notificationIsEnabled;
  int themeIndex;
  bool isFirstRun;
  double electricityCost;

  Settings({int themeIndex = 1, bool notificationIsEnabled = false, bool isFirstRun = true, double electricityCost = 0.1})
      : themeIndex = themeIndex,
        notificationIsEnabled = notificationIsEnabled,
        isFirstRun = isFirstRun,
        electricityCost = electricityCost;

  @override
  bool operator ==(Object other) {
    if (other is Settings) {
      return themeIndex == other.themeIndex &&
          notificationIsEnabled == other.notificationIsEnabled &&
          isFirstRun == other.isFirstRun;
    } else {
      return false;
    }
  }

  Map<String, dynamic> _toJson() => {
    'notificationIsEnabled': notificationIsEnabled,
    'themeIndex': themeIndex,
    'isFirstRun': isFirstRun,
    'electricityCost': electricityCost
  };

  static Settings _fromJson(Map<String, dynamic> json) {
    return Settings(
        notificationIsEnabled: json['notificationIsEnabled'],
        themeIndex: json['themeIndex'],
        isFirstRun: json['isFirstRun'],
        electricityCost: json['electricityCost']);
  }

  String toJsonString() => jsonEncode(_toJson());

  static Settings fromJsonString(String jsonString) => _fromJson(jsonDecode(jsonString));

  @override
  // ignore: unnecessary_overrides
  int get hashCode => super.hashCode;
}
