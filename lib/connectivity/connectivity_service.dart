import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  // Check for actual internet access
  Future<bool> hasInternetAccess() async {
    try {
      final result = await http.get(Uri.parse('https://google.com')).timeout(
        const Duration(seconds: 10),
      );
      return result.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Stream<bool> get onConnectivityChanged async* {
    await for (final result in _connectivity.onConnectivityChanged) {
      if (result != ConnectivityResult.none) {
        yield await hasInternetAccess();
      } else {
        yield false;
      }
    }
  }

  Future<bool> isConnected() async {
    final result = await _connectivity.checkConnectivity();
    if (result != ConnectivityResult.none) {
      return await hasInternetAccess();
    }
    return false;
  }
}
