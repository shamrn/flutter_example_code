import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:prime_ballet/auth/sign_up_verification/models/sign_up_verification_errors.dart';

part 'sign_up_verification_state.freezed.dart';

@freezed
class SignUpVerificationState with _$SignUpVerificationState {
  const factory SignUpVerificationState({
    @Default(false) bool isFinishedSignUp,
    @Default(false) bool isResendCodeEnable,
    @Default(false) bool isSetUpButtonEnable,
    @Default(false) bool isSetUpButtonLoading,
    @Default(60) int resendCodeCountdownSeconds,
    String? email,
    String? tokenForVerify,
    SignUpVerificationErrors? errors,
    DioException? dioException,
  }) = _SignUpVerificationState;
}
