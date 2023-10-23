import 'package:freezed_annotation/freezed_annotation.dart';

part 'sign_in_errors.freezed.dart';

@freezed
class SignInErrors with _$SignInErrors {
  const factory SignInErrors({
    @Default(false) bool isServerUnknownError,
  }) = _SignInErrors;
}
