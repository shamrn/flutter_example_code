import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injectable/injectable.dart';
import 'package:prime_ballet/auth/common/helpers/auth_validation_helper.dart';
import 'package:prime_ballet/auth/sign_in/models/sign_in_errors.dart';
import 'package:prime_ballet/auth/sign_in/models/sign_in_request.dart';
import 'package:prime_ballet/auth/sign_in/models/sign_in_validation_result.dart';
import 'package:prime_ballet/auth/sign_in/provider/sign_in_repository.dart';
import 'package:prime_ballet/auth/sign_in/provider/sign_in_state.dart';
import 'package:prime_ballet/common/env/environment_config.dart';
import 'package:prime_ballet/common/helpers/personal_settings_redirect_helper.dart';
import 'package:prime_ballet/common/repositories/local_auth_data_repository.dart';

@injectable
class SignInProvider extends StateNotifier<SignInState> {
  SignInProvider({
    required EnvironmentConfig environmentConfig,
    required SignInRepository signInRepository,
    required LocalAuthDataRepository localAuthDataRepository,
    required PersonalSettingsRedirectHelper personalSettingsRedirectHelper,
  })  : _environmentConfig = environmentConfig,
        _signInRepository = signInRepository,
        _localAuthDataRepository = localAuthDataRepository,
        _personalSettingsRedirectHelper = personalSettingsRedirectHelper,
        super(const SignInState());

  final EnvironmentConfig _environmentConfig;
  final SignInRepository _signInRepository;
  final LocalAuthDataRepository _localAuthDataRepository;
  final PersonalSettingsRedirectHelper _personalSettingsRedirectHelper;

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

  Future<void> signIn({required String email, required String password}) async {
    state = state.copyWith(isSetUpButtonLoading: true);

    final validationResult = _validate(email: email);

    if (!validationResult.isFieldsValid) {
      state = state.copyWith(
        isSetUpButtonLoading: false,
        validationResult: validationResult,
      );

      return;
    }

    try {
      final signInResponse = await _signInRepository.signIn(SignInRequest(
        clientId: _environmentConfig.clientIdByPlatform,
        email: email,
        password: password,
      ));

      await _localAuthDataRepository.saveTokens(
        signInResponse.accessToken,
        signInResponse.refreshToken,
      );

      final personalSettingsRedirectType =
          await _personalSettingsRedirectHelper.redirectType;

      state = state.copyWith(
        isSetUpButtonLoading: false,
        personalSettingsRedirectHelperType: personalSettingsRedirectType,
      );
    } on DioException catch (dioException) {
      final response = dioException.response;

      if (response?.statusCode == HttpStatus.badRequest) {
        final serverValidateErrorText = response?.data['error_description'];

        state = state.copyWith(
          isSetUpButtonLoading: false,
          validationResult: validationResult.copyWith(
            isServerValidateError: serverValidateErrorText != null,
            serverValidateErrorText: serverValidateErrorText is String
                ? serverValidateErrorText
                : null,
          ),
        );
      } else {
        state = state.copyWith(
          isSetUpButtonLoading: false,
          errors: const SignInErrors(isServerUnknownError: true),
        );
      }
    } on Exception catch (_) {
      state = state.copyWith(
        isSetUpButtonLoading: false,
        errors: const SignInErrors(isServerUnknownError: true),
      );
    }
  }

  SignInValidationResult _validate({required String email}) {
    var validationResult = state.validationResult.copyWith(
      isEmailInvalidError: false,
      isServerValidateError: false,
    );

    if (!AuthValidationHelper.isValidEmail(email)) {
      validationResult = validationResult.copyWith(isEmailInvalidError: true);
    }

    return validationResult;
  }
}
