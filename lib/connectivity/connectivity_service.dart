import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:io';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  Future<bool> isConnected() async {
    var connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    }

    // Check actual internet access by trying to reach google.com
    return await _hasInternetAccess();
  }

  Future<bool> _hasInternetAccess() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }
}
