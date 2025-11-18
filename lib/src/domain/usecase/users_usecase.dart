import 'package:either_dart/either.dart';
import 'package:jenix_event_manager/src/core/exceptions/failure.dart';
import 'package:jenix_event_manager/src/domain/entities/user_entity.dart';
import 'package:jenix_event_manager/src/domain/repository/users_repository.dart';

class UsersUsecase {
  final UsersRepository _usersRepository;
  UsersUsecase({
    required UsersRepository usersRepository,
  }) : _usersRepository = usersRepository;

  /// Crear un nuevo usuario organizador
  Future<Either<Failure, UserEntity>> createOrganizer({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String documentNumber,
    required String token,
  }) async {
    return await _usersRepository.createOrganizer(
      email: email,
      password: password,
      name: name,
      phone: phone,
      documentNumber: documentNumber,
      token: token,
    );
  }

  /// Actualizar datos del usuario actual
  Future<Either<Failure, UserEntity>> updateUser({
    required String userId,
    required String? name,
    required String? phone,
    required String? documentNumber,
    required String token,
  }) async {
    return await _usersRepository.updateUser(
      userId: userId,
      name: name,
      phone: phone,
      documentNumber: documentNumber,
      token: token,
    );
  }

  /// Promover un usuario a organizador por email
  Future<Either<Failure, UserEntity>> promoteToOrganizer({
    required String email,
    required String token,
  }) async {
    return await _usersRepository.promoteToOrganizer(
      email: email,
      token: token,
    );
  }

  /// Eliminar un usuario
  Future<Either<Failure, bool>> deleteUser({
    required String userId,
    required String token,
  }) async {
    return await _usersRepository.deleteUser(
      userId: userId,
      token: token,
    );
  }
}