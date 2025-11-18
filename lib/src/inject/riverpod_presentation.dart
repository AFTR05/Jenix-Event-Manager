import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jenix_event_manager/src/inject/riverpod_usecase.dart';
import 'package:jenix_event_manager/src/presentation/controllers/auth/authentication_controller.dart';
import 'package:jenix_event_manager/src/presentation/controllers/campus_controller.dart';
import 'package:jenix_event_manager/src/presentation/controllers/event_controller.dart';
import 'package:jenix_event_manager/src/presentation/controllers/room_controller.dart';
import 'package:jenix_event_manager/src/presentation/controllers/users_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'riverpod_presentation.g.dart';

@riverpod
AuthenticationController authenticationController(Ref ref){
  return AuthenticationController(
    ref: ref,
    authenticationUsecase: ref.watch(authenticationUsecaseProvider),
  );
}

@riverpod
CampusController campusController(Ref ref){
  return CampusController(
    ref: ref,
    campusUsecase: ref.watch(campusUsecaseProvider),
  );
}

@riverpod
RoomController roomController(Ref ref){
  return RoomController(
    ref: ref,
    roomUsecase: ref.watch(roomUsecaseProvider),
  );
}

@riverpod
EventController eventController(Ref ref) {
  return EventController(
    ref: ref,
    usecase: ref.watch(eventUsecaseProvider),
  );
}


@riverpod
UsersController usersController(Ref ref) {
  return UsersController(
    ref: ref,
    usersUsecase: ref.watch(usersUsecaseProvider),
  );
}
