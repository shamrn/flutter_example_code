import 'package:freezed_annotation/freezed_annotation.dart';

part 'sign_up_personal_settings_two_step_errors.freezed.dart';

@freezed
class SignUpPersonalSettingsTwoStepErrors
    with _$SignUpPersonalSettingsTwoStepErrors {
  const factory SignUpPersonalSettingsTwoStepErrors({
    @Default(false) bool isServerUnknownError,
  }) = _SignUpPersonalSettingsTwoStepErrors;
}
