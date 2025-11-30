import 'package:either_dart/either.dart';
import 'package:jenix_event_manager/src/core/exceptions/failure.dart';
import 'package:jenix_event_manager/src/data/sources/api_source.dart';
import 'package:jenix_event_manager/src/data/sources/http/consumer_api.dart';
import 'package:jenix_event_manager/src/domain/entities/enum/organization_area_enum.dart';
import 'package:jenix_event_manager/src/domain/entities/user_entity.dart';
import 'package:jenix_event_manager/src/domain/repository/authentication_repository.dart';

class AuthenticationRepositoryImpl implements AuthenticationRepository {
  final APISource apiSource;
  AuthenticationRepositoryImpl({required this.apiSource});

  String get path {
    return "http://localhost:3000/api/v1/auth";
  }

  Map<String, String> _getHeaders({
    required String token,
    bool includeContentType = false,
  }) {
    final headers = {"Authorization": "Bearer $token"};
    if (includeContentType) {
      headers["Content-Type"] = "application/json";
    }
    return headers;
  }

  @override
  Future<Either<Failure, UserEntity>> logIn({
    required String email,
    required String password,
  }) async {
    final url = "$path/local/login";
    final resultRequest = await ConsumerAPI.requestJSON<Map<String, dynamic>>(
      url: url,
      method: HTTPMethod.post,
      jsonObject: {"email": email, "password": password},
    );
    return resultRequest.fold((failure) => Left(failure), (json) {
      final Map<String, dynamic> userMap = Map<String, dynamic>.from(json);

      return Right(UserEntity.fromMap(userMap));
    });
  }

  @override
  Future<Either<Failure, UserEntity>> getUserInformation({
    required String accessToken,
  }) async {
    final url = "$path/me";
    final resultRequest = await ConsumerAPI.requestJSON<Map<String, dynamic>>(
      url: url,
      method: HTTPMethod.get,
      headers: _getHeaders(token: accessToken),
    );
    return resultRequest.fold((failure) => Left(failure), (json) {
      final Map<String, dynamic> userMap = Map<String, dynamic>.from(json);
      return Right(UserEntity.fromMap(userMap));
    });
  }

  @override
  Future<Either<Failure, bool>> logOut({required String accessToken}) async {
    final url = "$path/logout";
    // Use processData so we don't accidentally send a JSON body of "null"
    final resultRequest = await ConsumerAPI.requestJSON(
      url: url,
      method: HTTPMethod.post,
      jsonObject: {},
      headers: _getHeaders(token: accessToken),
    );

    return resultRequest.fold((failure) => Left(failure), (response) {
      //if (response['message'] == "Logout successful") {
      //  return const Right(true);
      //}
      if (response is bool) {
        return Right(response);
      }
      return const Right(true);
    });
  }

  @override
  Future<Either<Failure, UserEntity>> refreshToken({
    required String refreshToken,
  }) async {
    final url = "$path/refresh";
    final resultRequest = await ConsumerAPI.requestJSON<Map<String, dynamic>>(
      url: url,
      method: HTTPMethod.post,
      headers: _getHeaders(token: refreshToken),
    );
    return resultRequest.fold((failure) => Left(failure), (json) {
      final Map<String, dynamic> userMap = Map<String, dynamic>.from(json);
      return Right(UserEntity.fromMap(userMap));
    });
  }

  @override
  Future<Either<Failure, UserEntity>> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String documentNumber
  }) async {
    final url = "$path/local/signup";
    final resultRequest = await ConsumerAPI.requestJSON<Map<String, dynamic>>(
      url: url,
      method: HTTPMethod.post,
      jsonObject: {
        "email": email,
        "password": password,
        "name": name,
        "phone": phone,
        "documentNumber": documentNumber
      },
    );
    return resultRequest.fold((failure) => Left(failure), (json) {
      final Map<String, dynamic> userMap = Map<String, dynamic>.from(json);
      return Right(UserEntity.fromMap(userMap));
    });
  }
}
