import 'dart:async';
import 'dart:io';

import 'package:async/async.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'internet_connection_provider.g.dart';

class JenixInternetConnection {
  static Future<bool> get hasInternetConnection async {
    final connectivityResult = await Connectivity().checkConnectivity();

    return processConnection(connectivityResult: connectivityResult);
  }

  static Future<bool> processConnection({
    required List<ConnectivityResult> connectivityResult,
  }) async {
    if (connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi) ||
        connectivityResult.contains(ConnectivityResult.ethernet) ||
        connectivityResult.contains(ConnectivityResult.vpn) ||
        connectivityResult.contains(ConnectivityResult.other)) {
      return lookupConnection();
    }

    return false;
  }

  static Future<bool> lookupConnection() async {
    // Check if there's actual internet access
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {}

    return false;
  }

  static Stream<bool> get onStatusChange {
    final streamCon = Connectivity().onConnectivityChanged.asyncMap((result) => processConnection(connectivityResult: result));
    final streamTimer = Stream.periodic(const Duration(seconds: 10), (data) {}).asyncMap((e) => hasInternetConnection);
    final totalStream = StreamGroup.merge([streamCon, streamTimer]);
    return totalStream;
  }
}

@Riverpod(keepAlive: true)
class InternetConnectionProvider extends _$InternetConnectionProvider {
  StreamSubscription<bool>? _subscription;
  @override
  FutureOr<bool> build() async {
    return haveInternet();
  }

  Future<bool> haveInternet() async {
    return await JenixInternetConnection.hasInternetConnection;
  }

  void startListener() {
    _subscription = JenixInternetConnection.onStatusChange.listen((event) async {
      state = await AsyncValue.guard(() async {
        return event;
      });
    });
  }

  void stopListener() {
    _subscription?.cancel();
  }
}