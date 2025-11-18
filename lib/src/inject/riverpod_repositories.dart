import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jenix_event_manager/src/data/repositories/api/authentication_repository_impl.dart';
import 'package:jenix_event_manager/src/data/repositories/api/event_repository_impl.dart';
import 'package:jenix_event_manager/src/data/repositories/api/campus_repository_impl.dart';
import 'package:jenix_event_manager/src/data/repositories/api/room_repository_impl.dart';
import 'package:jenix_event_manager/src/data/repositories/api/users_repository_impl.dart';

import 'package:jenix_event_manager/src/domain/repository/authentication_repository.dart';
import 'package:jenix_event_manager/src/domain/repository/campus_repository.dart';
import 'package:jenix_event_manager/src/domain/repository/event_repository.dart';
import 'package:jenix_event_manager/src/domain/repository/room_repository.dart';
import 'package:jenix_event_manager/src/domain/repository/users_repository.dart';

import 'package:jenix_event_manager/src/inject/riverpod_sources.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'riverpod_repositories.g.dart';

@riverpod
AuthenticationRepository authenticationRepository(Ref ref) {
  return AuthenticationRepositoryImpl(
    apiSource: ref.watch(jenixSourceProvider),
  );
}

@riverpod
CampusRepository campusRepository(Ref ref) {
  return CampusRepositoryImpl();
}

@riverpod
RoomRepository roomRepository(Ref ref) {
  return RoomRepositoryImpl();
}

@riverpod
EventRepository eventRepository(Ref ref) {
  return EventRepositoryImpl();
}

@riverpod
UsersRepository usersRepository(Ref ref) {
  return UsersRepositoryImpl();
}