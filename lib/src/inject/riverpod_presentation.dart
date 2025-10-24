
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jenix_event_manager/src/inject/riverpod_usecase.dart';
import 'package:jenix_event_manager/src/presentation/controllers/auth/authentication_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'riverpod_presentation.g.dart';


@riverpod
AuthenticationController authenticationController(Ref ref){
  return AuthenticationController(
    ref: ref,
    authenticationUsecase: ref.watch(authenticationUsecaseProvider),
  );
}