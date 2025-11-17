import 'dart:async';
import 'package:either_dart/either.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jenix_event_manager/src/core/exceptions/failure.dart';
import 'package:jenix_event_manager/src/core/exceptions/server_http_exception.dart';
import 'package:jenix_event_manager/src/domain/entities/event_entity.dart';
import 'package:jenix_event_manager/src/domain/entities/user_entity.dart';
import 'package:jenix_event_manager/src/domain/usecase/event_usecase.dart';
import 'package:jenix_event_manager/src/inject/states_providers/login_provider.dart';
import 'package:jenix_event_manager/src/inject/riverpod_presentation.dart';

class EventController {
  final EventUsecase usecase;
  final Ref ref;

  final _eventsController = StreamController<List<EventEntity>>.broadcast();
  Stream<List<EventEntity>> get eventsStream => _eventsController.stream;

  final List<EventEntity> _cache = [];

  EventController({required this.usecase, required this.ref}) {
    _eventsController.add([]);
  }

  void dispose() {
    _eventsController.close();
  }

  void _notify() {
    _eventsController.add(List.unmodifiable(_cache));
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

  Future<Either<Failure, T>> _authRetry<T>(
    Future<Either<Failure, T>> Function(String token) action,
    String token,
  ) async {
    final effectiveToken = ref.read(loginProviderProvider)?.accessToken ?? token;
    final res = await action(effectiveToken);

    if (res.isLeft && res.left is ServerHttpException) {
      final ex = res.left as ServerHttpException;

      if (ex.response.statusCode == 401) {
        await refreshToken();
        final newToken = ref.read(loginProviderProvider)?.accessToken ?? effectiveToken;
        return await action(newToken);
      }
    }

    return res;
  }

  Future<Either<Failure, List<EventEntity>>> fetchAll(String token) async {
    final res = await getAllEvents(token);
    if (res.isRight) {
      _cache
        ..clear()
        ..addAll(res.right);
      _notify();
    }
    return res;
  }

  Future<Either<Failure, List<EventEntity>>> getAllEvents(String token) async {
    return await _authRetry<List<EventEntity>>(
      (t) => usecase.getAllEvents(token: t),
      token,
    );
  }

  Future<Either<Failure, EventEntity>> createEvent({
    required String name,
    String? beginHour,
    String? endHour,
    required String roomId,
    required String organizationArea,
    required String description,
    required String state,
    required String modality,
    required int maxAttendees,
    required String urlImage,
    required DateTime? initialDate,
    required DateTime? finalDate,
    required String token,
  }) async {
    return await _authRetry<EventEntity>(
      (t) => usecase.createEvent(
        name: name,
        beginHour: beginHour,
        endHour: endHour,
        roomId: roomId,
        organizationArea: organizationArea,
        description: description,
        state: state,
        modality: modality,
        maxAttendees: maxAttendees,
        urlImage: urlImage,
        initialDate: initialDate,
        finalDate: finalDate,
        token: t,
      ),
      token,
    );
  }

  Future<Either<Failure, EventEntity>> createAndCache({
    required String name,
    String? beginHour,
    String? endHour,
    required String roomId,
    required String organizationArea,
    required String description,
    required String state,
    required String modality,
    required int maxAttendees,
    required String urlImage,
    required DateTime? initialDate,
    required DateTime? finalDate,
    required String token,
  }) async {
    final res = await createEvent(
      name: name,
      beginHour: beginHour,
      endHour: endHour,
      roomId: roomId,
      organizationArea: organizationArea,
      description: description,
      state: state,
      modality: modality,
      maxAttendees: maxAttendees,
      urlImage: urlImage,
      initialDate: initialDate,
      finalDate: finalDate,
      token: token,
    );

    if (res.isRight) {
      _cache.add(res.right);
      _notify();
    }

    return res;
  }

  Future<Either<Failure, bool>> deleteEvent(String id, String token) async {
    return await _authRetry<bool>(
      (t) => usecase.deleteEvent(id: id, token: t),
      token,
    );
  }

  Future<Either<Failure, bool>> deleteAndCache(String id, String token) async {
    final res = await deleteEvent(id, token);

    if (res.isRight && res.right) {
      _cache.removeWhere((e) => e.id == id);
      _notify();
    }

    return res;
  }

  Future<Either<Failure, EventEntity>> getEventById(String id, String token) async {
    return await _authRetry<EventEntity>(
      (t) => usecase.getEventById(id: id, token: t),
      token,
    );
  }

  Future<Either<Failure, bool>> updateEvent({
    required String id,
    required String name,
    String? beginHour,
    String? endHour,
    required String roomId,
    required String organizationArea,
    required String description,
    required String state,
    required String modality,
    required int maxAttendees,
    required String urlImage,
    required DateTime? initialDate,
    required DateTime? finalDate,
    required String token,
  }) async {
    return await _authRetry<bool>(
      (t) => usecase.updateEvent(
        id: id,
        name: name,
        beginHour: beginHour,
        endHour: endHour,
        roomId: roomId,
        organizationArea: organizationArea,
        description: description,
        state: state,
        modality: modality,
        maxAttendees: maxAttendees,
        urlImage: urlImage,
        initialDate: initialDate,
        finalDate: finalDate,
        token: t,
      ),
      token,
    );
  }

  Future<Either<Failure, bool>> updateAndCache({
    required String id,
    required String name,
    String? beginHour,
    String? endHour,
    required String roomId,
    required String organizationArea,
    required String description,
    required String state,
    required String modality,
    required int maxAttendees,
    required String urlImage,
    required DateTime? initialDate,
    required DateTime? finalDate,
    required String token,
  }) async {
    final res = await updateEvent(
      id: id,
      name: name,
      beginHour: beginHour,
      endHour: endHour,
      roomId: roomId,
      organizationArea: organizationArea,
      description: description,
      state: state,
      modality: modality,
      maxAttendees: maxAttendees,
      urlImage: urlImage,
      initialDate: initialDate,
      finalDate: finalDate,
      token: token,
    );

    if (res.isRight && res.right) {
      final getRes = await getEventById(id, token);

      if (getRes.isRight) {
        final updated = getRes.right;
        final index = _cache.indexWhere((c) => c.id == id);

        if (index != -1) {
          _cache[index] = updated;
        } else {
          _cache.add(updated);
        }

        _notify();
      }
    }

    return res;
  }
}
