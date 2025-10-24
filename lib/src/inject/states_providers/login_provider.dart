
import 'package:jenix_event_manager/src/domain/entities/user_entity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'login_provider.g.dart';

@Riverpod(keepAlive: true)
class LoginProvider extends _$LoginProvider {
  @override
  UserEntity? build() {
    return null;
  }

  void setState(UserEntity? newValue) {
    state = newValue;
  }

  UserEntity? getUser() {
    return ref.read(loginProviderProvider);
  }
}
