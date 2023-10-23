import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_third_step/sign_up_personal_settings_third_step_beginner_average/models/sign_up_personal_settings_third_step_beginner_average_response.dart';

part 'sign_up_personal_settings_third_step_beginner_average_ui.freezed.dart';

@freezed
class SignUpPersonalSettingsThirdStepBeginnerAverageUi
    with _$SignUpPersonalSettingsThirdStepBeginnerAverageUi {
  const factory SignUpPersonalSettingsThirdStepBeginnerAverageUi({
    required int id,
    required String title,
  }) = _SignUpPersonalSettingsThirdStepBeginnerAverageUi;

  factory SignUpPersonalSettingsThirdStepBeginnerAverageUi.fromResponse(
    SignUpPersonalSettingsThirdStepBeginnerAverageResponse response,
  ) =>
      SignUpPersonalSettingsThirdStepBeginnerAverageUi(
        id: response.id,
        title: response.title,
      );
}
