import 'package:either_dart/either.dart';
import 'package:jenix_event_manager/src/core/exceptions/failure.dart';
import 'package:jenix_event_manager/src/domain/entities/campus_entity.dart';

abstract class CampusRepository {
  Future<Either<Failure, CampusEntity>> createCampus({
    required String name,
    required String state,
    required String token,
  });

  Future<Either<Failure, List<CampusEntity>>> getAllCampuses({
    required String token,
  });

  Future<Either<Failure, bool>> updateCampus({
    required String id,
    required String name,
    required String state,
    required String token,
  });

  Future<Either<Failure, bool>> deleteCampus({required String id, required String token});

  Future<Either<Failure, CampusEntity>> getCampusById({required String id, required String token});
}
