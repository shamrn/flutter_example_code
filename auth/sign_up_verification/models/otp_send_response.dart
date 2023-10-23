import 'package:freezed_annotation/freezed_annotation.dart';

part 'otp_send_response.freezed.dart';
part 'otp_send_response.g.dart';

@freezed
class OtpSendResponse with _$OtpSendResponse {
  // ignore: invalid_annotation_target
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory OtpSendResponse({
    required String token,
  }) = _OtpSendResponse;

  factory OtpSendResponse.fromJson(Map<String, dynamic> json) =>
      _$OtpSendResponseFromJson(json);
}
