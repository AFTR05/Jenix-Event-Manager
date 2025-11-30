import 'package:either_dart/either.dart';
import 'package:jenix_event_manager/src/core/exceptions/failure.dart';
import 'package:jenix_event_manager/src/domain/entities/event_entity.dart';
import 'package:jenix_event_manager/src/domain/repository/event_repository.dart';

class EventUsecase {
  final EventRepository repository;

  EventUsecase({required this.repository});

  Future<Either<Failure, EventEntity>> createEvent({
    required String name,
    String? beginHour,
    String? endHour,
    required String roomId,
    required String organizationArea,
    required String description,
    required String state,
    required String modality,
    required int maxAttendees,
    required String urlImage,
      required DateTime? initialDate,
    required DateTime? finalDate,
    required String token,
    required String responsiblePersonId,
  }) {
    return repository.createEvent(
      name: name,
      beginHour: beginHour,
      endHour: endHour,
      roomId: roomId,
      organizationArea: organizationArea,
      description: description,
      state: state,
      modality: modality,
      maxAttendees: maxAttendees,
      urlImage: urlImage,
      initialDate: initialDate,
      finalDate: finalDate,
      token: token,
      responsiblePersonId: responsiblePersonId,
    );
  }

  Future<Either<Failure, List<EventEntity>>> getAllEvents({required String token}) {
    return repository.getAllEvents(token: token);
  }

  Future<Either<Failure, EventEntity>> getEventById({
    required String id,
    required String token,
  }) {
    return repository.getEventById(id: id, token: token);
  }

  Future<Either<Failure, bool>> updateEvent({
    required String id,
    required String name,
    String? beginHour,
    String? endHour,
    required String roomId,
    required String organizationArea,
    required String description,
    required String state,
    required String modality,
    required int maxAttendees,
    required String urlImage,
    required String token,
      required DateTime? initialDate,
    required DateTime? finalDate,
  }) {
    return repository.updateEvent(
      id: id,
      name: name,
      beginHour: beginHour,
      endHour: endHour,
      roomId: roomId,
      organizationArea: organizationArea,
      description: description,
      state: state,
      modality: modality,
      maxAttendees: maxAttendees,
      urlImage: urlImage,
      token: token,
      initialDate: initialDate,
      finalDate: finalDate,
    );
  }

  Future<Either<Failure, bool>> deleteEvent({
    required String id,
    required String token,
  }) {
    return repository.deleteEvent(id: id, token: token);
  }
}
