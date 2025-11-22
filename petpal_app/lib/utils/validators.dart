/// Email validation using RFC format
bool isValidEmail(String email) {
  final emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  return emailRegex.hasMatch(email);
}

/// Password validation: min 8 chars, one uppercase, one number
bool isValidPassword(String password) {
  if (password.length < 8) return false;
  if (!password.contains(RegExp(r'[A-Z]'))) return false;
  if (!password.contains(RegExp(r'[0-9]'))) return false;
  return true;
}

/// Phone number validation (basic)
bool isValidPhone(String phone) {
  final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
  return phoneRegex.hasMatch(phone.replaceAll(RegExp(r'[\s-]'), ''));
}

/// Name validation (non-empty, reasonable length)
bool isValidName(String name) {
  return name.trim().isNotEmpty && name.trim().length >= 2;
}

