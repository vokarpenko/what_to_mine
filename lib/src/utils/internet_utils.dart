import 'package:connectivity_plus/connectivity_plus.dart';

class InternetUtils {
  static Future<bool> isInternetAvailable() async {
    final connections = await Connectivity().checkConnectivity();
    return connections.any(
      (connection) => connection != ConnectivityResult.none,
    );
  }
}
