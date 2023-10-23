import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:prime_ballet/auth/common/models/sign_up_arguments.dart';
import 'package:prime_ballet/auth/sign_up_verification/models/auth_sign_up_request.dart';
import 'package:prime_ballet/auth/sign_up_verification/models/otp_send_request.dart';
import 'package:prime_ballet/auth/sign_up_verification/models/otp_send_response.dart';
import 'package:prime_ballet/auth/sign_up_verification/models/otp_verify_request.dart';
import 'package:prime_ballet/auth/sign_up_verification/models/sign_up_verification_errors.dart';
import 'package:prime_ballet/auth/sign_up_verification/provider/sign_up_verification_provider.dart';
import 'package:prime_ballet/auth/sign_up_verification/provider/sign_up_verification_repository.dart';
import 'package:prime_ballet/auth/sign_up_verification/provider/sign_up_verification_state.dart';
import 'package:prime_ballet/common/env/environment_config.dart';
import 'package:prime_ballet/common/helpers/device_info_helper.dart';
import 'package:prime_ballet/common/models/token_response.dart';
import 'package:prime_ballet/common/repositories/local_auth_data_repository.dart';

import 'sign_up_verification_provider_test.mocks.dart';

@GenerateMocks([
  EnvironmentConfig,
  DeviceInfoHelper,
  SignUpVerificationRepository,
  LocalAuthDataRepository,
])
void main() {
  final environmentConfig = MockEnvironmentConfig();
  final deviceInfoHelper = MockDeviceInfoHelper();
  final signUpVerificationRepository = MockSignUpVerificationRepository();
  final localAuthDataRepository = MockLocalAuthDataRepository();

  final ref = ProviderContainer();

  const clientId = '1';
  const deviceId = '1';

  const signUpData = SignUpArguments(
    name: 'name',
    email: 'test@mail.com',
    password: 'password',
  );

  const tokenFirst = 'token_first';
  const tokenSecond = 'token_second';

  const code = '123456';

  const serverObjectReturnedOnError = ['Incorrect field'];

  final otpSendRequestFirst = OtpSendRequest(email: signUpData.email);
  const otpSendResponseFirst = OtpSendResponse(token: tokenFirst);

  final otpSendRequestSecond = OtpSendRequest(email: signUpData.email);
  const otpSendResponseSecond = OtpSendResponse(token: tokenSecond);

  const otpVerifyRequest = OtpVerifyRequest(
    token: tokenFirst,
    code: code,
  );

  final authSignUpRequest = AuthSignUpRequest(
    token: tokenFirst,
    name: signUpData.name,
    password: signUpData.password,
    clientId: clientId,
    deviceId: deviceId,
  );

  const authTokenResponse = TokenResponse(
    accessToken: 'access_token',
    refreshToken: 'refresh_token',
  );

  late StateNotifierProvider<SignUpVerificationProvider,
      SignUpVerificationState> provider;

  setUp(() {
    provider = StateNotifierProvider<SignUpVerificationProvider,
        SignUpVerificationState>(
      (ref) => SignUpVerificationProvider(
        signUpData: signUpData,
        environmentConfig: environmentConfig,
        deviceInfoHelper: deviceInfoHelper,
        signUpVerificationRepository: signUpVerificationRepository,
        localAuthDataRepository: localAuthDataRepository,
      ),
    );
  });

  DioException createDioException({
    required int statusCode,
    Map<String, dynamic>? data,
  }) {
    return DioException(
      response: Response(
        data: data,
        statusCode: statusCode,
        requestOptions: RequestOptions(),
      ),
      requestOptions: RequestOptions(),
    );
  }

  test('Check successful initialization', () async {
    when(signUpVerificationRepository.send(otpSendRequestFirst))
        .thenAnswer((_) async => otpSendResponseFirst);

    await expectLater(
      ref.read(provider),
      SignUpVerificationState(email: signUpData.email),
    );
    await expectLater(
      ref.read(provider),
      SignUpVerificationState(
        email: signUpData.email,
        tokenForVerify: tokenFirst,
      ),
    );

    await Future.delayed(const Duration(seconds: 1), () async {
      await expectLater(
        ref.read(provider),
        SignUpVerificationState(
          email: signUpData.email,
          tokenForVerify: tokenFirst,
          resendCodeCountdownSeconds: 59,
        ),
      );
    });
  });

  test('Check initialization when bad request', () async {
    final dioExc = createDioException(
      statusCode: HttpStatus.badRequest,
      data: {'email': serverObjectReturnedOnError},
    );

    when(signUpVerificationRepository.send(otpSendRequestFirst))
        .thenThrow(dioExc);

    await expectLater(
      ref.read(provider),
      SignUpVerificationState(
        email: signUpData.email,
        dioException: dioExc,
        errors: const SignUpVerificationErrors(isBadRequest: true),
      ),
    );
  });

  test('Check initialization when dio exception', () async {
    when(signUpVerificationRepository.send(otpSendRequestFirst)).thenThrow(
      createDioException(statusCode: HttpStatus.internalServerError),
    );

    await expectLater(
      ref.read(provider),
      SignUpVerificationState(
        email: signUpData.email,
        isResendCodeEnable: true,
        errors: const SignUpVerificationErrors(isOtpSendErrors: true),
      ),
    );
  });

  test('Check initialization when base exception', () async {
    when(signUpVerificationRepository.send(otpSendRequestFirst)).thenThrow(
      Exception(),
    );

    await expectLater(
      ref.read(provider),
      SignUpVerificationState(
        email: signUpData.email,
        isResendCodeEnable: true,
        errors: const SignUpVerificationErrors(isOtpSendErrors: true),
      ),
    );
  });

  test('Check `pinPutFieldListener` method', () async {
    when(signUpVerificationRepository.send(otpSendRequestFirst))
        .thenAnswer((_) async => otpSendResponseFirst);

    final notifier = ref.read(provider.notifier);

    await expectLater(
      ref.read(provider),
      SignUpVerificationState(email: signUpData.email),
    );

    notifier.pinPutFieldValueHandler('12345');
    await expectLater(
      ref.read(provider),
      SignUpVerificationState(
        email: signUpData.email,
        tokenForVerify: tokenFirst,
      ),
    );

    notifier.pinPutFieldValueHandler('123456');
    await expectLater(
      ref.read(provider),
      SignUpVerificationState(
        email: signUpData.email,
        tokenForVerify: tokenFirst,
        isSetUpButtonEnable: true,
      ),
    );

    notifier.pinPutFieldValueHandler('');
    await expectLater(
      ref.read(provider),
      SignUpVerificationState(
        email: signUpData.email,
        tokenForVerify: tokenFirst,
      ),
    );
  });

  test('Check `resendCode` method when success send code', () async {
    when(signUpVerificationRepository.send(otpSendRequestFirst))
        .thenAnswer((_) async => otpSendResponseFirst);

    await expectLater(
      ref.read(provider),
      SignUpVerificationState(email: signUpData.email),
    );
    await expectLater(
      ref.read(provider),
      SignUpVerificationState(
        email: signUpData.email,
        tokenForVerify: tokenFirst,
      ),
    );

    when(signUpVerificationRepository.send(otpSendRequestSecond))
        .thenAnswer((_) async => otpSendResponseSecond);

    await ref.read(provider.notifier).resendCode();

    await Future.delayed(const Duration(seconds: 1), () async {
      await expectLater(
        ref.read(provider),
        SignUpVerificationState(
          email: signUpData.email,
          tokenForVerify: tokenSecond,
          resendCodeCountdownSeconds: 59,
          errors: const SignUpVerificationErrors(),
        ),
      );
    });
  });

  test('Check `resendCode` method when bad request', () async {
    when(signUpVerificationRepository.send(otpSendRequestFirst))
        .thenAnswer((_) async => otpSendResponseFirst);

    await expectLater(
      ref.read(provider),
      SignUpVerificationState(email: signUpData.email),
    );
    await expectLater(
      ref.read(provider),
      SignUpVerificationState(
        email: signUpData.email,
        tokenForVerify: tokenFirst,
      ),
    );

    final dioExc = createDioException(
      statusCode: HttpStatus.badRequest,
      data: {'email': serverObjectReturnedOnError},
    );

    when(signUpVerificationRepository.send(otpSendRequestSecond))
        .thenThrow(dioExc);

    await ref.read(provider.notifier).resendCode();

    await expectLater(
      ref.read(provider),
      SignUpVerificationState(
        email: signUpData.email,
        tokenForVerify: tokenFirst,
        dioException: dioExc,
        errors: const SignUpVerificationErrors(isBadRequest: true),
      ),
    );
  });

  test('Check `resendCode` method when dio exception', () async {
    when(signUpVerificationRepository.send(otpSendRequestFirst))
        .thenAnswer((_) async => otpSendResponseFirst);

    await expectLater(
      ref.read(provider),
      SignUpVerificationState(email: signUpData.email),
    );
    await expectLater(
      ref.read(provider),
      SignUpVerificationState(
        email: signUpData.email,
        tokenForVerify: tokenFirst,
      ),
    );

    when(signUpVerificationRepository.send(otpSendRequestSecond)).thenThrow(
      createDioException(statusCode: HttpStatus.internalServerError),
    );

    await ref.read(provider.notifier).resendCode();

    await expectLater(
      ref.read(provider),
      SignUpVerificationState(
        email: signUpData.email,
        tokenForVerify: tokenFirst,
        errors: const SignUpVerificationErrors(isOtpSendErrors: true),
      ),
    );
  });

  test('Check `resendCode` method when base exception', () async {
    when(signUpVerificationRepository.send(otpSendRequestFirst))
        .thenAnswer((_) async => otpSendResponseFirst);

    await expectLater(
      ref.read(provider),
      SignUpVerificationState(email: signUpData.email),
    );
    await expectLater(
      ref.read(provider),
      SignUpVerificationState(
        email: signUpData.email,
        tokenForVerify: tokenFirst,
      ),
    );

    when(signUpVerificationRepository.send(otpSendRequestFirst)).thenThrow(
      Exception(),
    );

    await ref.read(provider.notifier).resendCode();

    await expectLater(
      ref.read(provider),
      SignUpVerificationState(
        email: signUpData.email,
        tokenForVerify: tokenFirst,
        errors: const SignUpVerificationErrors(isOtpSendErrors: true),
      ),
    );
  });

  test('Check successful execution `verifyAndSignUp` method', () async {
    when(environmentConfig.clientIdByPlatform).thenAnswer((_) => clientId);
    when(deviceInfoHelper.id).thenAnswer((_) => deviceId);
    when(signUpVerificationRepository.send(otpSendRequestFirst))
        .thenAnswer((_) async => otpSendResponseFirst);
    when(signUpVerificationRepository.verify(otpVerifyRequest)).thenAnswer(
      (_) async => {},
    );
    when(signUpVerificationRepository.signUp(authSignUpRequest)).thenAnswer(
      (_) async => authTokenResponse,
    );

    await expectLater(
      ref.read(provider),
      SignUpVerificationState(email: signUpData.email),
    );
    await expectLater(
      ref.read(provider),
      SignUpVerificationState(
        email: signUpData.email,
        tokenForVerify: tokenFirst,
      ),
    );

    await ref.read(provider.notifier).verifyAndSignUp(code);

    await expectLater(
      ref.read(provider),
      SignUpVerificationState(
        email: signUpData.email,
        tokenForVerify: tokenFirst,
        isSetUpButtonLoading: true,
        isFinishedSignUp: true,
        errors: const SignUpVerificationErrors(),
      ),
    );

    await untilCalled(
      localAuthDataRepository.saveTokens(
        authTokenResponse.accessToken,
        authTokenResponse.refreshToken,
      ),
    );

    verify(localAuthDataRepository.saveTokens(
      authTokenResponse.accessToken,
      authTokenResponse.refreshToken,
    )).called(1);
  });

  test(
    'Check `verifyAndSignUp` method when the entered code is not correct ',
    () async {
      when(signUpVerificationRepository.send(otpSendRequestFirst))
          .thenAnswer((_) async => otpSendResponseFirst);
      when(signUpVerificationRepository.verify(otpVerifyRequest)).thenThrow(
        createDioException(
          statusCode: HttpStatus.badRequest,
          data: {'non_field_errors': serverObjectReturnedOnError},
        ),
      );

      await expectLater(
        ref.read(provider),
        SignUpVerificationState(email: signUpData.email),
      );
      await expectLater(
        ref.read(provider),
        SignUpVerificationState(
          email: signUpData.email,
          tokenForVerify: tokenFirst,
        ),
      );

      await ref.read(provider.notifier).verifyAndSignUp(code);

      await expectLater(
        ref.read(provider),
        SignUpVerificationState(
          email: signUpData.email,
          tokenForVerify: tokenFirst,
          errors: SignUpVerificationErrors(
            isCodeInvalidError: true,
            serverErrorText: serverObjectReturnedOnError.first,
          ),
        ),
      );
    },
  );

  test(
    'Check `verifyAndSignUp` method when bad request',
    () async {
      when(signUpVerificationRepository.send(otpSendRequestFirst))
          .thenAnswer((_) async => otpSendResponseFirst);

      final dioExc = createDioException(
        statusCode: HttpStatus.badRequest,
        data: {'name': serverObjectReturnedOnError},
      );

      when(signUpVerificationRepository.verify(otpVerifyRequest)).thenThrow(
        dioExc,
      );

      await expectLater(
        ref.read(provider),
        SignUpVerificationState(email: signUpData.email),
      );
      await expectLater(
        ref.read(provider),
        SignUpVerificationState(
          email: signUpData.email,
          tokenForVerify: tokenFirst,
        ),
      );

      await ref.read(provider.notifier).verifyAndSignUp(code);

      await expectLater(
        ref.read(provider),
        SignUpVerificationState(
          email: signUpData.email,
          tokenForVerify: tokenFirst,
          dioException: dioExc,
          isSetUpButtonLoading: true,
          errors: const SignUpVerificationErrors(isBadRequest: true),
        ),
      );
    },
  );

  test(
    'Check `verifyAndSignUp` method when dio exception ',
    () async {
      when(signUpVerificationRepository.send(otpSendRequestFirst))
          .thenAnswer((_) async => otpSendResponseFirst);
      when(signUpVerificationRepository.verify(otpVerifyRequest)).thenThrow(
        createDioException(statusCode: HttpStatus.internalServerError),
      );

      await expectLater(
        ref.read(provider),
        SignUpVerificationState(email: signUpData.email),
      );
      await expectLater(
        ref.read(provider),
        SignUpVerificationState(
          email: signUpData.email,
          tokenForVerify: tokenFirst,
        ),
      );

      await ref.read(provider.notifier).verifyAndSignUp(code);

      await expectLater(
        ref.read(provider),
        SignUpVerificationState(
          email: signUpData.email,
          tokenForVerify: tokenFirst,
          errors: const SignUpVerificationErrors(isServerUnknownError: true),
        ),
      );
    },
  );

  test(
    'Check `verifyAndSignUp` method when base exception ',
    () async {
      when(signUpVerificationRepository.send(otpSendRequestFirst))
          .thenAnswer((_) async => otpSendResponseFirst);
      when(signUpVerificationRepository.verify(otpVerifyRequest)).thenThrow(
        Exception(),
      );

      await expectLater(
        ref.read(provider),
        SignUpVerificationState(email: signUpData.email),
      );
      await expectLater(
        ref.read(provider),
        SignUpVerificationState(
          email: signUpData.email,
          tokenForVerify: tokenFirst,
        ),
      );

      await ref.read(provider.notifier).verifyAndSignUp(code);

      await expectLater(
        ref.read(provider),
        SignUpVerificationState(
          email: signUpData.email,
          tokenForVerify: tokenFirst,
          errors: const SignUpVerificationErrors(isServerUnknownError: true),
        ),
      );
    },
  );
}
