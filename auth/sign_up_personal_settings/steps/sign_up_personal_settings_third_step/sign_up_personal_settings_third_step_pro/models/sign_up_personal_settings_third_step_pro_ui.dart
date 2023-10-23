import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_third_step/sign_up_personal_settings_third_step_pro/models/sign_up_personal_settings_third_step_pro_response.dart';

part 'sign_up_personal_settings_third_step_pro_ui.freezed.dart';

@freezed
class SignUpPersonalSettingsThirdStepProUi
    with _$SignUpPersonalSettingsThirdStepProUi {
  const factory SignUpPersonalSettingsThirdStepProUi({
    required int id,
    required String title,
    required String imageUrl,
    required String videoUrl,
  }) = _SignUpPersonalSettingsThirdStepProUi;

  factory SignUpPersonalSettingsThirdStepProUi.fromResponse(
    SignUpPersonalSettingsThirdStepProResponse response,
  ) =>
      SignUpPersonalSettingsThirdStepProUi(
        id: response.id,
        title: response.title,
        imageUrl: response.image,
        videoUrl: response.video,
      );
}
