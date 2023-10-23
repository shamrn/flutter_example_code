import 'package:freezed_annotation/freezed_annotation.dart';

part 'sign_up_personal_settings_third_step_create_playlist_request.freezed.dart';
part 'sign_up_personal_settings_third_step_create_playlist_request.g.dart';

@freezed
class SignUpPersonalSettingsThirdStepCreatePlaylistRequest
    with _$SignUpPersonalSettingsThirdStepCreatePlaylistRequest {
  // ignore: invalid_annotation_target
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory SignUpPersonalSettingsThirdStepCreatePlaylistRequest({
    required List<int> ids,
  }) = _SignUpPersonalSettingsThirdStepCreatePlaylistRequest;

  factory SignUpPersonalSettingsThirdStepCreatePlaylistRequest.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$SignUpPersonalSettingsThirdStepCreatePlaylistRequestFromJson(json);
}
