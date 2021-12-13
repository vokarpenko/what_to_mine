import 'dart:convert';

// Настройки приложния
class Settings {
  bool notificationIsEnabled;
  int themeIndex;

  Settings({int themeIndex = 1, bool notificationIsEnabled = false})
      : themeIndex = themeIndex,
        notificationIsEnabled = notificationIsEnabled;

  // Превращаем в value type
  bool operator ==(Object other) {
    if (other is Settings) {
      return this.themeIndex == other.themeIndex && this.notificationIsEnabled == other.notificationIsEnabled;
    } else
      return false;
  }

  Map<String, dynamic> _toJson() => {"notificationIsEnabled": notificationIsEnabled, "themeIndex": themeIndex};

  static Settings _fromJson(Map<String, dynamic> json) {
    return Settings(notificationIsEnabled: json["notificationIsEnabled"], themeIndex: json["themeIndex"]);
  }

  String toJsonString() => jsonEncode(_toJson());

  static Settings fromJsonString(String jsonString) => _fromJson(jsonDecode(jsonString));

  @override
  int get hashCode => super.hashCode;
}
