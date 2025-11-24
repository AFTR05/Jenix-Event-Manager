import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jenix_event_manager/src/domain/usecase/authentication_usecase.dart';
import 'package:jenix_event_manager/src/domain/usecase/campus_usecase.dart';
import 'package:jenix_event_manager/src/domain/usecase/enrollment_usecase.dart';
import 'package:jenix_event_manager/src/domain/usecase/room_usecase.dart';
import 'package:jenix_event_manager/src/domain/usecase/event_usecase.dart';
import 'package:jenix_event_manager/src/domain/usecase/users_usecase.dart';

import 'package:jenix_event_manager/src/inject/riverpod_repositories.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'riverpod_usecase.g.dart';

@riverpod
AuthenticationUsecase authenticationUsecase(Ref ref){
  return AuthenticationUsecase(
    authenticationRepository: ref.watch(authenticationRepositoryProvider),
  );
}

@riverpod
CampusUsecase campusUsecase(Ref ref) {
  return CampusUsecase(
    ref.watch(campusRepositoryProvider),
  );
}

@riverpod
RoomUsecase roomUsecase(Ref ref) {
  return RoomUsecase(
    ref.watch(roomRepositoryProvider),
  );
}

@riverpod
EventUsecase eventUsecase(Ref ref) {
  return EventUsecase(
    repository: ref.watch(eventRepositoryProvider),
  );
}

@riverpod
UsersUsecase usersUsecase(Ref ref) {
  return UsersUsecase(
    usersRepository: ref.watch(usersRepositoryProvider),
  );
}

@riverpod
EnrollmentUsecase enrollmentUsecase(Ref ref) {
  return EnrollmentUsecase(
    ref.watch(enrollmentRepositoryProvider),
  );
}
