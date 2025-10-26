import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'internet_connection_provider.g.dart';

class JenixInternetConnection {
  // Puedes cambiar esta URL por tu propio endpoint /health (con CORS habilitado en web)
  static const String _pingUrl = 'https://httpbin.org/get';

  static Future<bool> get hasInternetConnection async {
    // The connectivity_plus API has evolved: some versions return a single
    // ConnectivityResult while newer ones may return a List<ConnectivityResult>
    // (multiple interfaces). Handle both shapes safely.
    final dynamic connectivity = await Connectivity().checkConnectivity();

    // If we got a single enum value
    if (connectivity is ConnectivityResult) {
      if (connectivity == ConnectivityResult.none) return false;
      return _httpPing();
    }

    // If we got a list of results (multiple interfaces)
    if (connectivity is List) {
      if (connectivity.isEmpty) return false;
      final bool allNone = connectivity.every((e) => e == ConnectivityResult.none);
      if (allNone) return false;
      return _httpPing();
    }

    // Fallback: be conservative and run the ping
    return _httpPing();
  }

  /// En web, DNS lookup no es soportado -> hacemos un GET rápido.
  static Future<bool> _httpPing() async {
    try {
      final http.Response r = await http
          .get(Uri.parse(_pingUrl))
          .timeout(const Duration(seconds: 3));
      // Considera red OK si no es 5xx (reduce falsos negativos)
      return r.statusCode < 500;
    } catch (_) {
      return false;
    }
  }

  /// Stream sin StreamGroup: cambios de conectividad + chequeo periódico
  static Stream<bool> get onStatusChange {
    late final StreamController<bool> controller;
    StreamSubscription<dynamic>? connSub;
    Timer? timer;

    Future<void> emit() async {
      final bool ok = await hasInternetConnection;
      if (!controller.isClosed) controller.add(ok);
    }

    controller = StreamController<bool>(
      onListen: () {
        // Estado inicial
        emit();

        // Cambios de red (wifi/móvil/ethernet…)
        connSub = Connectivity().onConnectivityChanged.listen((_) => emit());

        // Verificación periódica (por si cambia gateway/DNS sin evento)
        timer = Timer.periodic(const Duration(seconds: 10), (_) => emit());
      },
      onCancel: () async {
        await connSub?.cancel();
        timer?.cancel();
        await controller.close();
      },
    );

    return controller.stream;
    // Si necesitas múltiples listeners simultáneos, usa:
    // return controller.stream.asBroadcastStream();
  }
}

@Riverpod(keepAlive: true)
class InternetConnectionProvider extends _$InternetConnectionProvider {
  StreamSubscription<dynamic>? _subscription;

  @override
  FutureOr<bool> build() async {
    // Estado inicial
    return await JenixInternetConnection.hasInternetConnection;
  }

  void startListener() {
    _subscription = JenixInternetConnection.onStatusChange.listen((bool isOnline) {
      state = AsyncData<bool>(isOnline);
    });
  }

  void stopListener() {
    _subscription?.cancel();
  }

  /// Chequeo bajo demanda
  Future<bool> haveInternet() => JenixInternetConnection.hasInternetConnection;
}