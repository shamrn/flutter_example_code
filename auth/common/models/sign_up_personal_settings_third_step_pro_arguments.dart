import 'package:freezed_annotation/freezed_annotation.dart';

part 'sign_up_personal_settings_third_step_pro_arguments.freezed.dart';

@freezed
class SignUpPersonalSettingsThirdStepProArguments
    with _$SignUpPersonalSettingsThirdStepProArguments {
  const factory SignUpPersonalSettingsThirdStepProArguments({
    required bool isStagedRedirect,
  }) = _SignUpPersonalSettingsThirdStepProArguments;
}
