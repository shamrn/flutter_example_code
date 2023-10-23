import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_sign_up_request.freezed.dart';
part 'auth_sign_up_request.g.dart';

@freezed
class AuthSignUpRequest with _$AuthSignUpRequest {
  // ignore: invalid_annotation_target
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory AuthSignUpRequest({
    required String token,
    required String name,
    required String password,
    required String clientId,
    required String deviceId,
  }) = _AuthSignUpRequest;

  factory AuthSignUpRequest.fromJson(Map<String, dynamic> json) =>
      _$AuthSignUpRequestFromJson(json);
}
