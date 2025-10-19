import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jenix_event_manager/src/data/repositories/api/authentication_repository_impl.dart';
import 'package:jenix_event_manager/src/domain/repository/authentication_repository.dart';
import 'package:jenix_event_manager/src/inject/riverpod_sources.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'riverpod_repositories.g.dart';

@riverpod
AuthenticationRepository authenticationRepository(Ref ref) {
  return AuthenticationRepositoryImpl(
      apiSource: ref.watch(jenixSourceProvider));
}
