import 'package:freezed_annotation/freezed_annotation.dart';

part 'sign_up_personal_settings_one_step_errors.freezed.dart';

@freezed
class SignUpPersonalSettingsOneStepErrors
    with _$SignUpPersonalSettingsOneStepErrors {
  const factory SignUpPersonalSettingsOneStepErrors({
    @Default(false) bool isServerUnknownError,
  }) = _SignUpPersonalSettingsOneStepErrors;
}
