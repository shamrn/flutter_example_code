import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:prime_ballet/auth/sign_in/models/sign_in_errors.dart';
import 'package:prime_ballet/auth/sign_in/models/sign_in_request.dart';
import 'package:prime_ballet/auth/sign_in/models/sign_in_validation_result.dart';
import 'package:prime_ballet/auth/sign_in/provider/sign_in_provider.dart';
import 'package:prime_ballet/auth/sign_in/provider/sign_in_repository.dart';
import 'package:prime_ballet/auth/sign_in/provider/sign_in_state.dart';
import 'package:prime_ballet/common/env/environment_config.dart';
import 'package:prime_ballet/common/helpers/personal_settings_redirect_helper.dart';
import 'package:prime_ballet/common/models/personal_settings_redirect_type.dart';
import 'package:prime_ballet/common/models/playlist_response.dart';
import 'package:prime_ballet/common/models/playlist_training_program_progress_response.dart';
import 'package:prime_ballet/common/models/playlist_training_program_response.dart';
import 'package:prime_ballet/common/models/profile_level_type.dart';
import 'package:prime_ballet/common/models/profile_response.dart';
import 'package:prime_ballet/common/models/token_response.dart';
import 'package:prime_ballet/common/repositories/local_auth_data_repository.dart';
import 'package:prime_ballet/common/repositories/playlist_repository.dart';
import 'package:prime_ballet/common/repositories/profile_repository.dart';

import 'sign_in_provider_test.mocks.dart';

@GenerateMocks([
  EnvironmentConfig,
  SignInRepository,
  LocalAuthDataRepository,
  ProfileRepository,
  PlaylistRepository,
])
void main() {
  final environmentConfig = MockEnvironmentConfig();
  final signInRepository = MockSignInRepository();
  final localAuthDataRepository = MockLocalAuthDataRepository();
  final profileRepository = MockProfileRepository();
  final playlistRepository = MockPlaylistRepository();

  final personalSettingsHelper = PersonalSettingsRedirectHelper(
    profileRepository: profileRepository,
    playlistRepository: playlistRepository,
  );

  final ref = ProviderContainer();

  const email = 'Test@mail.com';
  const password = 'Password12345';
  const clientId = 'clientId';

  const serverValidateErrorText = 'server validate error text';

  const signInRequest = SignInRequest(
    clientId: clientId,
    email: email,
    password: password,
  );

  const authTokenResponse = TokenResponse(
    accessToken: 'access_token',
    refreshToken: 'refresh_token',
  );

  const profileResponse = ProfileResponse(
    isSubscription: true,
    isActiveTwoPaths: true,
    name: 'name',
    dateOfBirth: '01.2010.01',
    height: 1,
    weight: 1,
    numberOfSessions: 4,
    level: ProfileLevelType.pro,
    trainingTime: 15,
  );

  const profileEmptyPersonalSettingsResponse = ProfileResponse(
    isSubscription: true,
    isActiveTwoPaths: true,
    name: null,
    dateOfBirth: null,
    height: null,
    weight: null,
    numberOfSessions: null,
    level: null,
    trainingTime: null,
  );

  const profilePersonalSettingsTwoStepNotCompletedResponse = ProfileResponse(
    isSubscription: true,
    isActiveTwoPaths: true,
    name: 'name',
    dateOfBirth: '01.2010.01',
    height: 1,
    weight: 1,
    numberOfSessions: null,
    level: ProfileLevelType.pro,
    trainingTime: null,
  );

  const playlistResponse = PlaylistResponse(
    personal: PlaylistTrainingProgramResponse(
      title: 'personal',
      image: 'image',
      progress: PlaylistTrainingProgramProgressResponse(
        percent: 50,
        currentDay: 1,
        totalDays: 5,
        currentVideosCount: 10,
      ),
    ),
    dance: null,
  );

  late StateNotifierProvider<SignInProvider, SignInState> provider;

  setUp(() {
    provider = StateNotifierProvider<SignInProvider, SignInState>(
      (ref) => SignInProvider(
        environmentConfig: environmentConfig,
        signInRepository: signInRepository,
        localAuthDataRepository: localAuthDataRepository,
        personalSettingsRedirectHelper: personalSettingsHelper,
      ),
    );
  });

  DioException createDioException({
    required int statusCode,
    Map<String, dynamic>? data,
  }) {
    return DioException(
      response: Response(
        statusCode: statusCode,
        data: data,
        requestOptions: RequestOptions(),
      ),
      requestOptions: RequestOptions(),
    );
  }

  test('Check initial state', () {
    expect(ref.read(provider), const SignInState());
  });

  test('Check `emailFieldListener` method', () async {
    final notifier = ref.read(provider.notifier);

    await expectLater(ref.read(provider), const SignInState());

    notifier.emailFieldValueHandler('email');
    await expectLater(
      ref.read(provider),
      const SignInState(
        validationResult: SignInValidationResult(isEmailEmpty: false),
      ),
    );

    notifier.emailFieldValueHandler('');
    await expectLater(ref.read(provider), const SignInState());
  });

  test('Check `passwordFieldListener` method', () async {
    final notifier = ref.read(provider.notifier);

    await expectLater(ref.read(provider), const SignInState());

    notifier.passwordFieldValueHandler('password12345');
    await expectLater(
      ref.read(provider),
      const SignInState(
        validationResult: SignInValidationResult(isPasswordEmpty: false),
      ),
    );

    notifier.passwordFieldValueHandler('');
    await expectLater(ref.read(provider), const SignInState());
  });

  test('check `isSetUpButtonEnable` state property', () async {
    final notifier = ref.read(provider.notifier)
      ..emailFieldValueHandler('email')
      ..passwordFieldValueHandler('password12345');

    await expectLater(ref.read(provider).isSetUpButtonEnable, true);

    notifier.passwordFieldValueHandler('');
    await expectLater(ref.read(provider).isSetUpButtonEnable, false);
  });

  test(
    'Check successful execution `signIn` method when profile is completed',
    () async {
      when(environmentConfig.clientIdByPlatform).thenAnswer((_) => clientId);
      when(signInRepository.signIn(signInRequest)).thenAnswer(
        (_) async => authTokenResponse,
      );
      when(profileRepository.fetchProfile()).thenAnswer(
        (_) async => profileResponse,
      );
      when(playlistRepository.fetchPlaylist()).thenAnswer(
        (_) async => playlistResponse,
      );

      await ref
          .read(provider.notifier)
          .signIn(email: email, password: password);

      await expectLater(
        ref.read(provider),
        const SignInState(
          personalSettingsRedirectHelperType: PersonalSettingsRedirectType.home,
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
    },
  );

  test(
    'Check successful execution `signIn` method when personal settings '
    'one step is not completed',
    () async {
      when(environmentConfig.clientIdByPlatform).thenAnswer((_) => clientId);
      when(signInRepository.signIn(signInRequest)).thenAnswer(
        (_) async => authTokenResponse,
      );
      when(profileRepository.fetchProfile()).thenAnswer(
        (_) async => profileEmptyPersonalSettingsResponse,
      );
      when(playlistRepository.fetchPlaylist()).thenAnswer(
        (_) async => playlistResponse,
      );

      await ref
          .read(provider.notifier)
          .signIn(email: email, password: password);

      await expectLater(
        ref.read(provider),
        const SignInState(
          personalSettingsRedirectHelperType:
              PersonalSettingsRedirectType.authSignUpPersonalSettingsOneStep,
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
    },
  );

  test(
    'Check successful execution `signIn` method when personal settings '
    'two step is not completed',
    () async {
      when(environmentConfig.clientIdByPlatform).thenAnswer((_) => clientId);
      when(signInRepository.signIn(signInRequest)).thenAnswer(
        (_) async => authTokenResponse,
      );
      when(profileRepository.fetchProfile()).thenAnswer(
        (_) async => profilePersonalSettingsTwoStepNotCompletedResponse,
      );
      when(playlistRepository.fetchPlaylist()).thenAnswer(
        (_) async => playlistResponse,
      );

      await ref
          .read(provider.notifier)
          .signIn(email: email, password: password);

      await expectLater(
        ref.read(provider),
        const SignInState(
          personalSettingsRedirectHelperType:
              PersonalSettingsRedirectType.authSignUpPersonalSettingsTwoStep,
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
    },
  );

  test(
    'Check successful execution `signIn` method when personal settings '
    'third step is not completed, profile level is beginner',
    () async {
      when(environmentConfig.clientIdByPlatform).thenAnswer((_) => clientId);
      when(signInRepository.signIn(signInRequest)).thenAnswer(
        (_) async => authTokenResponse,
      );
      when(profileRepository.fetchProfile()).thenAnswer(
        (_) async => profileResponse.copyWith(level: ProfileLevelType.beginner),
      );
      when(playlistRepository.fetchPlaylist()).thenThrow(createDioException(
        statusCode: HttpStatus.notFound,
      ));

      await ref
          .read(provider.notifier)
          .signIn(email: email, password: password);

      await expectLater(
        ref.read(provider),
        const SignInState(
          personalSettingsRedirectHelperType: PersonalSettingsRedirectType
              .authSignUpPersonalSettingsThirdStepBeginnerAverage,
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
    },
  );

  test(
    'Check successful execution `signIn` method when personal settings '
    'third step is not completed, profile level is average',
    () async {
      when(environmentConfig.clientIdByPlatform).thenAnswer((_) => clientId);
      when(signInRepository.signIn(signInRequest)).thenAnswer(
        (_) async => authTokenResponse,
      );
      when(profileRepository.fetchProfile()).thenAnswer(
        (_) async => profileResponse.copyWith(level: ProfileLevelType.average),
      );
      when(playlistRepository.fetchPlaylist()).thenThrow(createDioException(
        statusCode: HttpStatus.notFound,
      ));

      await ref
          .read(provider.notifier)
          .signIn(email: email, password: password);

      await expectLater(
        ref.read(provider),
        const SignInState(
          personalSettingsRedirectHelperType: PersonalSettingsRedirectType
              .authSignUpPersonalSettingsThirdStepBeginnerAverage,
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
    },
  );

  test(
    'Check successful execution `signIn` method when personal settings '
    'third step is not completed, profile level is pro',
    () async {
      when(environmentConfig.clientIdByPlatform).thenAnswer((_) => clientId);
      when(signInRepository.signIn(signInRequest)).thenAnswer(
        (_) async => authTokenResponse,
      );
      when(profileRepository.fetchProfile()).thenAnswer(
        (_) async => profileResponse.copyWith(level: ProfileLevelType.pro),
      );
      when(playlistRepository.fetchPlaylist()).thenThrow(createDioException(
        statusCode: HttpStatus.notFound,
      ));

      await ref
          .read(provider.notifier)
          .signIn(email: email, password: password);

      await expectLater(
        ref.read(provider),
        const SignInState(
          personalSettingsRedirectHelperType: PersonalSettingsRedirectType
              .authSignUpPersonalSettingsThirdStepPro,
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
    },
  );

  test(
    'Check base dio exception `signIn` method when personal settings '
    'third step is not completed, profile level is pro',
    () async {
      when(environmentConfig.clientIdByPlatform).thenAnswer((_) => clientId);
      when(signInRepository.signIn(signInRequest)).thenAnswer(
        (_) async => authTokenResponse,
      );
      when(profileRepository.fetchProfile()).thenAnswer(
        (_) async => profileResponse.copyWith(level: ProfileLevelType.pro),
      );
      when(playlistRepository.fetchPlaylist()).thenThrow(
        createDioException(statusCode: HttpStatus.internalServerError),
      );

      await ref
          .read(provider.notifier)
          .signIn(email: email, password: password);

      await expectLater(
        ref.read(provider),
        const SignInState(errors: SignInErrors(isServerUnknownError: true)),
      );
    },
  );

  test('Check `signIn` method when bad request', () async {
    when(environmentConfig.clientIdByPlatform).thenAnswer((_) => clientId);
    when(signInRepository.signIn(signInRequest)).thenThrow(createDioException(
      statusCode: HttpStatus.badRequest,
      data: {'error_description': serverValidateErrorText},
    ));

    await ref.read(provider.notifier).signIn(email: email, password: password);

    await expectLater(
      ref.read(provider),
      const SignInState(
        validationResult: SignInValidationResult(
          isServerValidateError: true,
          serverValidateErrorText: serverValidateErrorText,
        ),
      ),
    );
  });

  test('Check `signIn` method when dio exception', () async {
    when(environmentConfig.clientIdByPlatform).thenAnswer((_) => clientId);
    when(signInRepository.signIn(signInRequest)).thenThrow(createDioException(
      statusCode: HttpStatus.internalServerError,
    ));

    await ref.read(provider.notifier).signIn(email: email, password: password);

    await expectLater(
      ref.read(provider),
      const SignInState(errors: SignInErrors(isServerUnknownError: true)),
    );
  });

  test('Check `signIn` method when base exception', () async {
    when(environmentConfig.clientIdByPlatform).thenAnswer((_) => clientId);
    when(signInRepository.signIn(signInRequest)).thenThrow(Exception());

    await ref.read(provider.notifier).signIn(email: email, password: password);

    await expectLater(
      ref.read(provider),
      const SignInState(errors: SignInErrors(isServerUnknownError: true)),
    );
  });
}
