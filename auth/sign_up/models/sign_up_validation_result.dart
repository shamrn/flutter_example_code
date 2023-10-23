import 'package:freezed_annotation/freezed_annotation.dart';

part 'sign_up_validation_result.freezed.dart';

@freezed
class SignUpValidationResult with _$SignUpValidationResult {
  const factory SignUpValidationResult({
    @Default(true) bool isNameEmpty,
    @Default(true) bool isEmailEmpty,
    @Default(true) bool isPasswordEmpty,
    @Default(true) bool isConfirmPasswordEmpty,
    @Default(false) bool isNameInvalidError,
    @Default(false) bool isEmailInvalidError,
    @Default(false) bool isPasswordInvalidError,
    @Default(false) bool isPasswordMismatchError,
    @Default(false) bool isServerValidateError,
    @Default([]) List<String> serverValidateErrorTexts,
  }) = _SignUpValidationResult;

  const SignUpValidationResult._();

  bool get isFieldsNotEmpty =>
      !isNameEmpty &&
      !isEmailEmpty &&
      !isPasswordEmpty &&
      !isConfirmPasswordEmpty;

  bool get isFieldsValid =>
      !isNameInvalidError &&
      !isEmailInvalidError &&
      !isPasswordInvalidError &&
      !isPasswordMismatchError;
}
