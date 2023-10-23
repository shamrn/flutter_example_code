import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_two_step/models/sign_up_personal_settings_two_step_errors.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_two_step/models/sign_up_personal_settings_two_step_redirect_type.dart';

part 'sign_up_personal_settings_two_step_state.freezed.dart';

@freezed
class SignUpPersonalSettingsTwoStepState
    with _$SignUpPersonalSettingsTwoStepState {
  const factory SignUpPersonalSettingsTwoStepState({
    @Default(false) bool isContinueButtonLoading,
    @Default(4) int selectedNumberOfSessionsValue,
    @Default(30) int selectedTrainingTimeValue,
    @Default([]) List<int> numberOfSessionsValues,
    @Default([]) List<int> trainingTimeValues,
    SignUpPersonalSettingsTwoStepRedirectType? redirectType,
    SignUpPersonalSettingsTwoStepErrors? errors,
  }) = _SignUpPersonalSettingsTwoStepState;
}
