/// Input validation utilities
class Validators {
  /// Validate email format
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال البريد الإلكتروني';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'البريد الإلكتروني غير صحيح';
    }

    return null;
  }

  /// Validate phone number (Saudi format)
  static String? phoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال رقم الجوال';
    }

    // Remove any non-digit characters
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');

    // Check if it's a valid Saudi number (10 digits starting with 05 or +966)
    if (digitsOnly.length == 10 && digitsOnly.startsWith('05')) {
      return null;
    }

    if (digitsOnly.length == 12 && digitsOnly.startsWith('966')) {
      return null;
    }

    return 'رقم الجوال غير صحيح';
  }

  /// Validate password strength
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال كلمة السر';
    }

    if (value.length < 6) {
      return 'كلمة السر يجب أن تكون 6 أحرف على الأقل';
    }

    return null;
  }

  /// Validate required field
  static String? required(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال $fieldName';
    }
    return null;
  }

  /// Validate number (price, etc.)
  static String? number(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال رقم';
    }

    if (double.tryParse(value) == null) {
      return 'الرجاء إدخال رقم صحيح';
    }

    return null;
  }
}

