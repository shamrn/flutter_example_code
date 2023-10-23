class DateValidationHelper {
  static bool isValidDate(String value) {
    return RegExp(
      r'^(0[1-9]|[12][0-9]|3[01])\.(0[1-9]|1[0-2])\.\d{4}$',
    ).hasMatch(value);
  }
}
