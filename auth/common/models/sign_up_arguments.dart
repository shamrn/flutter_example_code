import 'package:freezed_annotation/freezed_annotation.dart';

part 'sign_up_arguments.freezed.dart';

@freezed
class SignUpArguments with _$SignUpArguments {
  const factory SignUpArguments({
    required String name,
    required String email,
    required String password,
  }) = _SignUpArguments;
}
