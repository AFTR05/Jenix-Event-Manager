import 'dart:convert';

import 'package:either_dart/either.dart';
import 'package:http/http.dart' as http;
import 'package:jenix_event_manager/src/core/exceptions/failure.dart';
import 'package:jenix_event_manager/src/core/exceptions/no_data_exception.dart';
import 'package:jenix_event_manager/src/core/exceptions/unknown_exception.dart';
import 'package:jenix_event_manager/src/core/helpers/json_utils.dart';
import 'package:jenix_event_manager/src/core/exceptions/server_http_exception.dart';
import 'package:jenix_event_manager/src/inject/states_providers/general_states/internet_connection_provider.dart';enum HTTPMethod {
  get,
  post,
  put,
  patch,
  delete;

  String getName() {
    switch (this) {
      case HTTPMethod.get:
        return "GET";

      case HTTPMethod.post:
        return "POST";

      case HTTPMethod.put:
        return "PUT";

      case HTTPMethod.patch:
        return "PATCH";

      case HTTPMethod.delete:
        return "DELETE";
    }
  }
}

class ConsumerAPI {
  // Default timeout restored to the original value used in the project.
  static const timeoutDurationDefault = Duration(minutes: 2);

  static Map<String, String>? _sanitizeHeaders(Map<String, String>? headers) {
    if (headers == null) return null;
    final out = <String, String>{};
    for (final entry in headers.entries) {
      final k = entry.key.trim();
      if (k.isEmpty) continue;
      var v = entry.value.toString();
      v = v.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');
      v = v.trim();
      if (v.isEmpty) continue;
      out[k] = v;
    }
    return out.isEmpty ? null : out;
  }

  static bool isValidStatus({required http.Response response}) {
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  static Future<bool> _validateInternet() async {
    return await JenixInternetConnection.hasInternetConnection;
  }

  static Future<Either<Failure, String>> getData({
    required String url,
    Map<String, String>? headers,
    bool validateNetwork = true,
    Duration timeout = timeoutDurationDefault,
  }) async {
    try {
      if (validateNetwork) {
        if (!(await _validateInternet())) {
          return Left(NoDataException());
        }
      }
  final safeHeaders = _sanitizeHeaders(headers);
  final futureResponse = http.get(Uri.parse(url), headers: safeHeaders);
  final response = await futureResponse.timeout(timeout);

      if (isValidStatus(response: response)) {
        return Right(
          response.body,
        );
      } else {
        return Left(
          ServerHttpException(
            response: response,
          ),
        );
      }
    } on Exception catch (e) {
      return Left(
        UnknownException(
          error: e,
        ),
      );
    }
  }

  static Future<Either<Failure, String>> processData({
    required String url,
    HTTPMethod method = HTTPMethod.post,
    Object? params,
    Map<String, String>? headers,
    Encoding? encoding,
    bool validateNetwork = true,
    Duration timeout = timeoutDurationDefault,
  }) async {
    try {
      if (validateNetwork) {
        if (!(await _validateInternet())) {
          return Left(NoDataException());
        }
      }
      http.Response response;

      switch (method) {
            case HTTPMethod.get:
              return getData(
                url: url,
                headers: headers,
                validateNetwork: validateNetwork,
                timeout: timeout,
              );
            case HTTPMethod.post:
          final safeHeaders = _sanitizeHeaders(headers);
      final futurePost = http.post(Uri.parse(url), headers: safeHeaders, body: params, encoding: encoding);
      response = await futurePost.timeout(timeout);
          break;
            case HTTPMethod.put:
        final safeHeaders = _sanitizeHeaders(headers);
    final futurePut = http.put(Uri.parse(url), headers: safeHeaders, body: params, encoding: encoding);
  response = await futurePut.timeout(timeout);
          break;
            case HTTPMethod.patch:
        final safeHeaders = _sanitizeHeaders(headers);
    final futurePatch = http.patch(Uri.parse(url), headers: safeHeaders, body: params, encoding: encoding);
  response = await futurePatch.timeout(timeout);
          break;
            case HTTPMethod.delete:
        final safeHeaders = _sanitizeHeaders(headers);
    final futureDelete = http.delete(Uri.parse(url), headers: safeHeaders, body: params, encoding: encoding);
  response = await futureDelete.timeout(timeout);
          break;
      }

      if (isValidStatus(response: response)) {
        return Right(response.body);
      } else {
        return Left(
          ServerHttpException(
            response: response,
          ),
        );
      }
    } on Exception catch (e) {
      return Left(
        UnknownException(
          error: e,
        ),
      );
    }
  }

  /// 🔹 Convierte un mapa en una cadena `application/x-www-form-urlencoded`
  static String convertToURLEncoded(Map<String, dynamic> data) {
    return data.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');
  }

  /// 🔹 Realiza una petición con `application/x-www-form-urlencoded`
  static Future<Either<Failure, T>> requestFormURLEncoded<T>({
    required String url,
    required Map<String, dynamic> formData,
    HTTPMethod method = HTTPMethod.post,
    Map<String, String>? headers,
    bool validateNetwork = true,
    Duration? timeout,
  }) async {
    try {
      final sanitized = _sanitizeHeaders(headers) ?? <String, String>{};
      if (!sanitized.containsKey("Content-Type")) {
        sanitized["Content-Type"] = "application/x-www-form-urlencoded";
      }

      final String encodedParams = convertToURLEncoded(formData);

      final response = await processData(
        url: url,
        method: method,
        params: encodedParams,
        headers: sanitized,
        validateNetwork: validateNetwork,
        timeout: timeout ?? timeoutDurationDefault,
      );

      if (response.isRight) {
        final jsonResponse =
            JSONUtils.getObjectFromStringJSON(jsonString: response.right);
        if (jsonResponse is T) {
          return Right(jsonResponse);
        } else {
          return Left(
            UnknownException(
              error: Exception("JSON Error"),
            ),
          );
        }
      } else {
        return Left(response.left);
      }
    } on Exception catch (e) {
      return Left(
        UnknownException(
          error: e,
        ),
      );
    }
  }

  static Future<Either<Failure, T>> requestJSON<T>({
    required String url,
    HTTPMethod method = HTTPMethod.post,
    dynamic jsonObject,
    Map<String, String>? headers,
    bool isJSONRequestBody = true,
    bool validateNetwork = true,
    Duration? timeout,
  }) async {
    try {
      dynamic params;
      Map<String, String>? safeHeaders = _sanitizeHeaders(headers);

      // Only send a JSON body when the caller provided a non-null jsonObject.
      // If jsonObject is null we avoid sending the literal string "null" as body
      // and we also avoid forcing Content-Type: application/json.
      if (isJSONRequestBody && jsonObject != null) {
        params = JSONUtils.getJSONFromObject(jsonObject: jsonObject);
        safeHeaders = safeHeaders ?? <String, String>{};
        if (!safeHeaders.containsKey("Content-Type")) {
          safeHeaders["Content-Type"] = "application/json";
        }
      }

      final response = await processData(
        url: url,
        method: method,
        params: params,
        headers: safeHeaders,
        validateNetwork: validateNetwork,
        timeout: timeout ?? timeoutDurationDefault,
      );
      if (response.isRight) {
        final jsonResponse =
            JSONUtils.getObjectFromStringJSON(jsonString: response.right);
        if (jsonResponse is T) {
          return Right(jsonResponse);
        } else {
          return Left(
            UnknownException(
              error: Exception("JSON Error"),
            ),
          );
        }
      } else {
        return Left(response.left);
      }
    } on Exception catch (e) {
      return Left(
        UnknownException(
          error: e,
        ),
      );
    }
  }

  static Future<Either<Failure, T>> requestMultipartJSON<T>({
    required String url,
    HTTPMethod method = HTTPMethod.post,
    required Map<String, String> params,
    Map<String, String>? headers,
    bool validateNetwork = true,
    Duration? timeout,
  }) async {
    if (validateNetwork) {
      if (!(await _validateInternet())) {
        return Left(NoDataException());
      }
    }
    var request = http.MultipartRequest(method.getName(), Uri.parse(url));
    request.fields.addAll(params);
    final safe = _sanitizeHeaders(headers);
    if (safe != null) {
      request.headers.addAll(safe);
    }
    try {
    final sendFuture = request.send();
  final effectiveTimeout = timeout ?? timeoutDurationDefault;
  http.StreamedResponse response = await sendFuture.timeout(effectiveTimeout);

      if (response.statusCode == 200) {
        final responseString = await response.stream.bytesToString();
        final jsonResponse =
            JSONUtils.getObjectFromStringJSON(jsonString: responseString);
        if (jsonResponse is T) {
          return Right(jsonResponse);
        } else {
          return Left(
            UnknownException(
              error: Exception("JSON Error"),
            ),
          );
        }
      } else {
        return Left(
          UnknownException(
            error: Exception(response.reasonPhrase),
          ),
        );
      }
    } on Exception catch (e) {
      return Left(
        UnknownException(
          error: e,
        ),
      );
    }
  }
}
