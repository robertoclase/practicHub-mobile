/// Utilidad para validaciones
class Validators {
  /// Valida que el email tenga formato correcto
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El email es obligatorio';
    }
    
    // Validación simple: debe contener @ y un punto después del @
    if (!value.contains('@')) {
      return 'Email no válido';
    }
    
    final parts = value.split('@');
    if (parts.length != 2 || !parts[1].contains('.')) {
      return 'Email no válido';
    }
    
    return null;
  }

  /// Valida que la contraseña tenga mínimo 6 caracteres
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es obligatoria';
    }
    
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    
    return null;
  }

  /// Valida que un campo no esté vacío
  static String? validateRequired(String? value, [String fieldName = 'Campo']) {
    if (value == null || value.isEmpty) {
      return '$fieldName es obligatorio';
    }
    return null;
  }

  /// Valida que dos contraseñas coincidan
  static String? validatePasswordMatch(String? value, String? password) {
    if (value != password) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  /// Valida que un número sea positivo
  static String? validatePositiveNumber(String? value, [String fieldName = 'Valor']) {
    if (value == null || value.isEmpty) {
      return '$fieldName es obligatorio';
    }
    
    final number = int.tryParse(value);
    if (number == null || number <= 0) {
      return '$fieldName debe ser un número positivo';
    }
    
    return null;
  }

  /// Valida que un valor esté en un rango
  static String? validateRange(
    String? value,
    int min,
    int max, [
    String fieldName = 'Valor',
  ]) {
    if (value == null || value.isEmpty) {
      return '$fieldName es obligatorio';
    }
    
    final number = int.tryParse(value);
    if (number == null) {
      return '$fieldName debe ser un número';
    }
    
    if (number < min || number > max) {
      return '$fieldName debe estar entre $min y $max';
    }
    
    return null;
  }
}
