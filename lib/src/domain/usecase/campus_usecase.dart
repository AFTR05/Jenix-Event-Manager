import 'package:either_dart/either.dart';
import 'package:jenix_event_manager/src/core/exceptions/failure.dart';
import 'package:jenix_event_manager/src/domain/entities/campus_entity.dart';
import 'package:jenix_event_manager/src/domain/repository/campus_repository.dart';

class CampusUsecase {
  final CampusRepository _campusRepository;

  CampusUsecase(this._campusRepository);

  Future<Either<Failure, CampusEntity>> createCampus({
    required String name,
    required String state,
    required String token,
  }) {
    return _campusRepository.createCampus(
      name: name,
      state: state,
      token: token,
    );
  }

  Future<Either<Failure, List<CampusEntity>>> getAllCampuses({
    required String token,
  }) {
    return _campusRepository.getAllCampuses(token: token);
  }

  Future<Either<Failure, CampusEntity>> getCampusById({
    required String id,
    required String token,
  }) {
    return _campusRepository.getCampusById(id: id, token: token);
  }

  Future<Either<Failure, bool>> updateCampus({
    required String id,
    required String name,
    required String state,
    required bool isActive,
    required String token,
  }) {
    return _campusRepository.updateCampus(
      id: id,
      name: name,
      state: state,
      token: token,
    );
  }

  Future<Either<Failure, bool>> deleteCampus({
    required String id,
    required String token,
  }) {
    return _campusRepository.deleteCampus(id: id, token: token);
  }
}
