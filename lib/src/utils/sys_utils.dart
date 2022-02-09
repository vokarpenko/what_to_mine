class SysUtils {
  static Future<void> delay(int second) async {
    await Future.delayed(Duration(seconds: second));
  }

  static Future<void> delayMilliseconds(int milliseconds) async {
    await Future.delayed(Duration(milliseconds: milliseconds));
  }
}
