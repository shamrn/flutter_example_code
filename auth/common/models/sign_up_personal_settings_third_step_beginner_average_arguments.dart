import 'package:freezed_annotation/freezed_annotation.dart';

part 'sign_up_personal_settings_third_step_beginner_average_arguments.freezed.dart';

@freezed
class SignUpPersonalSettingsThirdStepBeginnerAverageArguments
    with _$SignUpPersonalSettingsThirdStepBeginnerAverageArguments {
  const factory SignUpPersonalSettingsThirdStepBeginnerAverageArguments({
    required bool isStagedRedirect,
  }) = _SignUpPersonalSettingsThirdStepBeginnerAverageArguments;
}
