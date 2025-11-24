import 'package:either_dart/either.dart';
import 'package:jenix_event_manager/src/core/exceptions/failure.dart';
import 'package:jenix_event_manager/src/domain/entities/user_entity.dart';

abstract class UsersRepository {
  Future<Either<Failure, UserEntity>> createOrganizer({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String documentNumber,
    required String token,
  });

  Future<Either<Failure, UserEntity>> updateUser({
    required String userId,
    required String? name,
    required String? phone,
    required String? documentNumber,
    required String token,
  });

  Future<Either<Failure, UserEntity>> promoteToOrganizer({
    required String email,
    required String token,
  });

  Future<Either<Failure, bool>> deleteUser({
    required String userId,
    required String token,
  });

  Future<Either<Failure, List<UserEntity>>> getAllUsers({
    required int page,
    required int limit,
    required String token,
  });
}
