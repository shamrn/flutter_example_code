import 'package:freezed_annotation/freezed_annotation.dart';

part 'sign_up_personal_settings_third_step_pro_response.freezed.dart';
part 'sign_up_personal_settings_third_step_pro_response.g.dart';

@freezed
class SignUpPersonalSettingsThirdStepProResponse
    with _$SignUpPersonalSettingsThirdStepProResponse {
  // ignore: invalid_annotation_target
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory SignUpPersonalSettingsThirdStepProResponse({
    required int id,
    required String title,
    required String image,
    required String video,
  }) = _SignUpPersonalSettingsThirdStepProResponse;

  factory SignUpPersonalSettingsThirdStepProResponse.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$SignUpPersonalSettingsThirdStepProResponseFromJson(
        json,
      );
}
