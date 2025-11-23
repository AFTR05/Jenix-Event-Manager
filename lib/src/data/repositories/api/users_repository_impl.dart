import 'package:either_dart/either.dart';
import 'package:jenix_event_manager/src/core/exceptions/failure.dart';
import 'package:jenix_event_manager/src/core/exceptions/users_exception.dart';
import 'package:jenix_event_manager/src/data/sources/http/consumer_api.dart';
import 'package:jenix_event_manager/src/domain/entities/user_entity.dart';
import 'package:jenix_event_manager/src/domain/repository/users_repository.dart';

class UsersRepositoryImpl implements UsersRepository {
  String get path {
    return "http://localhost:3000/api/v1/user";
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
  Future<Either<Failure, UserEntity>> createOrganizer({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String documentNumber,
    required String token,
  }) async {
    final body = <String, dynamic>{
      'email': email,
      'password': password,
      'name': name,
      'phone': phone,
      'documentNumber': documentNumber,
    };
    final resultRequest = await ConsumerAPI.requestJSON<Map<String, dynamic>>(
      url: '$path/create/organizer',
      method: HTTPMethod.post,
      headers: _getHeaders(token: token, includeContentType: true),
      jsonObject: body,
    );

    if (resultRequest.isRight) {
      final userData = resultRequest.right;
      return Right(UserEntity.fromMap(userData));
    } else {
      return Left(UsersException());
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateUser({
    required String userId,
    required String? name,
    required String? phone,
    required String? documentNumber,
    required String token,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (phone != null) body['phone'] = phone;
    if (documentNumber != null) body['documentNumber'] = documentNumber;
    final resultRequest = await ConsumerAPI.requestJSON<Map<String, dynamic>>(
      url: path,
      method: HTTPMethod.patch,
      headers: _getHeaders(token: token, includeContentType: true),
      jsonObject: body,
    );

    if (resultRequest.isRight) {
      final userData = resultRequest.right;
      return Right(UserEntity.fromMap(userData));
    } else {
      return Left(UsersException());
    }
  }

  @override
  Future<Either<Failure, UserEntity>> promoteToOrganizer({
    required String email,
    required String token,
  }) async {
    final url = Uri.encodeFull('$path/promote/organizer?email=$email');

    final resultRequest = await ConsumerAPI.requestJSON<Map<String, dynamic>>(
      url: url,
      method: HTTPMethod.patch,
      headers: _getHeaders(token: token, includeContentType: true),
    );

    if (resultRequest.isRight) {
      final userData = resultRequest.right;
      return Right(UserEntity.fromMap(userData));
    } else {
      return Left(UsersException());
    }
  }

  @override
  Future<Either<Failure, bool>> deleteUser({
    required String userId,
    required String token,
  }) async {
    final resultRequest = await ConsumerAPI.requestJSON<Map<String, dynamic>>(
      url: '$path/$userId',
      method: HTTPMethod.delete,
      headers: _getHeaders(token: token),
    );

    if (resultRequest.isRight) {
      return Right(resultRequest.isRight);
    } else {
      return Left(UsersException());
    }
  }

  @override
  Future<Either<Failure, List<UserEntity>>> getAllUsers({
    required int page,
    required int limit,
    required String token,
  }) async {
    final url = '$path?page=$page&limit=$limit';
    final resultRequest = await ConsumerAPI.requestJSON<dynamic>(
      url: url,
      method: HTTPMethod.get,
      headers: _getHeaders(token: token),
    );

    if (resultRequest.isRight) {
      final responseData = resultRequest.right;
      List<dynamic> usersList = [];
      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('data')) {
          usersList = responseData['data'] as List<dynamic>? ?? [];
        } else if (responseData.containsKey('users')) {
          usersList = responseData['users'] as List<dynamic>? ?? [];
        }
      } else if (responseData is List<dynamic>) {
        usersList = responseData;
      }

      final users = usersList
          .map((u) => UserEntity.fromMap(u as Map<String, dynamic>))
          .toList();
      return Right(users);
    } else {
      return Left(UsersException());
    }
  }
}
