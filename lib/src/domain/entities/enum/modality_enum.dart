/// Enum que representa los tipos de modalidad de reunión
enum ModalityType {
	virtual,
	hybrid,
	presential;

  static ModalityType fromValue(dynamic value) {
    if (value is int) {
      return (value >= 0 && value < ModalityType.values.length)
          ? ModalityType.values[value]
          : ModalityType.presential;
    }
    if (value is String) {
      return ModalityType.values.firstWhere(
        (m) =>
            m.name.toLowerCase() == value.toLowerCase() ||
            m.label.toLowerCase() == value.toLowerCase(),
        orElse: () => ModalityType.presential,
      );
    }
    return ModalityType.presential;
  }
}

extension ModalityTypeExtension on ModalityType {
	String get label {
		switch (this) {
			case ModalityType.virtual:
				return 'Virtual';
			case ModalityType.hybrid:
				return 'Híbrido';
			case ModalityType.presential:
				return 'Presencial';
		}
	}
}
