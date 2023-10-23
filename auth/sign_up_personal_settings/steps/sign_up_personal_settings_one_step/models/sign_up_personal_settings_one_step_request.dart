import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:prime_ballet/common/models/profile_level_type.dart';

part 'sign_up_personal_settings_one_step_request.freezed.dart';
part 'sign_up_personal_settings_one_step_request.g.dart';

@freezed
class SignUpPersonalSettingsOneStepRequest
    with _$SignUpPersonalSettingsOneStepRequest {
  // ignore_for_file: invalid_annotation_target
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory SignUpPersonalSettingsOneStepRequest({
    required String dateOfBirth,
    required int height,
    required double weight,
    required ProfileLevelType level,
  }) = _SignUpPersonalSettingsOneStepRequest;

  factory SignUpPersonalSettingsOneStepRequest.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$SignUpPersonalSettingsOneStepRequestFromJson(json);
}
