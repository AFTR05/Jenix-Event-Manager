import 'package:either_dart/either.dart';
import 'package:jenix_event_manager/src/core/exceptions/failure.dart';
import 'package:jenix_event_manager/src/domain/entities/enrollment_entity.dart';

abstract class EnrollmentRepository {
  /// Crear un nuevo enrollment (inscripción)
  Future<Either<Failure, EnrollmentEntity>> createEnrollment({
    required String eventId,
    required String token,
  });

  /// Cancelar un enrollment
  Future<Either<Failure, bool>> cancelEnrollment({
    required String enrollmentId,
    required String token,
  });

  /// Obtener enrollments del usuario actual
  Future<Either<Failure, List<EnrollmentEntity>>> getMyEnrollments({
    required String token,
  });

  /// Obtener enrollments de un evento específico
  Future<Either<Failure, List<EnrollmentEntity>>> getEnrollmentsByEvent({
    required String eventId,
    required String token,
  });
}