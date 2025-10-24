import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jenix_event_manager/src/domain/usecase/authentication_usecase.dart';
import 'package:jenix_event_manager/src/inject/riverpod_repositories.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'riverpod_usecase.g.dart';

@riverpod
AuthenticationUsecase authenticationUsecase(Ref ref){
  return AuthenticationUsecase(authenticationRepository: ref.watch(authenticationRepositoryProvider));
}