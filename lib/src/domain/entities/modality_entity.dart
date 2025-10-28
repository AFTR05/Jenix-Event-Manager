/// Enum que representa los tipos de modalidad de reunión
enum ModalityType {
	virtual,
	hybrid,
	presential,
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
