import 'package:either_dart/either.dart';
import 'package:jenix_event_manager/src/core/exceptions/failure.dart';
import 'package:jenix_event_manager/src/domain/entities/room_entity.dart';
import 'package:jenix_event_manager/src/domain/repository/room_repository.dart';

class RoomUsecase {
  final RoomRepository _roomRepository;

  RoomUsecase(this._roomRepository);

  Future<Either<Failure, RoomEntity>> createRoom({
    required String type,
    required int capacity,
    String? state,
    List<String>? equipment,
    required String campusId,
    required String token,
  }) {
    return _roomRepository.createRoom(
      type: type,
      capacity: capacity,
      state: state,
      equipment: equipment,
      campusId: campusId,
      token: token,
    );
  }

  Future<Either<Failure, List<RoomEntity>>> getAllRooms({
    required String token,
  }) {
    return _roomRepository.getAllRooms(token: token);
  }

  Future<Either<Failure, RoomEntity>> getRoomById({
    required String id,
    required String token,
  }) {
    return _roomRepository.getRoomById(id: id, token: token);
  }

  Future<Either<Failure, bool>> updateRoom({
    required String id,
    required String type,
    required int capacity,
    String? state,
    List<String>? equipment,
    required String campusId,
    required String token,
  }) {
    return _roomRepository.updateRoom(
      id: id,
      type: type,
      capacity: capacity,
      state: state,
      equipment: equipment,
      campusId: campusId,
      token: token,
    );
  }

  Future<Either<Failure, bool>> deleteRoom({
    required String id,
    required String token,
  }) {
    return _roomRepository.deleteRoom(id: id, token: token);
  }
}