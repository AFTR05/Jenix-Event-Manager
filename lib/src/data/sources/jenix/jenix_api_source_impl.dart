import 'package:either_dart/either.dart';
import 'package:jenix_event_manager/src/core/exceptions/failure.dart';
import 'package:jenix_event_manager/src/core/exceptions/no_data_exception.dart';
import 'package:jenix_event_manager/src/data/sources/api_source.dart';
import 'package:jenix_event_manager/src/data/sources/http/consumer_api.dart';
import 'package:jenix_event_manager/src/data/sources/key_source.dart';

class JenixAPISourceImpl extends APISource {
  final KeySource keySource;
  JenixAPISourceImpl({required this.keySource});

  @override
  Future<Map<String, String>> headers() async {
    final tokenObj =
        await keySource.getKeyValue(nameKey: "");
    if (tokenObj is String) {
      return {"Authentication": "Bearer $tokenObj"};
    }
    return {};
  }

  String get host => "https://apidev6.invupos.com";
  @override
  String path() {
    return "$host/invuApiPos/index.php";
  }

  String path2() {
    return "$host/invuApi/index.php";
  }

  @override
  Future<Either<Failure, List<dynamic>>> getObjectsByKeyMap(
      {required String url, required String keyData}) async {
    final response = await ConsumerAPI.requestJSON<Map<String, dynamic>>(
      url: "${url == "?r=merma" ? path2() : path()}$url",
      method: HTTPMethod.get,
      jsonObject: null,
      headers: await headers(),
    );
    if (response.isRight) {
      if (response.right.containsKey(keyData)) {
        List<dynamic> data = [];
        var dataJSON = response.right[keyData];
        if (dataJSON is List<dynamic>) {
          for (var element in dataJSON) {
            data.add(element);
          }
        } else {
          data.add(dataJSON);
        }

        return Right(data);
      } else {
        return Left(NoDataException());
      }
    } else {
      final error = response.left;

      return Left(error);
    }
  }

  @override
  Future<Either<Failure, List>> getObjectsByKeyMapWithPagination(
      {required String url,
      required String keyData,
      required String numberPagesKey,
      int limit = 1000,
      int actualPage = 1}) async {
    final response = await ConsumerAPI.requestJSON<Map<String, dynamic>>(
      url: "${path()}$url/limit/$limit/pagina/$actualPage",
      method: HTTPMethod.get,
      jsonObject: null,
      headers: await headers(),
    );
    if (response.isRight) {
      var json = response.right;
      int numberPages = json[numberPagesKey];
      if (response.right.containsKey(keyData)) {
        List<dynamic> data = [];
        final dataJSON = response.right[keyData];
        if (dataJSON is List<dynamic>) {
          for (var element in dataJSON) {
            data.add(element);
          }
        } else {
          data.add(dataJSON);
        }
        if (numberPages > actualPage) {
          final nextPageResponse = await getObjectsByKeyMapWithPagination(
              url: url,
              keyData: keyData,
              numberPagesKey: numberPagesKey,
              actualPage: actualPage + 1);
          if (nextPageResponse.isRight) {
            data.addAll(nextPageResponse.right);
            return Right(data);
          } else {
            return Left(nextPageResponse.left);
          }
        } else {
          return Right(data);
        }
      } else {
        return Left(NoDataException());
      }
    } else {
      final error = response.left;

      return Left(error);
    }
  }

  @override
  Future<String> get urlImage async {
    final urlImages =
        await keySource.getKeyValue(nameKey: "");

    if (urlImages != null && urlImages is String) {
      return urlImages;
    }
    return "";
  }
}
