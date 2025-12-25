class Validators {
  static String? emailOrPhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email or Mobile Number is required';
    }
    // Check if it's an email or phone number
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    final phoneRegex = RegExp(r'^[0-9]{10}$');
    
    if (!emailRegex.hasMatch(value) && !phoneRegex.hasMatch(value)) {
      return 'Please enter a valid email or 10-digit mobile number';
    }
    return null;
  }
  
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }
  
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }
  
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^[0-9]{10}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid 10-digit phone number';
    }
    return null;
  }
  
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
  
  static String? minLength(String? value, int minLength, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    if (value.length < minLength) {
      return '${fieldName ?? 'This field'} must be at least $minLength characters';
    }
    return null;
  }

  static String? maxLength(String? value, int maxLength, {String? fieldName}) {
    if (value != null && value.length > maxLength) {
      return '${fieldName ?? 'This field'} must not exceed $maxLength characters';
    }
    return null;
  }

  static String? numeric(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    if (double.tryParse(value) == null) {
      return '${fieldName ?? 'This field'} must be a valid number';
    }
    return null;
  }

  static String? positiveNumber(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    final num = double.tryParse(value);
    if (num == null || num <= 0) {
      return '${fieldName ?? 'This field'} must be a positive number';
    }
    return null;
  }
}

