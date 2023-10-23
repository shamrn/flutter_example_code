import 'package:freezed_annotation/freezed_annotation.dart';

part 'sign_up_personal_settings_third_step_beginner_average_errors.freezed.dart';

@freezed
class SignUpPersonalSettingsThirdStepBeginnerAverageErrors
    with _$SignUpPersonalSettingsThirdStepBeginnerAverageErrors {
  const factory SignUpPersonalSettingsThirdStepBeginnerAverageErrors({
    @Default(false) bool isServerUnknownError,
  }) = _SignUpPersonalSettingsThirdStepBeginnerAverageErrors;
}
