class AuthValidationHelper {
  static bool isValidEmail(String value) {
    return RegExp(
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
    ).hasMatch(value);
  }

  static bool isValidName(String value) {
    return RegExp(
      r'^[a-zA-Z\s]+$',
    ).hasMatch(value);
  }

  static bool isValidPassword(String value) {
    return RegExp(
      r'^(?=.*[a-zA-Z])(?=.*[0-9]).{8,}$',
    ).hasMatch(value);
  }
}
