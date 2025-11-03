enum CampusStatusEnum { abierto, cerrado, mantenimiento }

extension CampusStatusEnumX on CampusStatusEnum {
  String toText() {
    switch (this) {
      case CampusStatusEnum.abierto:
        return 'abierto';
      case CampusStatusEnum.cerrado:
        return 'cerrado';
      case CampusStatusEnum.mantenimiento:
        return 'mantenimiento';
    }
  }
}

CampusStatusEnum? campusStatusEnumTryParse(String? text) {
  if (text == null) return null;
  switch (text) {
    case 'abierto':
      return CampusStatusEnum.abierto;
    case 'cerrado':
      return CampusStatusEnum.cerrado;
    case 'mantenimiento':
      return CampusStatusEnum.mantenimiento;
    default:
      return null;
  }
}

CampusStatusEnum campusStatusEnumFromText(String text) {
  final res = campusStatusEnumTryParse(text);
  if (res == null) {
    throw ArgumentError('Unknown CampusStatusEnum value: $text');
  }
  return res;
}
