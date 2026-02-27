/// Form validation utilities
library;

class AppValidators {
  /// Validate email address
  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  /// Validate password (min 8 chars, at least one uppercase, one digit)
  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must have an uppercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain a digit';
    }
    return null;
  }

  /// Validate confirm password
  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != original) return 'Passwords do not match';
    return null;
  }

  /// Required field validator
  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }

  /// Phone number validator (Pakistan format)
  static String? phone(String? value) {
    if (value == null || value.isEmpty) return 'Phone number is required';
    final phoneRegex = RegExp(r'^(\+92|0)?[0-9]{10,11}$');
    if (!phoneRegex.hasMatch(value.replaceAll(' ', ''))) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  /// CNIC validator (Pakistan: 13 digits)
  static String? cnic(String? value) {
    if (value == null || value.isEmpty) return 'CNIC is required';
    final cnicRegex = RegExp(r'^[0-9]{5}-[0-9]{7}-[0-9]$');
    final cnicRawRegex = RegExp(r'^[0-9]{13}$');
    final clean = value.replaceAll('-', '');
    if (!cnicRegex.hasMatch(value) && !cnicRawRegex.hasMatch(clean)) {
      return 'Enter valid CNIC (e.g. 12345-1234567-1)';
    }
    return null;
  }

  /// Price validator
  static String? price(String? value) {
    if (value == null || value.isEmpty) return 'Price is required';
    final price = double.tryParse(value);
    if (price == null || price <= 0) return 'Enter a valid price';
    return null;
  }

  /// Validate minimum length
  static String? minLength(String? value, int min,
      {String fieldName = 'Field'}) {
    if (value == null || value.isEmpty) return '$fieldName is required';
    if (value.length < min) {
      return '$fieldName must be at least $min characters';
    }
    return null;
  }
}
