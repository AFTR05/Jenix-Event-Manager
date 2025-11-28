import 'package:either_dart/either.dart';
import 'package:jenix_event_manager/src/core/exceptions/failure.dart';
import 'package:jenix_event_manager/src/domain/entities/enrollment_entity.dart';
import 'package:jenix_event_manager/src/domain/repository/enrollment_repository.dart';

class EnrollmentUsecase {
  final EnrollmentRepository _enrollmentRepository;

  EnrollmentUsecase(this._enrollmentRepository);

  /// Crear nueva inscripción a un evento
  Future<Either<Failure, EnrollmentEntity>> createEnrollment({
    required String eventId,
    required String token,
  }) {
    return _enrollmentRepository.createEnrollment(
      eventId: eventId,
      token: token,
    );
  }

  /// Cancelar una inscripción
  Future<Either<Failure, bool>> cancelEnrollment({
    required String enrollmentId,
    required String token,
  }) {
    return _enrollmentRepository.cancelEnrollment(
      enrollmentId: enrollmentId,
      token: token,
    );
  }

  /// Obtener mis inscripciones
  Future<Either<Failure, List<EnrollmentEntity>>> getMyEnrollments({
    required String token,
  }) {
    return _enrollmentRepository.getMyEnrollments(token: token);
  }

  /// Obtener inscripciones de un evento
  Future<Either<Failure, List<EnrollmentEntity>>> getEnrollmentsByEvent({
    required String eventId,
    required String token,
  }) {
    return _enrollmentRepository.getEnrollmentsByEvent(
      eventId: eventId,
      token: token,
    );
  }
}