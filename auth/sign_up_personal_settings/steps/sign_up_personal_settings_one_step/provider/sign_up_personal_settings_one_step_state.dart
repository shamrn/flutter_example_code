import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_one_step/models/sign_up_personal_settings_one_step_errors.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_one_step/models/sign_up_personal_settings_one_step_validation_result.dart';
import 'package:prime_ballet/common/models/profile_level_type.dart';

part 'sign_up_personal_settings_one_step_state.freezed.dart';

@freezed
class SignUpPersonalSettingsOneStepState
    with _$SignUpPersonalSettingsOneStepState {
  const factory SignUpPersonalSettingsOneStepState({
    @Default(false) bool isContinueButtonEnable,
    @Default(false) bool isContinueButtonLoading,
    @Default(false) bool isFinished,
    @Default(145) int selectedHeightValue,
    @Default(66.0) double selectedWeightValue,
    @Default(ProfileLevelType.average) ProfileLevelType selectedLevelValue,
    @Default([]) List<int> heightValues,
    @Default([]) List<double> weightValues,
    @Default([]) List<String> levelValues,
    SignUpPersonalSettingsOneStepValidationResult? validationResult,
    SignUpPersonalSettingsOneStepErrors? errors,
  }) = _SignUpPersonalSettingsOneStepState;
}
