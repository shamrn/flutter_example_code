import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_third_step/common/models/sign_up_personal_settings_third_step_create_playlist_request.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_third_step/common/repositories/sign_up_personal_settings_third_step_create_playlist_repository.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_third_step/sign_up_personal_settings_third_step_pro/models/sign_up_personal_settings_third_step_pro_errors.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_third_step/sign_up_personal_settings_third_step_pro/models/sign_up_personal_settings_third_step_pro_response.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_third_step/sign_up_personal_settings_third_step_pro/models/sign_up_personal_settings_third_step_pro_ui.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_third_step/sign_up_personal_settings_third_step_pro/provider/sign_up_personal_settings_third_step_pro_provider.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_third_step/sign_up_personal_settings_third_step_pro/provider/sign_up_personal_settings_third_step_pro_repository.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_third_step/sign_up_personal_settings_third_step_pro/provider/sign_up_personal_settings_third_step_pro_state.dart';
import 'package:prime_ballet/common/models/profile_level_type.dart';
import 'package:prime_ballet/common/models/profile_response.dart';
import 'package:prime_ballet/common/repositories/profile_repository.dart';

import 'sign_up_personal_settings_third_step_pro_provider_test.mocks.dart';

@GenerateMocks([
  ProfileRepository,
  SignUpPersonalSettingsThirdStepProRepository,
  SignUpPersonalSettingsThirdStepCreatePlaylistRepository,
])
void main() {
  final profileRepository = MockProfileRepository();
  final signUpPersonalSettingsThirdStepProRepository =
      MockSignUpPersonalSettingsThirdStepProRepository();
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
    SignUpPersonalSettingsThirdStepProResponse(
      id: 1,
      title: 'title',
      image: 'image',
      video: 'video',
    ),
    SignUpPersonalSettingsThirdStepProResponse(
      id: 2,
      title: 'title',
      image: 'image',
      video: 'video',
    ),
  ];

  const exerciseListUi = [
    SignUpPersonalSettingsThirdStepProUi(
      id: 1,
      title: 'title',
      imageUrl: 'image',
      videoUrl: 'video',
    ),
    SignUpPersonalSettingsThirdStepProUi(
      id: 2,
      title: 'title',
      imageUrl: 'image',
      videoUrl: 'video',
    ),
  ];

  final signUpPersonalSettingsThirdStepCreatePlaylistRequest =
      SignUpPersonalSettingsThirdStepCreatePlaylistRequest(
    ids: [exerciseListUi.first.id, exerciseListUi.last.id],
  );

  late StateNotifierProvider<SignUpPersonalSettingsThirdStepProProvider,
      SignUpPersonalSettingsThirdStepProState> provider;

  setUp(() {
    provider = StateNotifierProvider<SignUpPersonalSettingsThirdStepProProvider,
        SignUpPersonalSettingsThirdStepProState>(
      (ref) => SignUpPersonalSettingsThirdStepProProvider(
        profileRepository: profileRepository,
        personalSettingsThirdStepProRepository:
            signUpPersonalSettingsThirdStepProRepository,
        personalSettingsThirdStepCreatePlaylistRepository:
            signUpPersonalSettingsThirdStepCreatePlaylistRepository,
      ),
    );
  });

  test('Check `onInit` method when success', () async {
    when(profileRepository.fetchProfile())
        .thenAnswer((_) async => profileResponse);
    when(signUpPersonalSettingsThirdStepProRepository.fetchExercisePro())
        .thenAnswer((_) async => exerciseListResponse);

    await expectLater(
      ref.read(provider),
      const SignUpPersonalSettingsThirdStepProState(),
    );
    await expectLater(
      ref.read(provider),
      SignUpPersonalSettingsThirdStepProState(
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
      const SignUpPersonalSettingsThirdStepProState(),
    );
    await expectLater(
      ref.read(provider),
      const SignUpPersonalSettingsThirdStepProState(
        isLoading: false,
        errors: SignUpPersonalSettingsThirdStepProErrors(
          isServerUnknownError: true,
        ),
      ),
    );
  });

  test('Check `toggleExerciseIdSelection` method', () async {
    when(profileRepository.fetchProfile())
        .thenAnswer((_) async => profileResponse);
    when(signUpPersonalSettingsThirdStepProRepository.fetchExercisePro())
        .thenAnswer((_) async => exerciseListResponse);

    await expectLater(
      ref.read(provider),
      const SignUpPersonalSettingsThirdStepProState(),
    );

    ref
        .read(provider.notifier)
        .toggleExerciseIdSelection(exerciseListUi.first.id);
    await expectLater(
      ref.read(provider),
      SignUpPersonalSettingsThirdStepProState(
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
      SignUpPersonalSettingsThirdStepProState(
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
      SignUpPersonalSettingsThirdStepProState(
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
      SignUpPersonalSettingsThirdStepProState(
        isLoading: false,
        userName: profileResponse.name,
        exerciseList: exerciseListUi,
      ),
    );
  });

  test('Check `isSelectedCategory` method', () async {
    when(profileRepository.fetchProfile())
        .thenAnswer((_) async => profileResponse);
    when(signUpPersonalSettingsThirdStepProRepository.fetchExercisePro())
        .thenAnswer((_) async => exerciseListResponse);

    await expectLater(
      ref.read(provider),
      const SignUpPersonalSettingsThirdStepProState(),
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

  test('Check `saveSelectedExerciseCategories` method when success', () async {
    when(profileRepository.fetchProfile())
        .thenAnswer((_) async => profileResponse);
    when(signUpPersonalSettingsThirdStepProRepository.fetchExercisePro())
        .thenAnswer((_) async => exerciseListResponse);
    when(
      signUpPersonalSettingsThirdStepCreatePlaylistRepository.createPlaylist(
        signUpPersonalSettingsThirdStepCreatePlaylistRequest,
      ),
    ).thenAnswer((_) async => {});

    await expectLater(
      ref.read(provider),
      const SignUpPersonalSettingsThirdStepProState(),
    );

    ref.read(provider.notifier)
      ..toggleExerciseIdSelection(exerciseListUi.first.id)
      ..toggleExerciseIdSelection(exerciseListUi.last.id);

    unawaited(ref.read(provider.notifier).saveSelectedExercise());

    await expectLater(
      ref.read(provider),
      SignUpPersonalSettingsThirdStepProState(
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
      SignUpPersonalSettingsThirdStepProState(
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
    'Check `saveSelectedExerciseCategories` method when base exception',
    () async {
      when(profileRepository.fetchProfile())
          .thenAnswer((_) async => profileResponse);
      when(signUpPersonalSettingsThirdStepProRepository.fetchExercisePro())
          .thenAnswer((_) async => exerciseListResponse);
      when(signUpPersonalSettingsThirdStepCreatePlaylistRepository
          .createPlaylist(
        signUpPersonalSettingsThirdStepCreatePlaylistRequest,
      )).thenThrow(Exception());

      await expectLater(
        ref.read(provider),
        const SignUpPersonalSettingsThirdStepProState(),
      );

      ref.read(provider.notifier)
        ..toggleExerciseIdSelection(exerciseListUi.first.id)
        ..toggleExerciseIdSelection(exerciseListUi.last.id);

      unawaited(ref.read(provider.notifier).saveSelectedExercise());

      await expectLater(
        ref.read(provider),
        SignUpPersonalSettingsThirdStepProState(
          isLoading: false,
          userName: profileResponse.name,
          exerciseList: exerciseListUi,
          selectedExerciseIdList: [
            exerciseListUi.first.id,
            exerciseListUi.last.id,
          ],
          isContinueButtonEnable: true,
          errors: const SignUpPersonalSettingsThirdStepProErrors(
            isServerUnknownError: true,
          ),
        ),
      );
    },
  );
}
