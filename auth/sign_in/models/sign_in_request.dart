// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'sign_in_request.freezed.dart';
part 'sign_in_request.g.dart';

@freezed
class SignInRequest with _$SignInRequest {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory SignInRequest({
    @JsonKey(name: 'username') required String email,
    required String password,
    required String clientId,
    @Default('password') String grantType,
  }) = _SignInRequest;

  factory SignInRequest.fromJson(Map<String, dynamic> json) =>
      _$SignInRequestFromJson(json);
}
