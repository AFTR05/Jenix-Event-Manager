import 'package:either_dart/either.dart';
import 'package:jenix_event_manager/src/core/exceptions/failure.dart';
import 'package:jenix_event_manager/src/domain/entities/user_entity.dart';
import 'package:jenix_event_manager/src/domain/repository/authentication_repository.dart';

class AuthenticationUsecase {
  final AuthenticationRepository authenticationRepository;

  AuthenticationUsecase({required this.authenticationRepository});

  Future<Either<Failure, UserEntity>> logIn({
    required String email,
    required String password,
  }) {
    return authenticationRepository.logIn(email: email, password: password);
  }

  Future<Either<Failure, UserEntity>> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String documentNumber
  }) {
    return authenticationRepository.signUp(
      email: email,
      password: password,
      name: name,
      phone: phone,
      documentNumber: documentNumber
    );
  }

  Future<Either<Failure, bool>> logOut({required String accessToken}) {
    return authenticationRepository.logOut(accessToken: accessToken);
  }

  Future<Either<Failure, UserEntity>> getUserInformation({
    required String accessToken,
  }) {
    return authenticationRepository.getUserInformation(accessToken: accessToken);
  }

  Future<Either<Failure, UserEntity>> refreshToken({
    required String refreshToken,
  }) {
    return authenticationRepository.refreshToken(refreshToken: refreshToken);
  }
}
