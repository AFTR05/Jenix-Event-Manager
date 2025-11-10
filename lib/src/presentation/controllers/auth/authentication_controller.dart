import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:either_dart/either.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jenix_event_manager/src/core/exceptions/failure.dart';
import 'package:jenix_event_manager/src/domain/entities/user_entity.dart';
import 'package:jenix_event_manager/src/domain/usecase/authentication_usecase.dart';
import 'package:jenix_event_manager/src/inject/riverpod_usecase.dart';
import 'package:jenix_event_manager/src/inject/states_providers/login_provider.dart';

class AuthenticationController {
  final AuthenticationUsecase authenticationUsecase;
  final Ref ref;

  // SharedPreferences keys
  static const String _keyRememberMe = 'remember_me';
  static const String _keyUserData = 'user_data';

  AuthenticationController({
    required this.authenticationUsecase,
    required this.ref,
  });

  // ========== HELPER METHODS ==========

  /// Save user session to SharedPreferences
  Future<void> _saveUserEntity(UserEntity user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserData, user.toJson());
  }

  /// Get saved user from SharedPreferences
  Future<UserEntity?> _getSavedUserEntity() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_keyUserData);
    if (userJson == null || userJson.isEmpty) return null;

    try {
      return UserEntity.fromJson(userJson);
    } catch (e) {
      await prefs.remove(_keyUserData);
      return null;
    }
  }

  Future<void> saveSession({
    required UserEntity user,
    required bool rememberMe,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyRememberMe, rememberMe);

    if (rememberMe) {
      await _saveUserEntity(user);
    }
  }

  /// Clear all session data
  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyRememberMe);
    await prefs.remove(_keyUserData);
  }

  /// Check if remember me is enabled
  Future<bool> _getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyRememberMe) ?? false;
  }

  UserEntity _mergeUserWithInfo(UserEntity base, UserEntity? info) {
    if (info == null) return base;
    String chooseString(String a, String b) => b.isNotEmpty ? b : a;

    String? chooseToken(String? a, String? b) {
      if (b != null && b.isNotEmpty) return b;
      return a;
    }

    return base.copyWith(
      email: chooseString(base.email, info.email),
      name: chooseString(base.name, info.name),
      phone: chooseString(base.phone, info.phone),
      role: chooseString(base.role, info.role),
      accessToken: chooseToken(base.accessToken, info.accessToken),
      refreshToken: chooseToken(base.refreshToken, info.refreshToken),
    );
  }

  // ========== PUBLIC METHODS ==========

  /// Get current logged user from loginProvider
  UserEntity? getCurrentUser() {
    return ref.read(loginProviderProvider);
  }

  /// Login with email and password
  Future<Either<Failure, UserEntity>> logIn({
    required String email,
    required String password,
    bool rememberMe = true,
  }) async {
    final either = await authenticationUsecase.logIn(
      email: email,
      password: password,
    );

    await either.fold((failure) async => null, (user) async {
      final userInfoResult = await authenticationUsecase.getUserInformation(
        accessToken: user.accessToken ?? '',
      );
      UserEntity finalUser = _mergeUserWithInfo(
        user,
        userInfoResult.isRight ? userInfoResult.right : null,
      );
      ref.read(loginProviderProvider.notifier).setState(finalUser);
      await saveSession(user: finalUser, rememberMe: rememberMe);
    });

    return either;
  }

  /// Register new user
  Future<Either<Failure, UserEntity>> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String role,
    bool rememberMe = true,
  }) async {
    final either = await authenticationUsecase.register(
      email: email,
      password: password,
      name: name,
      phone: phone,
      role: role,
    );

    await either.fold((failure) async => null, (user) async {
      final userInfoResult = await authenticationUsecase.getUserInformation(
        accessToken: user.accessToken ?? '',
      );
      UserEntity finalUser = _mergeUserWithInfo(
        user,
        userInfoResult.isRight ? userInfoResult.right : null,
      );
      ref.read(loginProviderProvider.notifier).setState(finalUser);
      await saveSession(user: finalUser, rememberMe: rememberMe);
    });

    return either;
  }

  /// Logout and clear session
  Future<Either<Failure, bool>> logOut() async {
    final currentUser = getCurrentUser();
    final accessToken = currentUser?.accessToken;

    Either<Failure, bool> result;

    if (accessToken != null) {
      result = await authenticationUsecase.logOut(accessToken: accessToken);
    } else {
      result = const Right(true);
    }

    if (result.isLeft) {
      return result;
    }

    await _clearSession();
    ref.read(loginProviderProvider.notifier).setState(null);

    return result;
  }

  /// Manually refresh token
  Future<Either<Failure, UserEntity>> refreshToken({
    required String refreshToken,
  }) async {
    final either = await authenticationUsecase.refreshToken(
      refreshToken: refreshToken,
    );

    await either.fold((failure) async => null, (user) async {
      final userInfoResult = await authenticationUsecase.getUserInformation(
        accessToken: user.accessToken ?? '',
      );
      UserEntity finalUser = _mergeUserWithInfo(
        user,
        userInfoResult.isRight ? userInfoResult.right : null,
      );
      ref.read(loginProviderProvider.notifier).setState(finalUser);
      // Update saved session with new tokens
      final rememberMe = await _getRememberMe();
      await saveSession(user: finalUser, rememberMe: rememberMe);
    });

    return either;
  }

  /// Check if user is logged and restore session if remember me is enabled
  Future<bool> isLoggedUser() async {
    final rememberMe = await _getRememberMe();
    if (!rememberMe) return false;

    // Try to get saved user entity
    final savedUser = await _getSavedUserEntity();
    if (savedUser == null) {
      await _clearSession();
      return false;
    }

    // If user has refresh token, try to refresh the session
    if (savedUser.refreshToken != null && savedUser.refreshToken!.isNotEmpty) {
      final result = await authenticationUsecase.refreshToken(
        refreshToken: savedUser.refreshToken!,
      );

      return result.fold(
        (failure) async {
          final userInfoResult = await authenticationUsecase.getUserInformation(
            accessToken: savedUser.accessToken ?? '',
          );
          final finalUser = _mergeUserWithInfo(
            savedUser,
            userInfoResult.isRight ? userInfoResult.right : null,
          );
          ref.read(loginProviderProvider.notifier).setState(finalUser);
          return true;
        },
        (refreshedUser) async {
          final userInfoResult = await authenticationUsecase.getUserInformation(
            accessToken: refreshedUser.accessToken ?? '',
          );
          final finalUser = _mergeUserWithInfo(
            refreshedUser,
            userInfoResult.isRight ? userInfoResult.right : null,
          );
          ref.read(loginProviderProvider.notifier).setState(finalUser);
          await _saveUserEntity(finalUser);
          return true;
        },
      );
    }

    // No refresh token, just restore saved user
    ref.read(loginProviderProvider.notifier).setState(savedUser);
    return true;
  }
}

final authenticationControllerProvider = Provider<AuthenticationController>((
  ref,
) {
  final usecase = ref.read(authenticationUsecaseProvider);
  return AuthenticationController(authenticationUsecase: usecase, ref: ref);
});
