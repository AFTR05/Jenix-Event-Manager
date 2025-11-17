import 'package:either_dart/either.dart';
import 'package:jenix_event_manager/src/core/exceptions/failure.dart';
import 'package:jenix_event_manager/src/domain/entities/event_entity.dart';

abstract class EventRepository {
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
  });

  Future<Either<Failure, List<EventEntity>>> getAllEvents({
    required String token,
  });

  Future<Either<Failure, EventEntity>> getEventById({
    required String id,
    required String token,
  });

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
  });

  Future<Either<Failure, bool>> deleteEvent({
    required String id,
    required String token,
  });
}
