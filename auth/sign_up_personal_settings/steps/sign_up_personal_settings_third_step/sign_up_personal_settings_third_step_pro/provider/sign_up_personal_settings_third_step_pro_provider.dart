import 'package:injectable/injectable.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_third_step/common/models/sign_up_personal_settings_third_step_create_playlist_request.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_third_step/common/repositories/sign_up_personal_settings_third_step_create_playlist_repository.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_third_step/sign_up_personal_settings_third_step_pro/models/sign_up_personal_settings_third_step_pro_errors.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_third_step/sign_up_personal_settings_third_step_pro/models/sign_up_personal_settings_third_step_pro_response.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_third_step/sign_up_personal_settings_third_step_pro/models/sign_up_personal_settings_third_step_pro_ui.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_third_step/sign_up_personal_settings_third_step_pro/provider/sign_up_personal_settings_third_step_pro_repository.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_third_step/sign_up_personal_settings_third_step_pro/provider/sign_up_personal_settings_third_step_pro_state.dart';
import 'package:prime_ballet/common/models/profile_response.dart';
import 'package:prime_ballet/common/providers/base_state_notifier.dart';
import 'package:prime_ballet/common/repositories/profile_repository.dart';

@injectable
class SignUpPersonalSettingsThirdStepProProvider
    extends BaseStateNotifier<SignUpPersonalSettingsThirdStepProState> {
  SignUpPersonalSettingsThirdStepProProvider({
    required ProfileRepository profileRepository,
    required SignUpPersonalSettingsThirdStepProRepository
        personalSettingsThirdStepProRepository,
    required SignUpPersonalSettingsThirdStepCreatePlaylistRepository
        personalSettingsThirdStepCreatePlaylistRepository,
  })  : _profileRepository = profileRepository,
        _personalSettingsThirdStepProRepository =
            personalSettingsThirdStepProRepository,
        _personalSettingsThirdStepCreatePlaylistRepository =
            personalSettingsThirdStepCreatePlaylistRepository,
        super(const SignUpPersonalSettingsThirdStepProState());

  final ProfileRepository _profileRepository;
  final SignUpPersonalSettingsThirdStepProRepository
      _personalSettingsThirdStepProRepository;
  final SignUpPersonalSettingsThirdStepCreatePlaylistRepository
      _personalSettingsThirdStepCreatePlaylistRepository;

  @override
  Future<void> onInit() async {
    try {
      late final ProfileResponse profileResponse;
      late final List<SignUpPersonalSettingsThirdStepProResponse>
          exerciseResponse;

      await Future.wait<void>([
        (() async =>
            profileResponse = await _profileRepository.fetchProfile())(),
        (() async => exerciseResponse =
            await _personalSettingsThirdStepProRepository.fetchExercisePro())(),
      ]);

      state = state.copyWith(
        isLoading: false,
        userName: profileResponse.name,
        exerciseList: exerciseResponse
            .map(
              SignUpPersonalSettingsThirdStepProUi.fromResponse,
            )
            .toList(),
      );
    } on Exception catch (_) {
      state = state.copyWith(
        isLoading: false,
        errors: const SignUpPersonalSettingsThirdStepProErrors(
          isServerUnknownError: true,
        ),
      );
    }
  }

  void toggleExerciseIdSelection(int id) {
    final selectedCategoryIdList = List.of(state.selectedExerciseIdList);

    if (selectedCategoryIdList.contains(id)) {
      selectedCategoryIdList.remove(id);
    } else {
      selectedCategoryIdList.add(id);
    }

    state = state.copyWith(
      isContinueButtonEnable: selectedCategoryIdList.isNotEmpty,
      selectedExerciseIdList: selectedCategoryIdList,
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
        errors: const SignUpPersonalSettingsThirdStepProErrors(
          isServerUnknownError: true,
        ),
      );
    }
  }
}
