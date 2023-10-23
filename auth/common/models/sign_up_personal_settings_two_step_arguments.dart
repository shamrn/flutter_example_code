import 'package:freezed_annotation/freezed_annotation.dart';

part 'sign_up_personal_settings_two_step_arguments.freezed.dart';

@freezed
class SignUpPersonalSettingsTwoStepArguments
    with _$SignUpPersonalSettingsTwoStepArguments {
  const factory SignUpPersonalSettingsTwoStepArguments({
    required bool isStagedRedirect,
  }) = _SignUpPersonalSettingsTwoStepArguments;
}
