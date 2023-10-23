import 'package:freezed_annotation/freezed_annotation.dart';

part 'sign_up_personal_settings_third_step_pro_errors.freezed.dart';

@freezed
class SignUpPersonalSettingsThirdStepProErrors
    with _$SignUpPersonalSettingsThirdStepProErrors {
  const factory SignUpPersonalSettingsThirdStepProErrors({
    @Default(false) bool isServerUnknownError,
  }) = _SignUpPersonalSettingsThirdStepProErrors;
}
