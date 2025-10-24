import 'package:easy_localization/easy_localization.dart';
import 'package:jenix_event_manager/src/core/exceptions/failure.dart';
import 'package:jenix_event_manager/translations/locale_keys.g.dart';

class UnknownException extends Failure {
  Exception error;

  UnknownException({
    required this.error,
  });

  @override
  String get message => LocaleKeys.unknownError.tr();
}
