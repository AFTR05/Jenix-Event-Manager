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

    print('📤 CREATE Organizer Request: $path/create/organizer');
    print('   Body: $body');

    final resultRequest = await ConsumerAPI.requestJSON<Map<String, dynamic>>(
      url: '$path/create/organizer',
      method: HTTPMethod.post,
      headers: _getHeaders(token: token, includeContentType: true),
      jsonObject: body,
    );

    if (resultRequest.isRight) {
      final userData = resultRequest.right;
      print('✅ CREATE Organizer Success: ${userData['email']}');
      return Right(UserEntity.fromMap(userData));
    } else {
      print('❌ CREATE Organizer Failed: ${resultRequest.left}');
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

    print('📤 UPDATE User Request: $path');
    print('   Headers: ${_getHeaders(token: token, includeContentType: true)}');
    print('   Body: $body');

    final resultRequest = await ConsumerAPI.requestJSON<Map<String, dynamic>>(
      url: path,
      method: HTTPMethod.patch,
      headers: _getHeaders(token: token, includeContentType: true),
      jsonObject: body,
    );

    if (resultRequest.isRight) {
      final userData = resultRequest.right;
      print('✅ UPDATE User Success: ${userData['email']}');
      return Right(UserEntity.fromMap(userData));
    } else {
      print('❌ UPDATE User Failed: ${resultRequest.left}');
      return Left(UsersException());
    }
  }

  @override
  Future<Either<Failure, UserEntity>> promoteToOrganizer({
    required String email,
    required String token,
  }) async {
    print(
      '📤 PROMOTE User to Organizer Request: $path/promote/organizer?email=$email',
    );

    final url = Uri.encodeFull('$path/promote/organizer?email=$email');

    final resultRequest = await ConsumerAPI.requestJSON<Map<String, dynamic>>(
      url: url,
      method: HTTPMethod.patch,
      headers: _getHeaders(token: token, includeContentType: true),
    );

    if (resultRequest.isRight) {
      final userData = resultRequest.right;
      print('✅ PROMOTE User to Organizer Success: ${userData['email']}');
      return Right(UserEntity.fromMap(userData));
    } else {
      print('❌ PROMOTE User to Organizer Failed: ${resultRequest.left}');
      return Left(UsersException());
    }
  }

  @override
  Future<Either<Failure, bool>> deleteUser({
    required String userId,
    required String token,
  }) async {
    print('📤 DELETE User Request: $path/$userId');

    final resultRequest = await ConsumerAPI.requestJSON<Map<String, dynamic>>(
      url: '$path/$userId',
      method: HTTPMethod.delete,
      headers: _getHeaders(token: token),
    );

    if (resultRequest.isRight) {
      print('✅ DELETE User Success');
      return Right(resultRequest.isRight);
    } else {
      print('❌ DELETE User Failed: ${resultRequest.left}');
      return Left(UsersException());
    }
  }
}
