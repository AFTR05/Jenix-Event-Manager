import 'package:either_dart/src/either.dart';
import 'package:jenix_event_manager/src/core/exceptions/campus_exception.dart';
import 'package:jenix_event_manager/src/core/exceptions/failure.dart';
import 'package:jenix_event_manager/src/data/sources/http/consumer_api.dart';
import 'package:jenix_event_manager/src/domain/entities/campus_entity.dart';
import 'package:jenix_event_manager/src/domain/repository/campus_repository.dart';

class CampusRepositoryImpl implements CampusRepository {
  String get path {
    return "http://localhost:3000/api/v1/campus";
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

  @override
  Future<Either<Failure, CampusEntity>> createCampus({
    required String name,
    required String state,
    required String token,
  }) async {
    print('📤 CREATE Campus Request: $path');
    print('   Body: {"name": "$name", "state": "$state"}');
    
    final resultRequest = await ConsumerAPI.requestJSON<Map<String, dynamic>>(
      url: path,
      method: HTTPMethod.post,
      headers: _getHeaders(token: token, includeContentType: true),
      jsonObject: {"name": name, "state": state},
    );
    
    if (resultRequest.isRight) {
      final campusData = resultRequest.right;
      print('✅ CREATE Campus Success: ${campusData['id']}');
      return Right(CampusEntity.fromJson(campusData));
    } else {
      print('❌ CREATE Campus Failed: ${resultRequest.left}');
      return Left(CampusException());
    }
  }

  @override
  Future<Either<Failure, bool>> deleteCampus({required String id, required String token}) async {
    print('📤 DELETE Campus Request: $path/$id');
    
    final resultRequest = await ConsumerAPI.requestJSON<Map<String, dynamic>>(
      url: "$path/$id",
      method: HTTPMethod.delete,
      headers: _getHeaders(token: token),
    );
    
    if (resultRequest.isRight) {
      print('✅ DELETE Campus Success');
      return Right(true);
    } else {
      print('❌ DELETE Campus Failed: ${resultRequest.left}');
      return Left(CampusException());
    }
  }

  @override
  Future<Either<Failure, List<CampusEntity>>> getAllCampuses({required String token}) async {
    print('📤 GET All Campus Request: $path');
    
    final resultRequest = await ConsumerAPI.requestJSON<List<dynamic>>(
      url: path,
      method: HTTPMethod.get,
      headers: _getHeaders(token: token),
    );
    
    if (resultRequest.isRight) {
      final campusesData = resultRequest.right;
      print('✅ GET All Campus Success: ${campusesData.length} items');
      return Right(campusesData.map((e) => CampusEntity.fromJson(e)).toList());
    } else {
      print('❌ GET All Campus Failed: ${resultRequest.left}');
      return Left(CampusException());
    }
  }

  @override
  Future<Either<Failure, CampusEntity>> getCampusById({required String id, required String token}) async {
    final resultRequest = await ConsumerAPI.requestJSON<Map<String, dynamic>>(
      url: "$path/$id",
      method: HTTPMethod.get,
      headers: _getHeaders(token: token),
    );
    if (resultRequest.isRight) {
      final campusData = resultRequest.right;
      return Right(CampusEntity.fromJson(campusData));
    } else {
      return Left(CampusException());
    }
  }

  @override
  Future<Either<Failure, bool>> updateCampus({
    required String id,
    required String name,
    required String state,
    required String token,
  }) async {
    print('📤 UPDATE Campus Request: $path/$id');
    print('   Headers: ${_getHeaders(token: token, includeContentType: true)}');
    print('   Body: {"name": "$name", "state": "$state"}');
    
    final resultRequest = await ConsumerAPI.requestJSON<Map<String, dynamic>>(
      url: "$path/$id",
      method: HTTPMethod.patch,
      headers: _getHeaders(token: token, includeContentType: true),
      jsonObject: {
        "name": name,
        "state": state
      },
    );
    
    if (resultRequest.isRight) {
      print('✅ UPDATE Campus Success');
      return Right(true);
    } else {
      print('❌ UPDATE Campus Failed: ${resultRequest.left}');
      return Left(CampusException());
    }
  }
}
