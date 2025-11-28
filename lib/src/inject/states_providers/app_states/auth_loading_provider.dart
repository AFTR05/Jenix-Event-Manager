// lib/src/inject/auth_loading_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_loading_provider.g.dart';

@Riverpod(keepAlive: true)
class AuthLoading extends _$AuthLoading {
  @override
  bool build() => false;

  void set(bool value) => state = value;
  void start() => state = true;
  void stop() => state = false;
}
