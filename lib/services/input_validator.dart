class InputValidator {
  static String? validateEmail(String? email) {
    if (email?.isEmpty ?? true) return 'Email is required';
    if (!email!.contains('@')) return 'Invalid email format';
    return null;
  }

  static String? validatePassword(String? password) {
    if (password?.isEmpty ?? true) return 'Password is required';
    if (password!.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  static String? validateFirstName(String? name) {
    if (name?.isEmpty ?? true) return 'First name is required';
    if (name!.length > 200) return 'First name must be less than 200 characters';
    return null;
  }

  static String? validateLastName(String? name) {
    if (name?.isEmpty ?? true) return 'Last name is required';
    if (name!.length > 200) return 'Last name must be less than 200 characters';
    return null;
  }

  static String? validateAddress(String? address) {
    if (address?.isEmpty ?? true) return 'Address is required';
    if (address!.length > 255) return 'Address must be less than 255 characters';
    return null;
  }

  static String? validateCity(String? city) {
    if (city?.isEmpty ?? true) return 'City is required';
    if (city!.length > 100) return 'City must be less than 100 characters';
    return null;
  }

  static String? validatePrice(String? price) {
    if (price?.isEmpty ?? true) return 'Price is required';
    try {
      double.parse(price!);
      return null;
    } catch (e) {
      return 'Price must be a valid number';
    }
  }

  static String? validateRating(int? rating) {
    if (rating == null || rating < 1 || rating > 5) {
      return 'Rating must be between 1 and 5';
    }
    return null;
  }
}