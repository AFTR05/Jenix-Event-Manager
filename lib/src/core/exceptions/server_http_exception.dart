
import 'package:http/http.dart' as http;
import 'package:jenix_event_manager/src/core/exceptions/failure.dart';

class ServerHttpException extends Failure {
  http.Response response;

  ServerHttpException({
    required this.response,
  });

  @override
  String get message {
    return response.body;
  }
}
