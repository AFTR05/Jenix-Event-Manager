import 'dart:async';
import 'package:either_dart/either.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jenix_event_manager/src/core/exceptions/failure.dart';
import 'package:jenix_event_manager/src/core/exceptions/server_http_exception.dart';
import 'package:jenix_event_manager/src/domain/entities/enrollment_entity.dart';
import 'package:jenix_event_manager/src/domain/entities/user_entity.dart';
import 'package:jenix_event_manager/src/domain/usecase/enrollment_usecase.dart';
import 'package:jenix_event_manager/src/inject/riverpod_presentation.dart';
import 'package:jenix_event_manager/src/inject/states_providers/login_provider.dart';

class EnrollmentController {
  final EnrollmentUsecase enrollmentUsecase;
  final Ref ref;

  // Stream broadcasting the current list of enrollments.
  final _enrollmentsController = StreamController<List<EnrollmentEntity>>.broadcast();
  Stream<List<EnrollmentEntity>> get enrollmentsStream => _enrollmentsController.stream;

  final List<EnrollmentEntity> _cache = [];

  EnrollmentController({required this.enrollmentUsecase, required this.ref}) {
    _enrollmentsController.add([]);
  }

  void dispose() {
    _enrollmentsController.close();
  }

  List<EnrollmentEntity> get cachedEnrollments => List.unmodifiable(_cache);

  void _notifyListeners() {
    _enrollmentsController.add(List.unmodifiable(_cache));
  }

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

  /// Helper que intenta ejecutar la acción con el token actual. Si falla con 401,
  /// refresca el token y reintenta con el nuevo token.
  Future<Either<Failure, T>> _callWithAuthRetry<T>(
    Future<Either<Failure, T>> Function(String token) action,
    String token,
  ) async {
    final effectiveToken = ref.read(loginProviderProvider)?.accessToken ?? token;
    final res = await action(effectiveToken);

    if (res.isLeft && res.left is ServerHttpException) {
      final serverEx = res.left as ServerHttpException;
      if (serverEx.response.statusCode == 401) {
        await refreshToken();
        final newToken = ref.read(loginProviderProvider)?.accessToken ?? effectiveToken;
        return await action(newToken);
      }
    }

    return res;
  }

  /// Inscribirse a un evento
  Future<Either<Failure, EnrollmentEntity>> enrollInEvent(String eventId, String token) async {
    return await _callWithAuthRetry<EnrollmentEntity>(
      (t) => enrollmentUsecase.createEnrollment(
        eventId: eventId,
        token: t,
      ),
      token,
    );
  }

  /// Inscribirse y agregar al cache
  Future<Either<Failure, EnrollmentEntity>> enrollInEventAndCache(String eventId, String token) async {
    final res = await enrollInEvent(eventId, token);
    if (res.isRight) {
      _cache.add(res.right);
      _notifyListeners();
    }
    return res;
  }

  /// Cancelar inscripción
  Future<Either<Failure, bool>> cancelEnrollment(String enrollmentId, String token) async {
    return await _callWithAuthRetry<bool>(
      (t) => enrollmentUsecase.cancelEnrollment(
        enrollmentId: enrollmentId,
        token: t,
      ),
      token,
    );
  }

  /// Cancelar y eliminar del cache
  Future<Either<Failure, bool>> cancelEnrollmentAndCache(String enrollmentId, String token) async {
    final res = await cancelEnrollment(enrollmentId, token);
    if (res.isRight && res.right) {
      _cache.removeWhere((e) => e.id == enrollmentId);
      _notifyListeners();
    }
    return res;
  }

  /// Obtener mis inscripciones
  Future<Either<Failure, List<EnrollmentEntity>>> getMyEnrollments(String token) async {
    return await _callWithAuthRetry<List<EnrollmentEntity>>(
      (t) => enrollmentUsecase.getMyEnrollments(token: t),
      token,
    );
  }

  /// Obtener mis inscripciones y cachear
  Future<Either<Failure, List<EnrollmentEntity>>> getMyEnrollmentsAndCache(String token) async {
    final res = await getMyEnrollments(token);
    if (res.isRight) {
      _cache
        ..clear()
        ..addAll(res.right);
      _notifyListeners();
    }
    return res;
  }

  /// Obtener inscripciones de un evento
  Future<Either<Failure, List<EnrollmentEntity>>> getEnrollmentsByEvent(String eventId, String token) async {
    return await _callWithAuthRetry<List<EnrollmentEntity>>(
      (t) => enrollmentUsecase.getEnrollmentsByEvent(
        eventId: eventId,
        token: t,
      ),
      token,
    );
  }
}
