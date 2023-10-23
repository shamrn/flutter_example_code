import 'package:freezed_annotation/freezed_annotation.dart';

part 'sign_in_validation_result.freezed.dart';

@freezed
class SignInValidationResult with _$SignInValidationResult {
  const factory SignInValidationResult({
    @Default(true) bool isEmailEmpty,
    @Default(true) bool isPasswordEmpty,
    @Default(false) bool isEmailInvalidError,
    @Default(false) bool isServerValidateError,
    String? serverValidateErrorText,
  }) = _SignInValidationResult;

  const SignInValidationResult._();

  bool get isFieldsNotEmpty => !isEmailEmpty && !isPasswordEmpty;

  bool get isFieldsValid => !isEmailInvalidError;
}
