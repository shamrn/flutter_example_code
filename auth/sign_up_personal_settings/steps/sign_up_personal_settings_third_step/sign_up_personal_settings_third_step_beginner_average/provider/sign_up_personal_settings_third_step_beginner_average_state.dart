import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_third_step/sign_up_personal_settings_third_step_beginner_average/models/sign_up_personal_settings_third_step_beginner_average_errors.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_third_step/sign_up_personal_settings_third_step_beginner_average/models/sign_up_personal_settings_third_step_beginner_average_ui.dart';

part 'sign_up_personal_settings_third_step_beginner_average_state.freezed.dart';

@freezed
class SignUpPersonalSettingsThirdStepBeginnerAverageState
    with _$SignUpPersonalSettingsThirdStepBeginnerAverageState {
  const factory SignUpPersonalSettingsThirdStepBeginnerAverageState({
    @Default(true) bool isLoading,
    @Default(false) bool isFinish,
    @Default(false) bool isContinueButtonEnable,
    @Default(false) bool isContinueButtonLoading,
    @Default([]) List<int> selectedExerciseIdList,
    @Default([])
    List<SignUpPersonalSettingsThirdStepBeginnerAverageUi> exerciseList,
    String? userName,
    SignUpPersonalSettingsThirdStepBeginnerAverageErrors? errors,
  }) = _SignUpPersonalSettingsThirdStepBeginnerAverageState;
}
