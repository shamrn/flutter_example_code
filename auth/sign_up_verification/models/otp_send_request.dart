import 'package:freezed_annotation/freezed_annotation.dart';

part 'otp_send_request.freezed.dart';
part 'otp_send_request.g.dart';

@freezed
class OtpSendRequest with _$OtpSendRequest {
  // ignore: invalid_annotation_target
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory OtpSendRequest({
    required String email,
    @Default(0) int reason,
  }) = _OtpSendRequest;

  factory OtpSendRequest.fromJson(Map<String, dynamic> json) =>
      _$OtpSendRequestFromJson(json);
}
