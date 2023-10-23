import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injectable/injectable.dart';
import 'package:prime_ballet/auth/common/helpers/auth_validation_helper.dart';
import 'package:prime_ballet/auth/sign_up/models/sign_up_validation_result.dart';
import 'package:prime_ballet/auth/sign_up/provider/sign_up_state.dart';
import 'package:prime_ballet/common/dio/helpers/api_error_helper.dart';

@injectable
class SignUpProvider extends StateNotifier<SignUpState> {
  SignUpProvider() : super(const SignUpState());

  void nameFieldValueHandler(String value) {
    final validationResult = state.validationResult.copyWith(
      isNameEmpty: value.isEmpty,
    );

    state = state.copyWith(
      validationResult: validationResult,
      isSetUpButtonEnable: validationResult.isFieldsNotEmpty,
    );
  }

  void emailFieldValueHandler(String value) {
    final validationResult = state.validationResult.copyWith(
      isEmailEmpty: value.isEmpty,
    );

    state = state.copyWith(
      validationResult: validationResult,
      isSetUpButtonEnable: validationResult.isFieldsNotEmpty,
    );
  }

  void passwordFieldValueHandler(String value) {
    final validationResult = state.validationResult.copyWith(
      isPasswordEmpty: value.isEmpty,
    );

    state = state.copyWith(
      validationResult: validationResult,
      isSetUpButtonEnable: validationResult.isFieldsNotEmpty,
    );
  }

  void confirmPasswordFieldValueHandler(String value) {
    final validationResult = state.validationResult.copyWith(
      isConfirmPasswordEmpty: value.isEmpty,
    );

    state = state.copyWith(
      validationResult: validationResult,
      isSetUpButtonEnable: validationResult.isFieldsNotEmpty,
    );
  }

  Future<void> validate({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final validationResult = _validateSignUpData(
      name: name,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );

    state = state.copyWith(
      validationResult: validationResult,
      isValidationFinished: validationResult.isFieldsValid,
    );
  }

  void resetValidationFinished() {
    state = state.copyWith(isValidationFinished: false);
  }

  void handleServerValidation(dynamic verificationResult) {
    if (verificationResult is DioException) {
      final dioException = verificationResult;
      final serverValidateErrorTexts = <String>[];

      final nameErrorText = ApiErrorHelper.getErrorByKey(
        dioException,
        key: 'name',
      );
      final emailErrorText = ApiErrorHelper.getErrorByKey(
        dioException,
        key: 'email',
      );
      final passwordErrorText = ApiErrorHelper.getErrorByKey(
        dioException,
        key: 'password',
      );
      final confirmPasswordErrorText = ApiErrorHelper.getErrorByKey(
        dioException,
        key: 'passwordConfirm',
      );

      for (final errorText in [
        nameErrorText,
        emailErrorText,
        passwordErrorText,
        confirmPasswordErrorText,
      ]) {
        if (errorText != null) {
          serverValidateErrorTexts.add(errorText);
        }
      }

      state = state.copyWith(
        validationResult: state.validationResult.copyWith(
          isServerValidateError: serverValidateErrorTexts.isNotEmpty,
          serverValidateErrorTexts: serverValidateErrorTexts,
          isNameInvalidError: nameErrorText != null,
          isEmailInvalidError: emailErrorText != null,
          isPasswordInvalidError: passwordErrorText != null,
          isPasswordMismatchError: confirmPasswordErrorText != null,
        ),
      );
    }
  }

  SignUpValidationResult _validateSignUpData({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    var validationResult = state.validationResult.copyWith(
      isNameInvalidError: false,
      isEmailInvalidError: false,
      isPasswordInvalidError: false,
      isPasswordMismatchError: false,
      isServerValidateError: false,
    );

    if (!AuthValidationHelper.isValidName(name)) {
      validationResult = validationResult.copyWith(
        isNameInvalidError: true,
      );
    }

    if (!AuthValidationHelper.isValidEmail(email)) {
      validationResult = validationResult.copyWith(
        isEmailInvalidError: true,
      );
    }

    if (!AuthValidationHelper.isValidPassword(password)) {
      validationResult = validationResult.copyWith(
        isPasswordInvalidError: true,
      );
    }

    if (password != confirmPassword) {
      validationResult = validationResult.copyWith(
        isPasswordMismatchError: true,
      );
    }

    return validationResult;
  }
}
