import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_third_step/common/models/sign_up_personal_settings_third_step_create_playlist_request.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_third_step/common/repositories/sign_up_personal_settings_third_step_create_playlist_repository.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_third_step/sign_up_personal_settings_third_step_beginner_average/models/sign_up_personal_settings_third_step_beginner_average_errors.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_third_step/sign_up_personal_settings_third_step_beginner_average/models/sign_up_personal_settings_third_step_beginner_average_response.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_third_step/sign_up_personal_settings_third_step_beginner_average/models/sign_up_personal_settings_third_step_beginner_average_ui.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_third_step/sign_up_personal_settings_third_step_beginner_average/provider/sign_up_personal_settings_third_step_beginner_average_provider.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_third_step/sign_up_personal_settings_third_step_beginner_average/provider/sign_up_personal_settings_third_step_beginner_average_repository.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_third_step/sign_up_personal_settings_third_step_beginner_average/provider/sign_up_personal_settings_third_step_beginner_average_state.dart';
import 'package:prime_ballet/common/models/profile_level_type.dart';
import 'package:prime_ballet/common/models/profile_response.dart';
import 'package:prime_ballet/common/repositories/profile_repository.dart';

import 'sign_up_personal_settings_third_step_beginner_average_provider_test.mocks.dart';

@GenerateMocks([
  ProfileRepository,
  SignUpPersonalSettingsThirdStepBeginnerAverageRepository,
  SignUpPersonalSettingsThirdStepCreatePlaylistRepository,
])
void main() {
  final profileRepository = MockProfileRepository();
  final signUpPersonalSettingsThirdStepBeginnerAverageRepository =
      MockSignUpPersonalSettingsThirdStepBeginnerAverageRepository();
  final signUpPersonalSettingsThirdStepCreatePlaylistRepository =
      MockSignUpPersonalSettingsThirdStepCreatePlaylistRepository();

  final ref = ProviderContainer();

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

  const exerciseListResponse = [
    SignUpPersonalSettingsThirdStepBeginnerAverageResponse(
      id: 1,
      title: 'title',
    ),
    SignUpPersonalSettingsThirdStepBeginnerAverageResponse(
      id: 2,
      title: 'title',
    ),
  ];

  const exerciseListUi = [
    SignUpPersonalSettingsThirdStepBeginnerAverageUi(
      id: 1,
      title: 'title',
    ),
    SignUpPersonalSettingsThirdStepBeginnerAverageUi(
      id: 2,
      title: 'title',
    ),
  ];

  final signUpPersonalSettingsThirdStepCreatePlaylistRequest =
      SignUpPersonalSettingsThirdStepCreatePlaylistRequest(
    ids: [exerciseListUi.first.id, exerciseListUi.last.id],
  );

  late StateNotifierProvider<
      SignUpPersonalSettingsThirdStepBeginnerAverageProvider,
      SignUpPersonalSettingsThirdStepBeginnerAverageState> provider;

  setUp(() {
    provider = StateNotifierProvider<
        SignUpPersonalSettingsThirdStepBeginnerAverageProvider,
        SignUpPersonalSettingsThirdStepBeginnerAverageState>(
      (ref) => SignUpPersonalSettingsThirdStepBeginnerAverageProvider(
        profileRepository: profileRepository,
        personalSettingsThirdStepBeginnerAverageRepository:
            signUpPersonalSettingsThirdStepBeginnerAverageRepository,
        personalSettingsThirdStepCreatePlaylistRepository:
            signUpPersonalSettingsThirdStepCreatePlaylistRepository,
      ),
    );
  });

  test('Check `onInit` method when success', () async {
    when(profileRepository.fetchProfile())
        .thenAnswer((_) async => profileResponse);
    when(signUpPersonalSettingsThirdStepBeginnerAverageRepository
            .fetchExercise())
        .thenAnswer((_) async => exerciseListResponse);

    await expectLater(
      ref.read(provider),
      const SignUpPersonalSettingsThirdStepBeginnerAverageState(),
    );
    await expectLater(
      ref.read(provider),
      SignUpPersonalSettingsThirdStepBeginnerAverageState(
        isLoading: false,
        userName: profileResponse.name,
        exerciseList: exerciseListUi,
      ),
    );
  });

  test('Check `onInit` method when base exception', () async {
    when(profileRepository.fetchProfile()).thenThrow(Exception());

    await expectLater(
      ref.read(provider),
      const SignUpPersonalSettingsThirdStepBeginnerAverageState(),
    );
    await expectLater(
      ref.read(provider),
      const SignUpPersonalSettingsThirdStepBeginnerAverageState(
        isLoading: false,
        errors: SignUpPersonalSettingsThirdStepBeginnerAverageErrors(
          isServerUnknownError: true,
        ),
      ),
    );
  });

  test('Check `toggleExerciseIdSelection` method', () async {
    when(profileRepository.fetchProfile())
        .thenAnswer((_) async => profileResponse);
    when(signUpPersonalSettingsThirdStepBeginnerAverageRepository
            .fetchExercise())
        .thenAnswer((_) async => exerciseListResponse);

    await expectLater(
      ref.read(provider),
      const SignUpPersonalSettingsThirdStepBeginnerAverageState(),
    );

    ref
        .read(provider.notifier)
        .toggleExerciseIdSelection(exerciseListUi.first.id);
    await expectLater(
      ref.read(provider),
      SignUpPersonalSettingsThirdStepBeginnerAverageState(
        isLoading: false,
        userName: profileResponse.name,
        exerciseList: exerciseListUi,
        selectedExerciseIdList: [exerciseListUi.first.id],
        isContinueButtonEnable: true,
      ),
    );

    ref
        .read(provider.notifier)
        .toggleExerciseIdSelection(exerciseListUi.last.id);
    await expectLater(
      ref.read(provider),
      SignUpPersonalSettingsThirdStepBeginnerAverageState(
        isLoading: false,
        userName: profileResponse.name,
        exerciseList: exerciseListUi,
        selectedExerciseIdList: [
          exerciseListUi.first.id,
          exerciseListUi.last.id,
        ],
        isContinueButtonEnable: true,
      ),
    );

    ref
        .read(provider.notifier)
        .toggleExerciseIdSelection(exerciseListUi.first.id);
    await expectLater(
      ref.read(provider),
      SignUpPersonalSettingsThirdStepBeginnerAverageState(
        isLoading: false,
        userName: profileResponse.name,
        exerciseList: exerciseListUi,
        selectedExerciseIdList: [exerciseListUi.last.id],
        isContinueButtonEnable: true,
      ),
    );

    ref
        .read(provider.notifier)
        .toggleExerciseIdSelection(exerciseListUi.last.id);
    await expectLater(
      ref.read(provider),
      SignUpPersonalSettingsThirdStepBeginnerAverageState(
        isLoading: false,
        userName: profileResponse.name,
        exerciseList: exerciseListUi,
      ),
    );
  });

  test('Check `isExerciseSelected` method', () async {
    when(profileRepository.fetchProfile())
        .thenAnswer((_) async => profileResponse);
    when(signUpPersonalSettingsThirdStepBeginnerAverageRepository
            .fetchExercise())
        .thenAnswer((_) async => exerciseListResponse);

    await expectLater(
      ref.read(provider),
      const SignUpPersonalSettingsThirdStepBeginnerAverageState(),
    );

    expect(
      ref.read(provider.notifier).isExerciseSelected(exerciseListUi.first.id),
      isFalse,
    );

    ref
        .read(provider.notifier)
        .toggleExerciseIdSelection(exerciseListUi.first.id);

    expect(
      ref.read(provider.notifier).isExerciseSelected(exerciseListUi.first.id),
      isTrue,
    );
  });

  test('Check `saveSelectedExercise` method when success', () async {
    when(profileRepository.fetchProfile())
        .thenAnswer((_) async => profileResponse);
    when(signUpPersonalSettingsThirdStepBeginnerAverageRepository
            .fetchExercise())
        .thenAnswer((_) async => exerciseListResponse);
    when(
      signUpPersonalSettingsThirdStepCreatePlaylistRepository.createPlaylist(
        signUpPersonalSettingsThirdStepCreatePlaylistRequest,
      ),
    ).thenAnswer((_) async => {});

    await expectLater(
      ref.read(provider),
      const SignUpPersonalSettingsThirdStepBeginnerAverageState(),
    );

    ref.read(provider.notifier)
      ..toggleExerciseIdSelection(exerciseListUi.first.id)
      ..toggleExerciseIdSelection(exerciseListUi.last.id);

    unawaited(ref.read(provider.notifier).saveSelectedExercise());

    await expectLater(
      ref.read(provider),
      SignUpPersonalSettingsThirdStepBeginnerAverageState(
        isLoading: false,
        userName: profileResponse.name,
        exerciseList: exerciseListUi,
        selectedExerciseIdList: [
          exerciseListUi.first.id,
          exerciseListUi.last.id,
        ],
        isContinueButtonEnable: true,
        isContinueButtonLoading: true,
      ),
    );
    await expectLater(
      ref.read(provider),
      SignUpPersonalSettingsThirdStepBeginnerAverageState(
        isLoading: false,
        userName: profileResponse.name,
        exerciseList: exerciseListUi,
        selectedExerciseIdList: [
          exerciseListUi.first.id,
          exerciseListUi.last.id,
        ],
        isContinueButtonEnable: true,
        isFinish: true,
      ),
    );
  });

  test(
    'Check `saveSelectedExercise` method when base exception',
    () async {
      when(profileRepository.fetchProfile())
          .thenAnswer((_) async => profileResponse);
      when(signUpPersonalSettingsThirdStepBeginnerAverageRepository
              .fetchExercise())
          .thenAnswer((_) async => exerciseListResponse);
      when(signUpPersonalSettingsThirdStepCreatePlaylistRepository
          .createPlaylist(
        signUpPersonalSettingsThirdStepCreatePlaylistRequest,
      )).thenThrow(Exception());

      await expectLater(
        ref.read(provider),
        const SignUpPersonalSettingsThirdStepBeginnerAverageState(),
      );

      ref.read(provider.notifier)
        ..toggleExerciseIdSelection(exerciseListUi.first.id)
        ..toggleExerciseIdSelection(exerciseListUi.last.id);

      unawaited(ref.read(provider.notifier).saveSelectedExercise());

      await expectLater(
        ref.read(provider),
        SignUpPersonalSettingsThirdStepBeginnerAverageState(
          isLoading: false,
          userName: profileResponse.name,
          exerciseList: exerciseListUi,
          selectedExerciseIdList: [
            exerciseListUi.first.id,
            exerciseListUi.last.id,
          ],
          isContinueButtonEnable: true,
          errors: const SignUpPersonalSettingsThirdStepBeginnerAverageErrors(
            isServerUnknownError: true,
          ),
        ),
      );
    },
  );
}
