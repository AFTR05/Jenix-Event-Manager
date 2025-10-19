import 'package:either_dart/src/either.dart';
import 'package:jenix_event_manager/src/core/exceptions/failure.dart';
import 'package:jenix_event_manager/src/data/sources/api_source.dart';
import 'package:jenix_event_manager/src/data/sources/http/consumer_api.dart';
import 'package:jenix_event_manager/src/domain/entities/user_entity.dart';
import 'package:jenix_event_manager/src/domain/repository/authentication_repository.dart';

class AuthenticationRepositoryImpl implements AuthenticationRepository {
  final APISource apiSource;
  AuthenticationRepositoryImpl({required this.apiSource});

  String get path {
    return "http://localhost:3000/api/v1/auth";
  }

  Map<String, String> _getHeaders({required String token, bool includeContentType = false}) {
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
  Future<Either<Failure, bool>> logOut({required String accessToken}) async {
    final url = "$path/logout";
    
    print("🔓 Logout - URL: $url");
    print("🔑 Logout - Token: ${accessToken.substring(0, 20)}...");
    
    // Usar processData en lugar de requestJSON porque el logout puede devolver respuesta vacía
    final resultRequest = await ConsumerAPI.processData(
      url: url,
      method: HTTPMethod.post,
      headers: _getHeaders(token: accessToken, includeContentType: true),
      params: null, // No enviar body
    );
    
    return resultRequest.fold(
      (failure) {
        print("❌ Logout - Error: ${failure.toString()}");
        return Left(failure);
      },
      (response) {
        print("✅ Logout - Success: $response");
        return const Right(true);
      },
    );
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
    required String role,
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
        "role": role,
      },
    );
    return resultRequest.fold((failure) => Left(failure), (json) {
      final Map<String, dynamic> userMap = Map<String, dynamic>.from(json);
      return Right(UserEntity.fromMap(userMap));
    });
  }
}
