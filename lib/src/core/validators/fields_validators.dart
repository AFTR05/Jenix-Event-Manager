class FieldsValidators {
  // ============================================================================
  // BASIC VALIDATORS
  // ============================================================================
  
  /// Valida que un campo no esté vacío
  static String? fieldIsRequired(String? text) {
    if (text == null || text.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  /// Valida que un campo no esté vacío con mensaje personalizado
  static String? fieldIsRequiredCustom(String? text, String fieldName) {
    if (text == null || text.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // ============================================================================
  // EMAIL VALIDATORS
  // ============================================================================
  
  /// Valida formato de email
  static String? emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  /// Valida email con verificación de dominio
  static String? emailValidatorStrict(String? value) {
    final basicValidation = emailValidator(value);
    if (basicValidation != null) return basicValidation;

    // Lista de dominios comunes válidos (opcional)
    final commonDomains = [
      'gmail.com', 'yahoo.com', 'hotmail.com', 'outlook.com',
      'icloud.com', 'protonmail.com', 'mail.com', 'aol.com',
    ];

    final domain = value!.split('@').last.toLowerCase();
    
    // Advertencia para dominios poco comunes (no error)
    if (!commonDomains.contains(domain)) {
      // Puedes decidir si mostrar advertencia o no
      // return 'Please verify the email domain';
    }

    return null;
  }

  // ============================================================================
  // PASSWORD VALIDATORS
  // ============================================================================
  
  /// Valida longitud mínima de contraseña
  static String? passwordValidator(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    
    return null;
  }

  /// Valida contraseña con requisitos de seguridad
  static String? passwordValidatorStrong(String? value, {int minLength = 8}) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }

    // Verificar mayúscula
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    // Verificar minúscula
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }

    // Verificar número
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    // Verificar carácter especial
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }

    return null;
  }

  /// Valida que dos contraseñas coincidan
  static String? confirmPasswordValidator(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (value != password) {
      return 'Passwords do not match';
    }
    
    return null;
  }

  // ============================================================================
  // PHONE VALIDATORS
  // ============================================================================
  
  /// Valida número de teléfono básico
  static String? phoneValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    
    // Eliminar espacios, guiones y paréntesis para validación
    final cleanNumber = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // Verificar que solo contenga dígitos y posible +
    if (!RegExp(r'^\+?\d{10,15}$').hasMatch(cleanNumber)) {
      return 'Please enter a valid phone number';
    }
    
    return null;
  }

  /// Valida teléfono con formato específico
  static String? phoneValidatorUS(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    
    final cleanNumber = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // Formato US: 10 dígitos o +1 seguido de 10 dígitos
    if (!RegExp(r'^(\+1)?[0-9]{10}$').hasMatch(cleanNumber)) {
      return 'Please enter a valid US phone number';
    }
    
    return null;
  }

  // ============================================================================
  // TEXT LENGTH VALIDATORS
  // ============================================================================
  
  /// Valida longitud mínima
  static String? minLengthValidator(String? value, int minLength, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? "This field"} is required';
    }
    
    if (value.length < minLength) {
      return '${fieldName ?? "This field"} must be at least $minLength characters';
    }
    
    return null;
  }

  /// Valida longitud máxima
  static String? maxLengthValidator(String? value, int maxLength, {String? fieldName}) {
    if (value != null && value.length > maxLength) {
      return '${fieldName ?? "This field"} must be at most $maxLength characters';
    }
    return null;
  }

  /// Valida rango de longitud
  static String? lengthRangeValidator(
    String? value,
    int minLength,
    int maxLength, {
    String? fieldName,
  }) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? "This field"} is required';
    }
    
    if (value.length < minLength || value.length > maxLength) {
      return '${fieldName ?? "This field"} must be between $minLength and $maxLength characters';
    }
    
    return null;
  }

  // ============================================================================
  // NUMERIC VALIDATORS
  // ============================================================================
  
  /// Valida que solo contenga números
  static String? numericValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'Only numbers are allowed';
    }
    
    return null;
  }

  /// Valida números decimales
  static String? decimalValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    
    if (!RegExp(r'^\d+\.?\d*$').hasMatch(value)) {
      return 'Please enter a valid number';
    }
    
    return null;
  }

  /// Valida rango numérico
  static String? numberRangeValidator(
    String? value,
    double min,
    double max, {
    String? fieldName,
  }) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? "This field"} is required';
    }
    
    final number = double.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }
    
    if (number < min || number > max) {
      return '${fieldName ?? "Value"} must be between $min and $max';
    }
    
    return null;
  }

  // ============================================================================
  // URL & WEB VALIDATORS
  // ============================================================================
  
  /// Valida URL
  static String? urlValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'URL is required';
    }
    
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );
    
    if (!urlRegex.hasMatch(value.trim())) {
      return 'Please enter a valid URL';
    }
    
    return null;
  }

  /// Valida username/handle de redes sociales
  static String? usernameValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
    }
    
    // Username: 3-20 caracteres, solo letras, números, guiones y guiones bajos
    if (!RegExp(r'^[a-zA-Z0-9_-]{3,20}$').hasMatch(value)) {
      return 'Username must be 3-20 characters (letters, numbers, - and _ only)';
    }
    
    return null;
  }

  // ============================================================================
  // DATE VALIDATORS
  // ============================================================================
  
  /// Valida edad mínima (formato fecha de nacimiento)
  static String? ageValidator(DateTime? birthDate, int minAge) {
    if (birthDate == null) {
      return 'Date of birth is required';
    }
    
    final today = DateTime.now();
    final age = today.year - birthDate.year;
    
    if (age < minAge) {
      return 'You must be at least $minAge years old';
    }
    
    return null;
  }

  /// Valida fecha futura
  static String? futureDateValidator(DateTime? date) {
    if (date == null) {
      return 'Date is required';
    }
    
    if (date.isBefore(DateTime.now())) {
      return 'Date must be in the future';
    }
    
    return null;
  }

  /// Valida fecha pasada
  static String? pastDateValidator(DateTime? date) {
    if (date == null) {
      return 'Date is required';
    }
    
    if (date.isAfter(DateTime.now())) {
      return 'Date must be in the past';
    }
    
    return null;
  }

  // ============================================================================
  // CREDIT CARD VALIDATORS
  // ============================================================================
  
  /// Valida número de tarjeta de crédito (algoritmo de Luhn)
  static String? creditCardValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Card number is required';
    }
    
    final cleanNumber = value.replaceAll(RegExp(r'\s'), '');
    
    if (!RegExp(r'^\d{13,19}$').hasMatch(cleanNumber)) {
      return 'Please enter a valid card number';
    }
    
    // Algoritmo de Luhn
    int sum = 0;
    bool alternate = false;
    
    for (int i = cleanNumber.length - 1; i >= 0; i--) {
      int digit = int.parse(cleanNumber[i]);
      
      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit -= 9;
        }
      }
      
      sum += digit;
      alternate = !alternate;
    }
    
    if (sum % 10 != 0) {
      return 'Invalid card number';
    }
    
    return null;
  }

  /// Valida CVV
  static String? cvvValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'CVV is required';
    }
    
    if (!RegExp(r'^\d{3,4}$').hasMatch(value)) {
      return 'Please enter a valid CVV';
    }
    
    return null;
  }

  // ============================================================================
  // SPECIAL VALIDATORS
  // ============================================================================
  
  /// Valida checkbox (debe estar marcado)
  static String? checkboxValidator(bool? value) {
    if (value != true) {
      return 'You must accept to continue';
    }
    return null;
  }

  /// Valida que no contenga espacios
  static String? noSpacesValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    
    if (value.contains(' ')) {
      return 'Spaces are not allowed';
    }
    
    return null;
  }

  /// Valida solo letras
  static String? alphabeticValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Only letters are allowed';
    }
    
    return null;
  }

  /// Valida solo letras y números
  static String? alphanumericValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    
    if (!RegExp(r'^[a-zA-Z0-9\s]+$').hasMatch(value)) {
      return 'Only letters and numbers are allowed';
    }
    
    return null;
  }

  // ============================================================================
  // COMPOSITE VALIDATORS
  // ============================================================================
  
  /// Combina múltiples validadores
  static String? Function(String?) combine(
    List<String? Function(String?)> validators,
  ) {
    return (value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }

  /// Validador condicional
  static String? Function(String?) conditional(
    bool Function() condition,
    String? Function(String?) validator,
  ) {
    return (value) {
      if (condition()) {
        return validator(value);
      }
      return null;
    };
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================
  
  /// Limpia caracteres especiales de un string
  static String cleanString(String value) {
    return value.replaceAll(RegExp(r'[^\w\s]'), '');
  }

  /// Formatea número de teléfono
  static String formatPhoneNumber(String phone) {
    final clean = phone.replaceAll(RegExp(r'\D'), '');
    if (clean.length == 10) {
      return '(${clean.substring(0, 3)}) ${clean.substring(3, 6)}-${clean.substring(6)}';
    }
    return phone;
  }

  /// Formatea número de tarjeta
  static String formatCardNumber(String card) {
    final clean = card.replaceAll(RegExp(r'\s'), '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < clean.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(clean[i]);
    }
    
    return buffer.toString();
  }
}