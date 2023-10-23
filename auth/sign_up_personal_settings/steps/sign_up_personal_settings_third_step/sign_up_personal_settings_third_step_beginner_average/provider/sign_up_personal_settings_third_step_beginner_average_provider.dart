import 'package:injectable/injectable.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_third_step/common/models/sign_up_personal_settings_third_step_create_playlist_request.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_third_step/common/repositories/sign_up_personal_settings_third_step_create_playlist_repository.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_third_step/sign_up_personal_settings_third_step_beginner_average/models/sign_up_personal_settings_third_step_beginner_average_errors.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_third_step/sign_up_personal_settings_third_step_beginner_average/models/sign_up_personal_settings_third_step_beginner_average_response.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_third_step/sign_up_personal_settings_third_step_beginner_average/models/sign_up_personal_settings_third_step_beginner_average_ui.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_third_step/sign_up_personal_settings_third_step_beginner_average/provider/sign_up_personal_settings_third_step_beginner_average_repository.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_third_step/sign_up_personal_settings_third_step_beginner_average/provider/sign_up_personal_settings_third_step_beginner_average_state.dart';
import 'package:prime_ballet/common/models/profile_response.dart';
import 'package:prime_ballet/common/providers/base_state_notifier.dart';
import 'package:prime_ballet/common/repositories/profile_repository.dart';

@injectable
class SignUpPersonalSettingsThirdStepBeginnerAverageProvider
    extends BaseStateNotifier<
        SignUpPersonalSettingsThirdStepBeginnerAverageState> {
  SignUpPersonalSettingsThirdStepBeginnerAverageProvider({
    required ProfileRepository profileRepository,
    required SignUpPersonalSettingsThirdStepBeginnerAverageRepository
        personalSettingsThirdStepBeginnerAverageRepository,
    required SignUpPersonalSettingsThirdStepCreatePlaylistRepository
        personalSettingsThirdStepCreatePlaylistRepository,
  })  : _profileRepository = profileRepository,
        _personalSettingsThirdStepBeginnerAverageRepository =
            personalSettingsThirdStepBeginnerAverageRepository,
        _personalSettingsThirdStepCreatePlaylistRepository =
            personalSettingsThirdStepCreatePlaylistRepository,
        super(const SignUpPersonalSettingsThirdStepBeginnerAverageState());

  final ProfileRepository _profileRepository;
  final SignUpPersonalSettingsThirdStepBeginnerAverageRepository
      _personalSettingsThirdStepBeginnerAverageRepository;
  final SignUpPersonalSettingsThirdStepCreatePlaylistRepository
      _personalSettingsThirdStepCreatePlaylistRepository;

  @override
  Future<void> onInit() async {
    try {
      late final ProfileResponse profileResponse;
      late final List<SignUpPersonalSettingsThirdStepBeginnerAverageResponse>
          exerciseResponseList;

      await Future.wait<void>([
        (() async =>
            profileResponse = await _profileRepository.fetchProfile())(),
        (() async => exerciseResponseList =
            await _personalSettingsThirdStepBeginnerAverageRepository
                .fetchExercise())(),
      ]);

      state = state.copyWith(
        isLoading: false,
        userName: profileResponse.name,
        exerciseList: exerciseResponseList
            .map(
              SignUpPersonalSettingsThirdStepBeginnerAverageUi.fromResponse,
            )
            .toList(),
      );
    } on Exception catch (_) {
      state = state.copyWith(
        isLoading: false,
        errors: const SignUpPersonalSettingsThirdStepBeginnerAverageErrors(
          isServerUnknownError: true,
        ),
      );
    }
  }

  void toggleExerciseIdSelection(int id) {
    final selectedExerciseIdList = List.of(state.selectedExerciseIdList);

    if (selectedExerciseIdList.contains(id)) {
      selectedExerciseIdList.remove(id);
    } else {
      selectedExerciseIdList.add(id);
    }

    state = state.copyWith(
      isContinueButtonEnable: selectedExerciseIdList.isNotEmpty,
      selectedExerciseIdList: selectedExerciseIdList,
    );
  }

  bool isExerciseSelected(int id) {
    return state.selectedExerciseIdList.contains(id);
  }

  Future<void> saveSelectedExercise() async {
    state = state.copyWith(isContinueButtonLoading: true);

    try {
      await _personalSettingsThirdStepCreatePlaylistRepository
          .createPlaylist(SignUpPersonalSettingsThirdStepCreatePlaylistRequest(
        ids: state.selectedExerciseIdList,
      ));

      state = state.copyWith(isContinueButtonLoading: false, isFinish: true);
    } on Exception catch (_) {
      state = state.copyWith(
        isContinueButtonLoading: false,
        errors: const SignUpPersonalSettingsThirdStepBeginnerAverageErrors(
          isServerUnknownError: true,
        ),
      );
    }
  }
}
