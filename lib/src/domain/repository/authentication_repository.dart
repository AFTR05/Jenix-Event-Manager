import 'package:either_dart/either.dart';
import 'package:jenix_event_manager/src/core/exceptions/failure.dart';
import 'package:jenix_event_manager/src/domain/entities/user_entity.dart';

abstract class AuthenticationRepository {
  Future<Either<Failure, UserEntity>> logIn({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String role,
  });

  Future<Either<Failure, bool>> logOut({
    required String accessToken
  });

  Future<Either<Failure, UserEntity>> getUserInformation({
    required String accessToken
  });

    Future<Either<Failure, UserEntity>> refreshToken({
        required String refreshToken
    });
}
