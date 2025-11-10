import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:either_dart/either.dart';
import 'package:jenix_event_manager/src/core/exceptions/failure.dart';
import 'package:jenix_event_manager/src/domain/entities/campus_entity.dart';
import 'package:jenix_event_manager/src/domain/entities/enum/campus_status_enum.dart';
import 'package:jenix_event_manager/src/domain/entities/user_entity.dart';
import 'package:jenix_event_manager/src/domain/usecase/campus_usecase.dart';
import 'package:jenix_event_manager/src/inject/riverpod_presentation.dart';
import 'package:jenix_event_manager/src/inject/states_providers/login_provider.dart';
import 'package:jenix_event_manager/src/core/exceptions/server_http_exception.dart';

class CampusController {
  final CampusUsecase campusUsecase;
  final Ref ref;

  // Stream broadcasting the current list of campuses. UI can listen to this
  // for reactive updates instead of polling or manual refreshes.
  final _campusesController = StreamController<List<CampusEntity>>.broadcast();
  Stream<List<CampusEntity>> get campusesStream => _campusesController.stream;

  // Internal cache kept in sync with the stream.
  final List<CampusEntity> _cache = [];

  CampusController({required this.campusUsecase, required this.ref}) {
    // Emit initial empty state immediately so listeners can start watching.
    _campusesController.add([]);
  }

  void dispose() {
    _campusesController.close();
  }

  /// Returns an unmodifiable view of the cached campuses (synchronous fallback).
  List<CampusEntity> get cachedCampuses => List.unmodifiable(_cache);

  /// Pushes the current cache to all stream listeners.
  void _notifyListeners() {
    _campusesController.add(List.unmodifiable(_cache));
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
  /// Fetches all campuses from the backend and updates the cache + stream.
  Future<Either<Failure, List<CampusEntity>>> fetchAllAndCache(String token) async {
    final res = await getAllCampuses(token);
    if (res.isRight) {
      _cache
        ..clear()
        ..addAll(res.right);
      _notifyListeners();
    }
    return res;
  }

  Future<Either<Failure, CampusEntity>> createCampus(
      String name, CampusStatusEnum state, String token) async {
    return await _callWithAuthRetry<CampusEntity>(
      (t) => campusUsecase.createCampus(name: name, state: state.toText(), token: t),
      token,
    );
  }

  /// Create a campus and add it to the local cache + notify stream on success.
  Future<Either<Failure, CampusEntity>> createAndCache(
      String name, CampusStatusEnum state, String token) async {
    final res = await createCampus(name, state, token);
    if (res.isRight) {
      _cache.add(res.right);
      _notifyListeners();
    }
    return res;
  }

  Future<Either<Failure, bool>> deleteCampus(String id, String token) async {
    return await _callWithAuthRetry<bool>(
      (t) => campusUsecase.deleteCampus(id: id, token: t),
      token,
    );
  }

  /// Delete a campus and remove it from the cache + notify stream on success.
  Future<Either<Failure, bool>> deleteAndCache(String id, String token) async {
    final res = await deleteCampus(id, token);
    if (res.isRight && res.right == true) {
      _cache.removeWhere((c) => c.id == id);
      _notifyListeners();
    }
    return res;
  }

  Future<Either<Failure, List<CampusEntity>>> getAllCampuses(String token) async {
    return await _callWithAuthRetry<List<CampusEntity>>(
      (t) => campusUsecase.getAllCampuses(token: t),
      token,
    );
  }

  Future<Either<Failure, CampusEntity>> getCampusById(String id, String token) async {
    return await _callWithAuthRetry<CampusEntity>(
      (t) => campusUsecase.getCampusById(id: id, token: t),
      token,
    );
  }

  Future<Either<Failure, bool>> updateCampus(String id, String name,
      CampusStatusEnum state, bool isActive, String token) async {
    return await _callWithAuthRetry<bool>(
      (t) => campusUsecase.updateCampus(
        id: id,
        name: name,
        state: state.toText(),
        isActive: isActive,
        token: t,
      ),
      token,
    );
  }

  /// Update a campus and refresh it in the cache + notify stream on success.
  Future<Either<Failure, bool>> updateAndCache(String id, String name,
      CampusStatusEnum state, bool isActive, String token) async {
    final res = await updateCampus(id, name, state, isActive, token);
    if (res.isRight && res.right == true) {
      // The update endpoint returns a boolean. After a successful update,
      // fetch the latest campus data and update the cache entry.
      final getRes = await getCampusById(id, token);
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