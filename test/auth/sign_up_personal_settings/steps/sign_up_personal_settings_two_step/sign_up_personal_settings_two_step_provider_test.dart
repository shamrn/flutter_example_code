import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_two_step/models/sign_up_personal_settings_two_step_errors.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_two_step/models/sign_up_personal_settings_two_step_redirect_type.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_two_step/models/sign_up_personal_settings_two_step_request.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_two_step/provider/sign_up_personal_settings_two_step_provider.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_two_step/provider/sign_up_personal_settings_two_step_repository.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_two_step/provider/sign_up_personal_settings_two_step_state.dart';
import 'package:prime_ballet/common/helpers/number_generate_helper.dart';
import 'package:prime_ballet/common/models/profile_level_type.dart';
import 'package:prime_ballet/common/models/profile_response.dart';

import 'sign_up_personal_settings_two_step_provider_test.mocks.dart';

@GenerateMocks([SignUpPersonalSettingsTwoStepRepository])
void main() {
  final signUpPersonalSettingsTwoStepRepository =
      MockSignUpPersonalSettingsTwoStepRepository();

  final ref = ProviderContainer();

  final numberOfSessionsValues = NumberGenerateHelper.generateIntList(
    start: 1,
    end: 7,
    step: 1,
  );

  const signUpPersonalSettingsTwoStepRequest =
      SignUpPersonalSettingsTwoStepRequest(
    numberOfSessions: 4,
    trainingTime: 30,
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

  final initialState = SignUpPersonalSettingsTwoStepState(
    numberOfSessionsValues: numberOfSessionsValues,
    trainingTimeValues: [15, 30, 60],
  );

  late StateNotifierProvider<SignUpPersonalSettingsTwoStepProvider,
      SignUpPersonalSettingsTwoStepState> provider;

  setUp(() {
    provider = StateNotifierProvider<SignUpPersonalSettingsTwoStepProvider,
        SignUpPersonalSettingsTwoStepState>(
      (ref) => SignUpPersonalSettingsTwoStepProvider(
        signUpPersonalSettingsTwoStepRepository:
            signUpPersonalSettingsTwoStepRepository,
      ),
    );
  });

  test('Check initial state', () {
    expect(ref.read(provider), initialState);
  });

  test('Check `setWeek` method', () async {
    const newNumberOfSessionsValue = 7;

    await ref
        .read(provider.notifier)
        .setNumberOfSessions(newNumberOfSessionsValue);

    expect(
      ref.read(provider),
      initialState.copyWith(
        selectedNumberOfSessionsValue: newNumberOfSessionsValue,
      ),
    );
  });

  test('Check `setTime` method', () async {
    const newTrainingTimeValue = 60;

    await ref.read(provider.notifier).setTrainingTime(newTrainingTimeValue);

    expect(
      ref.read(provider),
      initialState.copyWith(selectedTrainingTimeValue: newTrainingTimeValue),
    );
  });

  test(
    'Check successful execution `updatePersonalSettings` method '
    'when profile level is beginner ',
    () async {
      when(signUpPersonalSettingsTwoStepRepository
              .update(signUpPersonalSettingsTwoStepRequest))
          .thenAnswer(
        (_) async => profileResponse.copyWith(level: ProfileLevelType.beginner),
      );

      unawaited(ref.read(provider.notifier).updatePersonalSettings());

      await expectLater(
        ref.read(provider),
        initialState.copyWith(isContinueButtonLoading: true),
      );
      await expectLater(
        ref.read(provider),
        initialState.copyWith(
          redirectType: SignUpPersonalSettingsTwoStepRedirectType
              .authSignUpPersonalSettingsThirdStepBeginnerAverage,
        ),
      );
    },
  );

  test(
    'Check successful execution `updatePersonalSettings` method '
    'when profile level is average ',
    () async {
      when(signUpPersonalSettingsTwoStepRepository
              .update(signUpPersonalSettingsTwoStepRequest))
          .thenAnswer(
        (_) async => profileResponse.copyWith(
          level: ProfileLevelType.average,
        ),
      );

      unawaited(ref.read(provider.notifier).updatePersonalSettings());

      await expectLater(
        ref.read(provider),
        initialState.copyWith(isContinueButtonLoading: true),
      );
      await expectLater(
        ref.read(provider),
        initialState.copyWith(
          redirectType: SignUpPersonalSettingsTwoStepRedirectType
              .authSignUpPersonalSettingsThirdStepBeginnerAverage,
        ),
      );
    },
  );

  test(
    'Check successful execution `updatePersonalSettings` method '
    'when profile level is pro ',
    () async {
      when(signUpPersonalSettingsTwoStepRepository
              .update(signUpPersonalSettingsTwoStepRequest))
          .thenAnswer(
        (_) async => profileResponse.copyWith(level: ProfileLevelType.pro),
      );

      unawaited(ref.read(provider.notifier).updatePersonalSettings());

      await expectLater(
        ref.read(provider),
        initialState.copyWith(isContinueButtonLoading: true),
      );
      await expectLater(
        ref.read(provider),
        initialState.copyWith(
          redirectType: SignUpPersonalSettingsTwoStepRedirectType
              .authSignUpPersonalSettingsThirdStepPro,
        ),
      );
    },
  );

  test('Check `updatePersonalSettings` method when base exception', () async {
    when(signUpPersonalSettingsTwoStepRepository
            .update(signUpPersonalSettingsTwoStepRequest))
        .thenThrow(Exception());

    unawaited(ref.read(provider.notifier).updatePersonalSettings());

    await expectLater(
      ref.read(provider),
      initialState.copyWith(
        errors: const SignUpPersonalSettingsTwoStepErrors(
          isServerUnknownError: true,
        ),
      ),
    );
  });

  test(
    'Check `resetRedirect` method`',
    () async {
      when(signUpPersonalSettingsTwoStepRepository
              .update(signUpPersonalSettingsTwoStepRequest))
          .thenAnswer(
        (_) async => profileResponse.copyWith(
          level: ProfileLevelType.average,
        ),
      );

      unawaited(ref.read(provider.notifier).updatePersonalSettings());

      await expectLater(
        ref.read(provider),
        initialState.copyWith(isContinueButtonLoading: true),
      );
      await expectLater(
        ref.read(provider),
        initialState.copyWith(
          redirectType: SignUpPersonalSettingsTwoStepRedirectType
              .authSignUpPersonalSettingsThirdStepBeginnerAverage,
        ),
      );

      ref.read(provider.notifier).resetRedirect();

      await expectLater(
        ref.read(provider),
        initialState,
      );
    },
  );
}
