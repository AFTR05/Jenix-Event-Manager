import 'package:either_dart/either.dart';
import 'package:jenix_event_manager/src/core/exceptions/failure.dart';
import 'package:jenix_event_manager/src/domain/entities/room_entity.dart';

abstract class RoomRepository {
  Future<Either<Failure, RoomEntity>> createRoom({
    required String type,
    required int capacity,
    String? state,
    List<String>? equipment,
    required String campusId,
    required String token,
  });

  Future<Either<Failure, List<RoomEntity>>> getAllRooms({
    required String token,
  });

  Future<Either<Failure, bool>> updateRoom({
    required String id,
    required String type,
    required int capacity,
    String? state,
    List<String>? equipment,
    required String campusId,
    required String token,
  });

  Future<Either<Failure, bool>> deleteRoom({required String id, required String token});

  Future<Either<Failure, RoomEntity>> getRoomById({required String id, required String token});
}