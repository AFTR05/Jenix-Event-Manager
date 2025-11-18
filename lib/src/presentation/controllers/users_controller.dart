import 'package:either_dart/either.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jenix_event_manager/src/core/exceptions/failure.dart';
import 'package:jenix_event_manager/src/core/exceptions/server_http_exception.dart';
import 'package:jenix_event_manager/src/domain/entities/user_entity.dart';
import 'package:jenix_event_manager/src/domain/usecase/users_usecase.dart';
import 'package:jenix_event_manager/src/inject/riverpod_presentation.dart';
import 'package:jenix_event_manager/src/inject/states_providers/login_provider.dart';

class UsersController {
  final UsersUsecase usersUsecase;
  final Ref ref;

  UsersController({
    required this.usersUsecase,
    required this.ref,
  });

  Future<void> refreshToken() async {
    final user = ref.read(loginProviderProvider);
    final refreshResult = await ref.read(authenticationControllerProvider).refreshToken(
      refreshToken: user?.refreshToken ?? '',
    );

    if (refreshResult.isRight) {
      final newUser = refreshResult.right;
      UserEntity updatedUser = newUser.copyWith(
        phone: user?.phone,
        name: user?.name,
        email: user?.email,
        role: user?.role,
        accessToken: newUser.accessToken,
        refreshToken: newUser.refreshToken,
      );
      ref.read(loginProviderProvider.notifier).setState(updatedUser);
      await ref.read(authenticationControllerProvider).saveSession(
        user: updatedUser,
        rememberMe: true,
      );
    }
  }

  /// Helper that tries the provided [action] with the current token. If the
  /// request fails with a ServerHttpException and statusCode == 401, it will
  /// refresh the token once and retry the [action] with the new token.
  Future<Either<Failure, T>> _callWithAuthRetry<T>(
    Future<Either<Failure, T>> Function(String token) action,
    String token,
  ) async {
    final effectiveToken = ref.read(loginProviderProvider)?.accessToken ?? token;
    final res = await action(effectiveToken);

    if (res.isLeft && res.left is ServerHttpException) {
      final serverEx = res.left as ServerHttpException;
      if (serverEx.response.statusCode == 401) {
        // Try refresh once
        await refreshToken();
        final newToken = ref.read(loginProviderProvider)?.accessToken ?? effectiveToken;
        return await action(newToken);
      }
    }

    return res;
  }

  /// Crear un nuevo usuario organizador
  Future<Either<Failure, UserEntity>> createOrganizer({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String documentNumber,
    required String token,
  }) async {
    return await _callWithAuthRetry<UserEntity>(
      (t) => usersUsecase.createOrganizer(
        email: email,
        password: password,
        name: name,
        phone: phone,
        documentNumber: documentNumber,
        token: t,
      ),
      token,
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
    return await _callWithAuthRetry<UserEntity>(
      (t) => usersUsecase.updateUser(
        userId: userId,
        name: name,
        phone: phone,
        documentNumber: documentNumber,
        token: t,
      ),
      token,
    );
  }

  /// Promover un usuario a organizador por email
  Future<Either<Failure, UserEntity>> promoteToOrganizer({
    required String email,
    required String token,
  }) async {
    return await _callWithAuthRetry<UserEntity>(
      (t) => usersUsecase.promoteToOrganizer(
        email: email,
        token: t,
      ),
      token,
    );
  }

  /// Eliminar un usuario
  Future<Either<Failure, bool>> deleteUser({
    required String userId,
    required String token,
  }) async {
    return await _callWithAuthRetry<bool>(
      (t) => usersUsecase.deleteUser(
        userId: userId,
        token: t,
      ),
      token,
    );
  }
}