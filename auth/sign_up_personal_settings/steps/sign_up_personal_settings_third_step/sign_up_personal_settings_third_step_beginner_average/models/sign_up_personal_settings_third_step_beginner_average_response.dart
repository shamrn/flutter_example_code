import 'package:freezed_annotation/freezed_annotation.dart';

part 'sign_up_personal_settings_third_step_beginner_average_response.freezed.dart';
part 'sign_up_personal_settings_third_step_beginner_average_response.g.dart';

@freezed
class SignUpPersonalSettingsThirdStepBeginnerAverageResponse
    with _$SignUpPersonalSettingsThirdStepBeginnerAverageResponse {
  // ignore: invalid_annotation_target
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory SignUpPersonalSettingsThirdStepBeginnerAverageResponse({
    required int id,
    required String title,
  }) = _SignUpPersonalSettingsThirdStepBeginnerAverageResponse;

  factory SignUpPersonalSettingsThirdStepBeginnerAverageResponse.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$SignUpPersonalSettingsThirdStepBeginnerAverageResponseFromJson(
        json,
      );
}
