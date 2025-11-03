import 'package:either_dart/either.dart';
import 'package:jenix_event_manager/src/core/exceptions/failure.dart';
import 'package:jenix_event_manager/src/core/exceptions/room_exception.dart';
import 'package:jenix_event_manager/src/data/sources/http/consumer_api.dart';
import 'package:jenix_event_manager/src/domain/entities/room_entity.dart';
import 'package:jenix_event_manager/src/domain/repository/room_repository.dart';

class RoomRepositoryImpl implements RoomRepository {
  @override
  Future<Either<Failure, RoomEntity>> createRoom({
    required String type,
    required int capacity,
    String? state,
    List<String>? equipment,
    required String campusId,
    required String token,
  }) async {
    final body = <String, dynamic>{
      'type': type,
      'capacity': capacity,
      'campusId': campusId,
    };
    if (state != null) body['state'] = state;
    if (equipment != null) body['equipment'] = equipment;

    print('📤 CREATE Room Request: $path');
    print('   Body: $body');

    final resultRequest = await ConsumerAPI.requestJSON<Map<String, dynamic>>(
      url: path,
      method: HTTPMethod.post,
      headers: _getHeaders(token: token, includeContentType: true),
      jsonObject: body,
    );

    if (resultRequest.isRight) {
      final roomData = resultRequest.right;
      print('✅ CREATE Room Success: ${roomData['id']}');
      return Right(RoomEntity.fromJson(roomData));
    } else {
      print('❌ CREATE Room Failed: ${resultRequest.left}');
      return Left(RoomException());
    }
  }
  
  @override
  Future<Either<Failure, bool>> deleteRoom({required String id, required String token}) {
    print('📤 DELETE Room Request: $path/$id');
    
    return ConsumerAPI.requestJSON<Map<String, dynamic>>(
      url: "$path/$id",
      method: HTTPMethod.delete,
      headers: _getHeaders(token: token),
    ).then((resultRequest) {
      if (resultRequest.isRight) {
        print('✅ DELETE Room Success');
        return Right(resultRequest.isRight);
      } else {
        print('❌ DELETE Room Failed: ${resultRequest.left}');
        return Left(RoomException());
      }
    });
  }
  
  @override
  Future<Either<Failure, List<RoomEntity>>> getAllRooms({required String token}) {
    print('📤 GET All Rooms Request: $path');
    
    return ConsumerAPI.requestJSON<List<dynamic>>(
      url: path,
      method: HTTPMethod.get,
      headers: _getHeaders(token: token),
    ).then((resultRequest) {
      if (resultRequest.isRight) {
        final roomsData = resultRequest.right;
        print('✅ GET All Rooms Success: ${roomsData.length} items');
        return Right(roomsData.map((e) => RoomEntity.fromJson(e)).toList());
      } else {
        print('❌ GET All Rooms Failed: ${resultRequest.left}');
        return Left(RoomException());
      }
    });
  }
  
  @override
  Future<Either<Failure, RoomEntity>> getRoomById({required String id, required String token}) {
    return ConsumerAPI.requestJSON<Map<String, dynamic>>(
      url: "$path/$id",
      method: HTTPMethod.get,
      headers: _getHeaders(token: token),
    ).then((resultRequest) {
      if (resultRequest.isRight) {
        final roomData = resultRequest.right;
        return Right(RoomEntity.fromJson(roomData));
      } else {
        return Left(RoomException());
      }
    });
  }
  
  @override
  Future<Either<Failure, bool>> updateRoom({
    required String id,
    required String type,
    required int capacity,
    String? state,
    List<String>? equipment,
    required String campusId,
    required String token,
  }) {
    final body = <String, dynamic>{
      'type': type,
      'capacity': capacity,
      'campusId': campusId,
    };
    if (state != null) body['state'] = state;
    if (equipment != null) body['equipment'] = equipment;

    print('📤 UPDATE Room Request: $path/$id');
    print('   Headers: ${_getHeaders(token: token, includeContentType: true)}');
    print('   Body: $body');

    return ConsumerAPI.requestJSON<Map<String, dynamic>>(
      url: "$path/$id",
      method: HTTPMethod.patch,
      headers: _getHeaders(token: token, includeContentType: true),
      jsonObject: body,
    ).then((resultRequest) {
      if (resultRequest.isRight) {
        print('✅ UPDATE Room Success');
        return Right(true);
      } else {
        print('❌ UPDATE Room Failed: ${resultRequest.left}');
        return Left(RoomException());
      }
    });
  }

  String get path {
    return "http://localhost:3000/api/v1/room";
  }

  Map<String, String> _getHeaders({
    required String token,
    bool includeContentType = false,
  }) {
    final headers = {"Authorization": "Bearer $token"};
    if (includeContentType) {
      headers["Content-Type"] = "application/json";
    }
    return headers;
  }
}