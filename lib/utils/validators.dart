class AppValidators {
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) return 'Please enter a valid email address';
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Phone number is required';
    final phoneRegex = RegExp(r'^[6-9]\d{9}$');
    final cleaned = value.replaceAll(RegExp(r'[\s\-\+]'), '');
    if (!phoneRegex.hasMatch(cleaned)) return 'Please enter a valid 10-digit phone number';
    return null;
  }

  static String? validatePhoneOptional(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return validatePhone(value);
  }

  static String? validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) return 'Amount is required';
    final amount = double.tryParse(value.trim());
    if (amount == null) return 'Please enter a valid number';
    if (amount < 0) return 'Amount cannot be negative';
    return null;
  }

  static String? validatePositiveAmount(String? value) {
    final result = validateAmount(value);
    if (result != null) return result;
    final amount = double.tryParse(value!.trim()) ?? 0;
    if (amount <= 0) return 'Amount must be greater than 0';
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Name is required';
    if (value.trim().length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  static String? validateGST(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final gstRegex = RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$');
    if (!gstRegex.hasMatch(value.trim().toUpperCase())) return 'Invalid GST number format';
    return null;
  }
}
