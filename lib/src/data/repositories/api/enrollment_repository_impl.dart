import 'package:either_dart/either.dart';
import 'package:jenix_event_manager/src/core/exceptions/failure.dart';
import 'package:jenix_event_manager/src/core/exceptions/enrollment_exception.dart';
import 'package:jenix_event_manager/src/data/sources/http/consumer_api.dart';
import 'package:jenix_event_manager/src/domain/entities/enrollment_entity.dart';
import 'package:jenix_event_manager/src/domain/entities/enum/enrollment_status_enum.dart';
import 'package:jenix_event_manager/src/domain/repository/enrollment_repository.dart';

class EnrollmentRepositoryImpl implements EnrollmentRepository {
  @override
  Future<Either<Failure, EnrollmentEntity>> createEnrollment({
    required String eventId,
    required String token,
  }) async {
    final body = <String, dynamic>{'eventId': eventId};

    print('📤 CREATE Enrollment Request: $path');
    print('   Body: $body');

    final resultRequest = await ConsumerAPI.requestJSON<Map<String, dynamic>>(
      url: '$path/create',
      method: HTTPMethod.post,
      headers: _getHeaders(token: token, includeContentType: true),
      jsonObject: body,
    );

    if (resultRequest.isRight) {
      final enrollmentData = resultRequest.right;
      print('✅ CREATE Enrollment Success: ${enrollmentData['id']}');
      return Right(EnrollmentEntity.fromJson(enrollmentData));
    } else {
      print('❌ CREATE Enrollment Failed: ${resultRequest.left}');
      return Left(EnrollmentException());
    }
  }

  @override
  Future<Either<Failure, bool>> cancelEnrollment({
    required String enrollmentId,
    required String token,
  }) async {
    print('📤 CANCEL Enrollment Request: $path/cancel/$enrollmentId');

    final resultRequest = await ConsumerAPI.requestJSON<Map<String, dynamic>>(
      url: '$path/cancel/$enrollmentId',
      method: HTTPMethod.patch,
      headers: _getHeaders(token: token),
    );

    if (resultRequest.isRight) {
      print('✅ CANCEL Enrollment Success');
      return Right(true);
    } else {
      print('❌ CANCEL Enrollment Failed: ${resultRequest.left}');
      return Left(EnrollmentException());
    }
  }

  @override
  Future<Either<Failure, List<EnrollmentEntity>>> getMyEnrollments({
    required String token,
  }) async {
    print('📤 GET My Enrollments Request: $path/my-enrollments');

    final resultRequest = await ConsumerAPI.requestJSON<List<dynamic>>(
      url: '$path/my-enrollments',
      method: HTTPMethod.get,
      headers: _getHeaders(token: token),
    );

    if (resultRequest.isRight) {
      final enrollmentsData = resultRequest.right;
      print('✅ GET My Enrollments Success: ${enrollmentsData.length} items');
      return Right(enrollmentsData.map((e) => EnrollmentEntity.fromJson(e as Map<String, dynamic>)).toList());
    } else {
      print('❌ GET My Enrollments Failed: ${resultRequest.left}');
      return Left(EnrollmentException());
    }
  }

  @override
  Future<Either<Failure, List<EnrollmentEntity>>> getEnrollmentsByEvent({
    required String eventId,
    required String token,
  }) async {
    print('📤 GET Enrollments by Event Request: $path/by-event/$eventId');

    final resultRequest = await ConsumerAPI.requestJSON<Map<String, dynamic>>(
      url: '$path/by-event/$eventId',
      method: HTTPMethod.get,
      headers: _getHeaders(token: token),
    );

    if (resultRequest.isRight) {
      try {
        final responseData = resultRequest.right;
        final enrollmentsListRaw = responseData['enrollments'] as List<dynamic>? ?? [];
        
        final enrollmentsList = enrollmentsListRaw.map((e) {
          final enrollmentMap = e as Map<String, dynamic>;
          final userMap = enrollmentMap['user'] as Map<String, dynamic>?;
          
          // Convertir la estructura de respuesta a EnrollmentEntity
          return EnrollmentEntity(
            id: enrollmentMap['enrollmentId'] as String,
            userId: userMap?['id'] as String?,
            eventId: responseData['eventId'] as String?,
            status: EnrollmentStatus.fromString(enrollmentMap['status'] as String),
            enrollmentDate: DateTime.parse(enrollmentMap['enrollmentDate'] as String),
            cancelledAt: null,
          );
        }).toList();

        print('✅ GET Enrollments by Event Success: ${enrollmentsList.length} items');
        return Right(enrollmentsList);
      } catch (e) {
        print('❌ GET Enrollments by Event Parsing Error: $e');
        return Right([]); // Retornar lista vacía en caso de error de parsing
      }
    } else {
      // Si es error 404 o ENROLLMENT_NOT_FOUND, retornar lista vacía
      final error = resultRequest.left;
      print('⚠️ GET Enrollments by Event Failed: $error');
      print('⚠️ Returning empty list instead of error');
      return Right([]);
    }
  }

  String get path {
    return 'http://localhost:3000/api/v1/enrollments';
  }

  Map<String, String> _getHeaders({
    required String token,
    bool includeContentType = false,
  }) {
    final headers = {'Authorization': 'Bearer $token'};
    if (includeContentType) {
      headers['Content-Type'] = 'application/json';
    }
    return headers;
  }
}