import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:prime_ballet/auth/common/models/sign_up_arguments.dart';
import 'package:prime_ballet/auth/sign_up_verification/models/auth_sign_up_request.dart';
import 'package:prime_ballet/auth/sign_up_verification/models/otp_send_request.dart';
import 'package:prime_ballet/auth/sign_up_verification/models/otp_verify_request.dart';
import 'package:prime_ballet/auth/sign_up_verification/models/sign_up_verification_errors.dart';
import 'package:prime_ballet/auth/sign_up_verification/provider/sign_up_verification_repository.dart';
import 'package:prime_ballet/auth/sign_up_verification/provider/sign_up_verification_state.dart';
import 'package:prime_ballet/common/dio/helpers/api_error_helper.dart';
import 'package:prime_ballet/common/env/environment_config.dart';
import 'package:prime_ballet/common/helpers/device_info_helper.dart';
import 'package:prime_ballet/common/providers/base_state_notifier.dart';
import 'package:prime_ballet/common/repositories/local_auth_data_repository.dart';

@injectable
class SignUpVerificationProvider
    extends BaseStateNotifier<SignUpVerificationState> {
  SignUpVerificationProvider({
    @factoryParam required SignUpArguments signUpData,
    required EnvironmentConfig environmentConfig,
    required DeviceInfoHelper deviceInfoHelper,
    required SignUpVerificationRepository signUpVerificationRepository,
    required LocalAuthDataRepository localAuthDataRepository,
  })  : _signUpData = signUpData,
        _environmentConfig = environmentConfig,
        _deviceInfoHelper = deviceInfoHelper,
        _signUpVerificationRepository = signUpVerificationRepository,
        _localAuthDataRepository = localAuthDataRepository,
        super(const SignUpVerificationState());

  static const _resendCodeCountdownSeconds = 60;
  static const _validCodeLength = 6;

  final SignUpArguments _signUpData;
  final EnvironmentConfig _environmentConfig;
  final DeviceInfoHelper _deviceInfoHelper;
  final SignUpVerificationRepository _signUpVerificationRepository;
  final LocalAuthDataRepository _localAuthDataRepository;

  Timer? _timer;

  @override
  Future<void> onInit() async {
    state = state.copyWith(email: _signUpData.email);

    try {
      final otpSendResponse = await _signUpVerificationRepository.send(
        OtpSendRequest(email: _signUpData.email),
      );

      state = state.copyWith(tokenForVerify: otpSendResponse.token);

      unawaited(_runResendCodeCountdown());
    } on DioException catch (dioExc) {
      final response = dioExc.response;

      if (response?.statusCode == HttpStatus.badRequest) {
        state = state.copyWith(
          dioException: dioExc,
          errors: const SignUpVerificationErrors(isBadRequest: true),
        );
      } else {
        state = state.copyWith(
          isResendCodeEnable: true,
          errors: const SignUpVerificationErrors(isOtpSendErrors: true),
        );
      }
    } on Exception catch (_) {
      state = state.copyWith(
        isResendCodeEnable: true,
        errors: const SignUpVerificationErrors(isOtpSendErrors: true),
      );
    }
  }

  @override
  void dispose() {
    if (_timer?.isActive ?? false) {
      _timer!.cancel();
    }

    super.dispose();
  }

  void pinPutFieldValueHandler(String value) {
    state = state.copyWith(
      isSetUpButtonEnable: value.length == _validCodeLength,
    );
  }

  Future<void> resendCode() async {
    state = state.copyWith(errors: const SignUpVerificationErrors());

    try {
      final otpSendResponse = await _signUpVerificationRepository.send(
        OtpSendRequest(email: _signUpData.email),
      );

      state = state.copyWith(tokenForVerify: otpSendResponse.token);

      state = state.copyWith(
        isResendCodeEnable: false,
        resendCodeCountdownSeconds: _resendCodeCountdownSeconds,
      );

      unawaited(_runResendCodeCountdown());
    } on DioException catch (dioException) {
      final response = dioException.response;

      if (response?.statusCode == HttpStatus.badRequest) {
        state = state.copyWith(
          dioException: dioException,
          errors: const SignUpVerificationErrors(isBadRequest: true),
        );
      } else {
        state = state.copyWith(
          errors: const SignUpVerificationErrors(isOtpSendErrors: true),
        );
      }
    } on Exception catch (_) {
      state = state.copyWith(
        errors: const SignUpVerificationErrors(isOtpSendErrors: true),
      );
    }
  }

  Future<void> verifyAndSignUp(String code) async {
    state = state.copyWith(
      isSetUpButtonLoading: true,
      errors: const SignUpVerificationErrors(),
    );

    try {
      await _signUpVerificationRepository.verify(OtpVerifyRequest(
        token: state.tokenForVerify!,
        code: code,
      ));

      final authTokenResponse = await _signUpVerificationRepository.signUp(
        AuthSignUpRequest(
          token: state.tokenForVerify!,
          name: _signUpData.name,
          password: _signUpData.password,
          clientId: _environmentConfig.clientIdByPlatform,
          deviceId: _deviceInfoHelper.id,
        ),
      );

      await _localAuthDataRepository.saveTokens(
        authTokenResponse.accessToken,
        authTokenResponse.refreshToken,
      );

      state = state.copyWith(isFinishedSignUp: true);
    } on DioException catch (dioException) {
      final response = dioException.response;

      if (response?.statusCode == HttpStatus.badRequest) {
        if (ApiErrorHelper.isContainsKeys(
          dioException,
          keys: ['name', 'email', 'password', 'passwordConfirm'],
        )) {
          state = state.copyWith(
            dioException: dioException,
            errors: const SignUpVerificationErrors(isBadRequest: true),
          );

          return;
        }

        final codeErrorText = ApiErrorHelper.getErrorByKey(
          dioException,
          key: 'non_field_errors',
        );

        if (codeErrorText != null) {
          state = state.copyWith(
            isSetUpButtonLoading: false,
            errors: SignUpVerificationErrors(
              isCodeInvalidError: true,
              serverErrorText: codeErrorText,
            ),
          );
        }
      } else {
        state = state.copyWith(
          isSetUpButtonLoading: false,
          errors: const SignUpVerificationErrors(isServerUnknownError: true),
        );
      }
    } on Exception catch (_) {
      state = state.copyWith(
        isSetUpButtonLoading: false,
        errors: const SignUpVerificationErrors(isServerUnknownError: true),
      );
    }
  }

  Future<void> _runResendCodeCountdown() async {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final timeSecond = timer.tick;

      state = state.copyWith(
        resendCodeCountdownSeconds: _resendCodeCountdownSeconds - timeSecond,
      );

      if (timeSecond == _resendCodeCountdownSeconds) {
        state = state.copyWith(isResendCodeEnable: true);

        timer.cancel();
      }
    });
  }
}
