enum RoomStatusEnum { disponible, cerrado, mantenimiento }

extension RoomStatusEnumX on RoomStatusEnum {
  String toText() {
    switch (this) {
      case RoomStatusEnum.disponible:
        return 'disponible';
      case RoomStatusEnum.cerrado:
        return 'cerrado';
      case RoomStatusEnum.mantenimiento:
        return 'mantenimiento';
    }
  }
}
RoomStatusEnum? roomStatusEnumTryParse(String? text) {
  if (text == null) return null;
  switch (text) {
    case 'disponible':
      return RoomStatusEnum.disponible;
    case 'cerrado':
      return RoomStatusEnum.cerrado;
    case 'mantenimiento':
      return RoomStatusEnum.mantenimiento;
    default:
      return null;
  }
}

RoomStatusEnum roomStatusEnumFromText(String text) {
  final res = roomStatusEnumTryParse(text);
  if (res == null) {
    throw ArgumentError('Unknown RoomStatusEnum value: $text');
  }
  return res;
}
