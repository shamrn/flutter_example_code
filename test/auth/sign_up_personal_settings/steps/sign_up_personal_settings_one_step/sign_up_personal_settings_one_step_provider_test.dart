import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_one_step/models/sign_up_personal_settings_one_step_errors.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_one_step/models/sign_up_personal_settings_one_step_request.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_one_step/models/sign_up_personal_settings_one_step_validation_result.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_one_step/provider/sign_up_personal_settings_one_step_provider.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_one_step/provider/sign_up_personal_settings_one_step_repository.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_one_step/provider/sign_up_personal_settings_one_step_state.dart';
import 'package:prime_ballet/common/helpers/number_generate_helper.dart';
import 'package:prime_ballet/common/models/profile_level_type.dart';

import 'sign_up_personal_settings_one_step_provider_test.mocks.dart';

@GenerateMocks([SignUpPersonalSettingsOneStepRepository])
void main() {
  final signUpPersonalSettingsOneStepRepository =
      MockSignUpPersonalSettingsOneStepRepository();

  final ref = ProviderContainer();

  final heightValues = NumberGenerateHelper.generateIntList(
    start: 90,
    end: 200,
    step: 1,
  );
  final weightValues = NumberGenerateHelper.generateDoubleList(
    start: 12,
    end: 120,
    step: 0.1,
  );
  final levelValues = ProfileLevelType.valuesAsSting;

  const dateOfBirth = '10.10.2010';
  const height = 145;
  const weight = 66.0;
  const level = ProfileLevelType.average;

  final signUpPersonalSettingsOneStepRequest =
      SignUpPersonalSettingsOneStepRequest(
    dateOfBirth: dateOfBirth,
    height: height,
    weight: weight,
    level: ProfileLevelType.getValueByString(level.name),
  );

  const serverValidateErrorText = 'server validate error text';

  final initialState = SignUpPersonalSettingsOneStepState(
    heightValues: heightValues,
    weightValues: weightValues,
    levelValues: levelValues,
  );

  late StateNotifierProvider<SignUpPersonalSettingsOneStepProvider,
      SignUpPersonalSettingsOneStepState> provider;

  setUp(() {
    provider = StateNotifierProvider<SignUpPersonalSettingsOneStepProvider,
        SignUpPersonalSettingsOneStepState>(
      (ref) => SignUpPersonalSettingsOneStepProvider(
        signUpPersonalSettingsOneStepRepository:
            signUpPersonalSettingsOneStepRepository,
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
    expect(ref.read(provider), initialState);
  });

  test('Check `dateOfBirthFieldListener` method', () {
    final notifier = ref.read(provider.notifier)
      ..dateOfBirthFieldValueHandler('10.10.10');

    expect(ref.read(provider), initialState);

    notifier.dateOfBirthFieldValueHandler('10.10.2010');
    expect(
      ref.read(provider),
      initialState.copyWith(isContinueButtonEnable: true),
    );

    notifier.dateOfBirthFieldValueHandler('');
    expect(ref.read(provider), initialState);
  });

  test('Check `setHeight` method', () async {
    const newHeightValue = 180;

    await ref.read(provider.notifier).setHeight(newHeightValue);

    expect(
      ref.read(provider),
      initialState.copyWith(selectedHeightValue: newHeightValue),
    );
  });

  test('Check `setWeight` method', () async {
    const newWeightValue = 80.5;

    await ref.read(provider.notifier).setWeight(newWeightValue);

    expect(
      ref.read(provider),
      initialState.copyWith(selectedWeightValue: newWeightValue),
    );
  });

  test('Check `setLevel` method', () async {
    const newLevelValue = ProfileLevelType.pro;

    await ref.read(provider.notifier).setLevel(newLevelValue.name);

    expect(
      ref.read(provider),
      initialState.copyWith(selectedLevelValue: newLevelValue),
    );
  });

  test('Check successful execution `updatePersonalSettings` method ', () async {
    when(signUpPersonalSettingsOneStepRepository
            .update(signUpPersonalSettingsOneStepRequest))
        .thenAnswer((_) async => {});

    unawaited(ref.read(provider.notifier).updatePersonalSettings(
          dateOfBirth: dateOfBirth,
        ));

    await expectLater(
      ref.read(provider),
      initialState.copyWith(isContinueButtonLoading: true),
    );
    await expectLater(
      ref.read(provider),
      initialState.copyWith(isFinished: true),
    );
  });

  test(
    'Check `updatePersonalSettings` method when dateOfBirth is not valid ',
    () async {
      await ref.read(provider.notifier).updatePersonalSettings(
            dateOfBirth: '55.15.2012',
          );

      await expectLater(
        ref.read(provider),
        initialState.copyWith(
          validationResult: const SignUpPersonalSettingsOneStepValidationResult(
            isDateOfBirthInvalidError: true,
          ),
        ),
      );
    },
  );

  test('Check `updatePersonalSettings` method when bad request ', () async {
    when(signUpPersonalSettingsOneStepRepository
            .update(signUpPersonalSettingsOneStepRequest))
        .thenThrow(
      createDioException(
        statusCode: HttpStatus.badRequest,
        data: {
          'date_of_birth': [serverValidateErrorText],
        },
      ),
    );

    unawaited(ref.read(provider.notifier).updatePersonalSettings(
          dateOfBirth: dateOfBirth,
        ));

    await expectLater(
      ref.read(provider),
      initialState.copyWith(
        validationResult: const SignUpPersonalSettingsOneStepValidationResult(
          isDateOfBirthInvalidError: true,
          isServerValidateError: true,
          serverValidateErrorText: serverValidateErrorText,
        ),
      ),
    );
  });

  test(
    'Check `updatePersonalSettings` method when dio unknown exception ',
    () async {
      when(signUpPersonalSettingsOneStepRepository
              .update(signUpPersonalSettingsOneStepRequest))
          .thenThrow(
        createDioException(statusCode: HttpStatus.internalServerError),
      );

      unawaited(ref.read(provider.notifier).updatePersonalSettings(
            dateOfBirth: dateOfBirth,
          ));

      await expectLater(
        ref.read(provider),
        initialState.copyWith(
          errors: const SignUpPersonalSettingsOneStepErrors(
            isServerUnknownError: true,
          ),
        ),
      );
    },
  );

  test('Check `updatePersonalSettings` method when base exception ', () async {
    when(signUpPersonalSettingsOneStepRepository
            .update(signUpPersonalSettingsOneStepRequest))
        .thenThrow(Exception());

    unawaited(ref.read(provider.notifier).updatePersonalSettings(
          dateOfBirth: dateOfBirth,
        ));

    await expectLater(
      ref.read(provider),
      initialState.copyWith(
        errors: const SignUpPersonalSettingsOneStepErrors(
          isServerUnknownError: true,
        ),
      ),
    );
  });

  test('Check `resetFinished` ', () async {
    when(signUpPersonalSettingsOneStepRepository
            .update(signUpPersonalSettingsOneStepRequest))
        .thenAnswer((_) async => {});

    unawaited(ref.read(provider.notifier).updatePersonalSettings(
          dateOfBirth: dateOfBirth,
        ));

    await expectLater(
      ref.read(provider),
      initialState.copyWith(isContinueButtonLoading: true),
    );
    await expectLater(
      ref.read(provider),
      initialState.copyWith(isFinished: true),
    );

    ref.read(provider.notifier).resetFinished();

    await expectLater(
      ref.read(provider),
      initialState,
    );
  });
}
