enum OrganizationAreaEnum {
  allFaculties('Todas las facultades'),
  withoutFaculty('Sin facultad'),
  sciences('Facultad de Ciencias'),
  medicalSciences('Facultad de Ciencias Médicas'),
  administrativeSciences('Facultad de Ciencias Administrativas'),
  engineeringAndBasicSciences('Facultad de Ingenierías y Ciencias Básicas'),
  humanAndEducationSciences('Facultad de Ciencias Humanas y de la Educación'),
  socialAndLegalSciences('Facultad de Ciencias Sociales y Jurídicas'),
  healthSciences('Facultad de Ciencias de la Salud'),
  agriculturalSciences('Facultad de Ciencias Agropecuarias');

  final String displayName;

  const OrganizationAreaEnum(this.displayName);

  static final List<String> _organizationAreas = [
    'Todas las facultades',
    'Sin facultad',
    'Facultad de Ciencias',
    'Facultad de Ciencias Médicas',
    'Facultad de Ciencias Administrativas',
    'Facultad de Ingenierías y Ciencias Básicas',
    'Facultad de Ciencias Humanas y de la Educación',
    'Facultad de Ciencias Sociales y Jurídicas',
    'Facultad de Ciencias de la Salud',
    'Facultad de Ciencias Agropecuarias',
  ];

  static List<String> get organizationAreas => _organizationAreas;

  static OrganizationAreaEnum fromString(String value) {
    return OrganizationAreaEnum.values.firstWhere(
      (area) => area.displayName == value,
      orElse: () => OrganizationAreaEnum.allFaculties,
    );
  }
}