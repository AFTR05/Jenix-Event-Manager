import 'package:either_dart/either.dart';
import 'package:jenix_event_manager/src/core/exceptions/failure.dart';

abstract class APISource {
  String path();
  Future<Map<String, String>> headers();

  Future<Either<Failure, List<dynamic>>> getObjectsByKeyMap(
      {required String url, required String keyData});

  Future<Either<Failure, List<dynamic>>> getObjectsByKeyMapWithPagination({
    required String url,
    required String keyData,
    required String numberPagesKey,
    int limit = 1000,
    int actualPage = 1,
  });

  Future<String> get urlImage;
}
