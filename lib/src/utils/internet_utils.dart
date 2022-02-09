import 'package:connectivity/connectivity.dart';

class InternetUtils {
  static Future<bool> isInternetAvailable() async {
    ConnectivityResult connectivityResult = await (Connectivity().checkConnectivity());
    bool result = connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi;
    return result;
  }
}
