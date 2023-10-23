import 'package:freezed_annotation/freezed_annotation.dart';

part 'sign_up_personal_settings_one_step_validation_result.freezed.dart';

@freezed
class SignUpPersonalSettingsOneStepValidationResult
    with _$SignUpPersonalSettingsOneStepValidationResult {
  const factory SignUpPersonalSettingsOneStepValidationResult({
    @Default(false) bool isDateOfBirthInvalidError,
    @Default(false) bool isServerValidateError,
    String? serverValidateErrorText,
  }) = _SignUpPersonalSettingsOneStepValidationResult;
}
