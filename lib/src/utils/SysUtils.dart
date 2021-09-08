class SysUtils {
  static Future<void> delay(int second) async {
    await new Future.delayed(Duration(seconds: second));
  }

  static Future<void> delayMilliseconds(int milliseconds) async {
    await new Future.delayed(Duration(milliseconds: milliseconds));
  }
}
