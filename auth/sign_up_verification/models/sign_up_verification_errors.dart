import 'package:freezed_annotation/freezed_annotation.dart';

part 'sign_up_verification_errors.freezed.dart';

@freezed
class SignUpVerificationErrors with _$SignUpVerificationErrors {
  const factory SignUpVerificationErrors({
    @Default(false) bool isServerUnknownError,
    @Default(false) bool isOtpSendErrors,
    @Default(false) bool isBadRequest,
    @Default(false) bool isCodeInvalidError,
    String? serverErrorText,
  }) = _SignUpVerificationErrors;
}
