import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_third_step/sign_up_personal_settings_third_step_pro/models/sign_up_personal_settings_third_step_pro_errors.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_third_step/sign_up_personal_settings_third_step_pro/models/sign_up_personal_settings_third_step_pro_ui.dart';

part 'sign_up_personal_settings_third_step_pro_state.freezed.dart';

@freezed
class SignUpPersonalSettingsThirdStepProState
    with _$SignUpPersonalSettingsThirdStepProState {
  const factory SignUpPersonalSettingsThirdStepProState({
    @Default(true) bool isLoading,
    @Default(false) bool isFinish,
    @Default(false) bool isContinueButtonEnable,
    @Default(false) bool isContinueButtonLoading,
    @Default([]) List<int> selectedExerciseIdList,
    @Default([]) List<SignUpPersonalSettingsThirdStepProUi> exerciseList,
    String? userName,
    SignUpPersonalSettingsThirdStepProErrors? errors,
  }) = _SignUpPersonalSettingsThirdStepProState;
}
