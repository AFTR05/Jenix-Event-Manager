extension StringUtils on String {
  /// Obtiene las iniciales de un string
  /// Ejemplos:
  /// "Juan Pérez" -> "JP"
  /// "Maria Elena Rodriguez Garcia" -> "MERG"
  /// "Ana" -> "A"
  /// "  juan   carlos  " -> "JC"
  /// "" -> ""
  String get initials {
    if (isEmpty) return '';
    
    // Divide el string por espacios, filtra elementos vacíos y toma la primera letra de cada palabra
    return trim()
        .split(RegExp(r'\s+')) // Divide por uno o más espacios
        .where((word) => word.isNotEmpty) // Filtra palabras vacías
        .map((word) => word[0].toUpperCase()) // Toma la primera letra y la convierte a mayúscula
        .join(); // Une todas las iniciales
  }
  
  /// Obtiene solo las iniciales del primer y último nombre (máximo 2 caracteres)
  /// Ejemplos:
  /// "Juan Pérez" -> "JP"
  /// "Maria Elena Rodriguez Garcia" -> "MG" (primera y última)
  /// "Ana" -> "A"
  String get firstLastInitials {
    if (isEmpty) return '';
    
    final words = trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    
    if (words.isEmpty) return '';
    if (words.length == 1) return words.first[0].toUpperCase();
    
    return '${words.first[0].toUpperCase()}${words.last[0].toUpperCase()}';
  }
  
  /// Obtiene las iniciales con un límite máximo de caracteres
  /// Ejemplos:
  /// "Juan Pérez Martinez".getInitials(2) -> "JP"
  /// "Ana".getInitials(3) -> "A"
  String getInitials(int maxLength) {
    final allInitials = initials;
    return allInitials.length > maxLength 
        ? allInitials.substring(0, maxLength)
        : allInitials;
  }
}