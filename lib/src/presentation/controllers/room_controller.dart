import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:either_dart/either.dart';
import 'package:jenix_event_manager/src/core/exceptions/failure.dart';
import 'package:jenix_event_manager/src/domain/entities/room_entity.dart';
import 'package:jenix_event_manager/src/domain/usecase/room_usecase.dart';
import 'package:jenix_event_manager/src/inject/riverpod_presentation.dart';
import 'package:jenix_event_manager/src/inject/states_providers/login_provider.dart';
import 'package:jenix_event_manager/src/core/exceptions/server_http_exception.dart';
import 'package:jenix_event_manager/src/domain/entities/user_entity.dart';

class RoomController {
  final RoomUsecase roomUsecase;
  final Ref ref;

  // Stream broadcasting the current list of rooms.
  final _roomsController = StreamController<List<RoomEntity>>.broadcast();
  Stream<List<RoomEntity>> get roomsStream => _roomsController.stream;

  final List<RoomEntity> _cache = [];

  RoomController({required this.roomUsecase, required this.ref}) {
    _roomsController.add([]);
  }

  void dispose() {
    _roomsController.close();
  }

  List<RoomEntity> get cachedRooms => List.unmodifiable(_cache);

  void _notifyListeners() {
    _roomsController.add(List.unmodifiable(_cache));
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
      await ref.read(authenticationControllerProvider).saveSession(user: updatedUser, rememberMe: true);
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

  Future<Either<Failure, List<RoomEntity>>> fetchAllAndCache(String token) async {
    final res = await getAllRooms(token);
    if (res.isRight) {
      _cache
        ..clear()
        ..addAll(res.right);
      _notifyListeners();
    }
    return res;
  }

  Future<Either<Failure, List<RoomEntity>>> getAllRooms(String token) async {
    final effectiveToken = ref.read(loginProviderProvider)?.accessToken ?? token;
    final res = await roomUsecase.getAllRooms(token: effectiveToken);

    if (res.isLeft && res.left is ServerHttpException) {
      final serverEx = res.left as ServerHttpException;
      if (serverEx.response.statusCode == 401) {
        await refreshToken();
        final newToken = ref.read(loginProviderProvider)?.accessToken ?? effectiveToken;
        return await roomUsecase.getAllRooms(token: newToken);
      }
    }

    return res;
  }

  Future<Either<Failure, RoomEntity>> createRoom({
    required String type,
    required int capacity,
    String? state,
    List<String>? equipment,
    required String campusId,
    required String token,
  }) async {
    return await _callWithAuthRetry<RoomEntity>(
      (t) => roomUsecase.createRoom(
        type: type,
        capacity: capacity,
        state: state,
        equipment: equipment,
        campusId: campusId,
        token: t,
      ),
      token,
    );
  }

  Future<Either<Failure, RoomEntity>> createAndCache({
    required String type,
    required int capacity,
    String? state,
    List<String>? equipment,
    required String campusId,
    required String token,
  }) async {
    final res = await createRoom(
      type: type,
      capacity: capacity,
      state: state,
      equipment: equipment,
      campusId: campusId,
      token: token,
    );
    if (res.isRight) {
      _cache.add(res.right);
      _notifyListeners();
    }
    return res;
  }

  Future<Either<Failure, bool>> deleteRoom(String id, String token) async {
    return await _callWithAuthRetry<bool>(
      (t) => roomUsecase.deleteRoom(id: id, token: t),
      token,
    );
  }

  Future<Either<Failure, bool>> deleteAndCache(String id, String token) async {
    final res = await deleteRoom(id, token);
    if (res.isRight && res.right == true) {
      _cache.removeWhere((r) => r.id == id);
      _notifyListeners();
    }
    return res;
  }

  Future<Either<Failure, RoomEntity>> getRoomById(String id, String token) async {
    return await _callWithAuthRetry<RoomEntity>(
      (t) => roomUsecase.getRoomById(id: id, token: t),
      token,
    );
  }

  Future<Either<Failure, bool>> updateRoom({
    required String id,
    required String type,
    required int capacity,
    String? state,
    List<String>? equipment,
    required String campusId,
    required String token,
  }) async {
    return await _callWithAuthRetry<bool>(
      (t) => roomUsecase.updateRoom(
        id: id,
        type: type,
        capacity: capacity,
        state: state,
        equipment: equipment,
        campusId: campusId,
        token: t,
      ),
      token,
    );
  }

  Future<Either<Failure, bool>> updateAndCache({
    required String id,
    required String type,
    required int capacity,
    String? state,
    List<String>? equipment,
    required String campusId,
    required String token,
  }) async {
    final res = await updateRoom(
      id: id,
      type: type,
      capacity: capacity,
      state: state,
      equipment: equipment,
      campusId: campusId,
      token: token,
    );
    if (res.isRight && res.right == true) {
      final getRes = await getRoomById(id, token);
      if (getRes.isRight) {
        final updated = getRes.right;
        final index = _cache.indexWhere((c) => c.id == id);
        if (index != -1) {
          _cache[index] = updated;
        } else {
          _cache.add(updated);
        }
        _notifyListeners();
      }
    }
    return res;
  }
}