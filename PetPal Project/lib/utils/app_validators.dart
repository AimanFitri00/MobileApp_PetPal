class AppValidators {
  static String? required(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? email(String? value) {
    final base = required(value, fieldName: 'Email');
    if (base != null) return base;
    final pattern = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!pattern.hasMatch(value!.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? password(String? value) {
    final base = required(value, fieldName: 'Password');
    if (base != null) return base;
    if (value!.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }
}
