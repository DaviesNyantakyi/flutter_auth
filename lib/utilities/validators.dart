import 'package:regexpattern/regexpattern.dart';

class Validators {
  static String noServiceTimeErrorMessage = 'Add one or more service times';
  static String? textValidator(String? text) {
    if (text == null || text.isEmpty) {
      return 'Field required';
    }
    return null;
  }

  static String? nameValidator(String? name) {
    if (name == null || name.isEmpty) {
      return 'Enter your name';
    }
    return null;
  }

  static String? emailValidator(String? email) {
    if (email == null ||
        email.isEmpty ||
        !email.contains('@') ||
        !email.contains('.')) {
      return 'Email not valid';
    }

    return null;
  }

  static String? passwordValidator(String? password) {
    if (!password!.isPasswordEasy() || password.isEmpty) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  static String? genderValidator(String? gender) {
    if (gender != null &&
        gender.toLowerCase().trim() != 'male' &&
        gender.toLowerCase().trim() != 'female') {
      return 'Gender required (Male/Female)';
    }

    if (gender != null && gender.isEmpty) {
      return 'Gender required';
    }
    return null;
  }

  static String? birthdayValidator({DateTime? date}) {
    if (date == null) {
      return 'Select your date of birth';
    }

    return null;
  }
}
