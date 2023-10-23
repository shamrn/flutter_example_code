import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:prime_ballet/auth/sign_up/models/sign_up_validation_result.dart';

part 'sign_up_state.freezed.dart';

@freezed
class SignUpState with _$SignUpState {
  const factory SignUpState({
    @Default(false) bool isSetUpButtonEnable,
    @Default(false) bool isValidationFinished,
    @Default(SignUpValidationResult()) SignUpValidationResult validationResult,
  }) = _SignUpState;
}
