import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:prime_ballet/auth/sign_in/models/sign_in_errors.dart';
import 'package:prime_ballet/auth/sign_in/models/sign_in_validation_result.dart';
import 'package:prime_ballet/common/models/personal_settings_redirect_type.dart';

part 'sign_in_state.freezed.dart';

@freezed
class SignInState with _$SignInState {
  const factory SignInState({
    @Default(false) bool isSetUpButtonEnable,
    @Default(false) bool isSetUpButtonLoading,
    @Default(SignInValidationResult()) SignInValidationResult validationResult,
    PersonalSettingsRedirectType? personalSettingsRedirectHelperType,
    SignInErrors? errors,
  }) = _SignInState;
}
