import 'package:freezed_annotation/freezed_annotation.dart';

part 'sign_up_personal_settings_two_step_request.freezed.dart';
part 'sign_up_personal_settings_two_step_request.g.dart';

@freezed
class SignUpPersonalSettingsTwoStepRequest
    with _$SignUpPersonalSettingsTwoStepRequest {
  // ignore_for_file: invalid_annotation_target
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory SignUpPersonalSettingsTwoStepRequest({
    required int numberOfSessions,
    required int trainingTime,
  }) = _SignUpPersonalSettingsTwoStepRequest;

  factory SignUpPersonalSettingsTwoStepRequest.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$SignUpPersonalSettingsTwoStepRequestFromJson(json);
}
