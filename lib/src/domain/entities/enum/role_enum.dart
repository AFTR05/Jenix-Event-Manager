enum RoleEnum {
  admin,
  organizer,
  user,
}

extension RoleEnumExtension on RoleEnum {
  String get value {
    switch (this) {
      case RoleEnum.admin:
        return 'admin';
      case RoleEnum.organizer:
        return 'organizer';
      case RoleEnum.user:
        return 'user';
    }
  }

  String get displayName {
    switch (this) {
      case RoleEnum.admin:
        return 'Administrador';
      case RoleEnum.organizer:
        return 'Organizador';
      case RoleEnum.user:
        return 'Usuario';
    }
  }

  static RoleEnum fromString(String value) {
    switch (value.toLowerCase()) {
      case 'admin':
        return RoleEnum.admin;
      case 'organizer':
        return RoleEnum.organizer;
      case 'user':
        return RoleEnum.user;
      default:
        return RoleEnum.user;
    }
  }
}