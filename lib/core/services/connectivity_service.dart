import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static Stream<List<ConnectivityResult>> get connectivityStream =>
      Connectivity().onConnectivityChanged;

  static Future<bool> isOnline() async {
    final res = await Connectivity().checkConnectivity();
    return res != ConnectivityResult.none;
  }
}
