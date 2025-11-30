import 'package:either_dart/either.dart';
import 'package:jenix_event_manager/src/core/exceptions/failure.dart';
import 'package:jenix_event_manager/src/core/exceptions/event_exception.dart';
import 'package:jenix_event_manager/src/data/sources/http/consumer_api.dart';
import 'package:jenix_event_manager/src/domain/entities/event_entity.dart';
import 'package:jenix_event_manager/src/domain/repository/event_repository.dart';

class EventRepositoryImpl implements EventRepository {
  @override
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
  }) async {

    final body = {
      'name': name,
      'beginHour': beginHour,
      'endHour': endHour,
      'roomId': roomId,
      'organizationArea': organizationArea,
      'responsiblePersonId': responsiblePersonId,
      'description': description,
      'state': state,
      'modality': modality,
      'maxAttendees': maxAttendees,
      'urlImage': urlImage,
      'initialDate': initialDate?.toIso8601String(),
      'finalDate': finalDate?.toIso8601String(),
    };

    print("📤 CREATE Event Request: $path");
    print("   Body: $body");

    final res = await ConsumerAPI.requestJSON<Map<String, dynamic>>(
      url: path,
      method: HTTPMethod.post,
      headers: _headers(token, true),
      jsonObject: body,
    );

    if (res.isRight) {
      print("✅ CREATE Event Success");
      return Right(EventEntity.fromJson(res.right));
    } else {
      print("❌ CREATE Event Failed: ${res.left}");
      return Left(res.left);
    }
  }

  @override
  Future<Either<Failure, bool>> deleteEvent({
    required String id,
    required String token,
  }) async {
    final res = await ConsumerAPI.requestJSON<Map<String, dynamic>>(
      url: "$path/$id",
      method: HTTPMethod.delete,
      headers: _headers(token),
    );

    if (res.isRight) {
      print("✅ DELETE Event Success");
      return Right(true);
    } else {
      print("❌ DELETE Event Failed");
      return Left(EventException());
    }
  }

  @override
  Future<Either<Failure, List<EventEntity>>> getAllEvents({
    required String token,
  }) async {
    final res = await ConsumerAPI.requestJSON<List<dynamic>>(
      url: "$path/list",
      method: HTTPMethod.post,
      headers: _headers(token),
    );

    if (res.isRight) {
      final list = res.right.map((e) => EventEntity.fromJson(e)).toList();
      print("✅ GET All Events Success (${list.length})");
      return Right(list);
    } else {
      print("❌ GET All Events Failed");
      return Left(res.left);
    }
  }

  @override
  Future<Either<Failure, EventEntity>> getEventById({
    required String id,
    required String token,
  }) async {
    final res = await ConsumerAPI.requestJSON<Map<String, dynamic>>(
      url: "$path/$id",
      method: HTTPMethod.get,
      headers: _headers(token),
    );

    if (res.isRight) {
      return Right(EventEntity.fromJson(res.right));
    } else {
      return Left(res.left);
    }
  }

  @override
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
    required DateTime? initialDate,
    required DateTime? finalDate,
    required String token,
  }) async {
    final body = {
      'name': name,
      'beginHour': beginHour,
      'endHour': endHour,
      'roomId': roomId,
      'organizationArea': organizationArea,
      'description': description,
      'state': state,
      'modality': modality,
      'maxAttendees': maxAttendees,
      'urlImage': urlImage,
      'initialDate': initialDate?.toIso8601String(),
      'finalDate': finalDate?.toIso8601String(),
    };

    final res = await ConsumerAPI.requestJSON<Map<String, dynamic>>(
      url: "$path/$id",
      method: HTTPMethod.patch,
      headers: _headers(token, true),
      jsonObject: body,
    );

    if (res.isRight) {
      print("✅ UPDATE Event Success");
      return Right(true);
    } else {
      print("❌ UPDATE Event Failed: ${res.left}");
      return Left(res.left);
    }
  }

  String get path => "http://localhost:3000/api/v1/event";

  Map<String, String> _headers(String token, [bool json = false]) {
    final map = {"Authorization": "Bearer $token"};
    if (json) map["Content-Type"] = "application/json";
    return map;
  }
}
