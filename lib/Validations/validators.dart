class Validators {
  static String? voterIdValidator(value) {
    final regex = RegExp(r'^[A-Z]{3}[0-9]{7}$');
    if (value == null || value.isEmpty) {
      return 'Please enter your Voter ID';
    } else if (!regex.hasMatch(value)) {
      return 'Invalid ID number';
    }
    return null;
  }

  static String? passportIdValidator(value) {
    final regex = RegExp(r'^[A-Z][0-9]{7}$');
    if (value == null || value.isEmpty) {
      return 'Please enter your Passport ID';
    } else if (!regex.hasMatch(value)) {
      return 'Invalid ID number';
    }
    return null;
  }

  static String? drivingLicenseValidator(value) {
    final regex = RegExp(r'^[A-Z]{2}\d{13}');
    if (value == null || value.isEmpty) {
      return 'Please enter your Driving License number';
    } else if (!regex.hasMatch(value)) {
      return 'Invalid Driving License number';
    }
    return null;
  }

  static String? aadhaarLast4DigitsValidator(value) {
    final regex = RegExp(r'^[0-9]{4}$');
    if (value == null || value.isEmpty) {
      return 'Please enter the last 4 digits of your Aadhaar';
    } else if (!regex.hasMatch(value)) {
      return 'Invalid Aadhar number';
    }
    return null;
  }

  static String? emailValidator(value) {
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    } else if (!regex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? phoneNumberValidator(value) {
    final regex = RegExp(r'^(?:[+0]9)?[0-9]{10}$');
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    } else if (!regex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  static String? formValidation(value) {
    if (value == null || value.isEmpty) {
      return 'Please Enter';
    }
    final alphanumericRegex = RegExp(r'^[a-zA-Z0-9-]+$');
    if (!alphanumericRegex.hasMatch(value)) {
      return 'Please Enter';
    }
    if (value == '0') {
      return 'Please Enter’ ';
    }
    return null;
  }

  static policyNumber(value) {
    if (value.isEmpty) {
      return true;
    } else {
      return false;
    }
  }
}
