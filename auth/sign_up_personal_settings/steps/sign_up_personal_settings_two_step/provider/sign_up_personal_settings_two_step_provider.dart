import 'package:injectable/injectable.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_two_step/models/sign_up_personal_settings_two_step_errors.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_two_step/models/sign_up_personal_settings_two_step_redirect_type.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_two_step/models/sign_up_personal_settings_two_step_request.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_two_step/provider/sign_up_personal_settings_two_step_repository.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_two_step/provider/sign_up_personal_settings_two_step_state.dart';
import 'package:prime_ballet/common/helpers/number_generate_helper.dart';
import 'package:prime_ballet/common/models/profile_level_type.dart';
import 'package:prime_ballet/common/providers/base_state_notifier.dart';

@injectable
class SignUpPersonalSettingsTwoStepProvider
    extends BaseStateNotifier<SignUpPersonalSettingsTwoStepState> {
  SignUpPersonalSettingsTwoStepProvider({
    required SignUpPersonalSettingsTwoStepRepository
        signUpPersonalSettingsTwoStepRepository,
  })  : _signUpPersonalSettingsTwoStepRepository =
            signUpPersonalSettingsTwoStepRepository,
        super(const SignUpPersonalSettingsTwoStepState());

  final SignUpPersonalSettingsTwoStepRepository
      _signUpPersonalSettingsTwoStepRepository;

  @override
  Future<void> onInit() async {
    final numberOfSessionsValues = NumberGenerateHelper.generateIntList(
      start: 1,
      end: 7,
      step: 1,
    );

    state = state.copyWith(
      numberOfSessionsValues: numberOfSessionsValues,
      trainingTimeValues: [15, 30, 60],
    );
  }

  Future<void> setNumberOfSessions(int value) async {
    state = state.copyWith(selectedNumberOfSessionsValue: value);
  }

  Future<void> setTrainingTime(int value) async {
    state = state.copyWith(selectedTrainingTimeValue: value);
  }

  Future<void> updatePersonalSettings() async {
    state = state.copyWith(
      isContinueButtonLoading: true,
      errors: null,
    );

    try {
      final profileResponse = await _signUpPersonalSettingsTwoStepRepository
          .update(SignUpPersonalSettingsTwoStepRequest(
        numberOfSessions: state.selectedNumberOfSessionsValue,
        trainingTime: state.selectedTrainingTimeValue,
      ));

      state = state.copyWith(
        isContinueButtonLoading: false,
        redirectType: _getRedirectType(profileResponse.level),
      );
    } on Exception catch (_) {
      state = state.copyWith(
        isContinueButtonLoading: false,
        errors: const SignUpPersonalSettingsTwoStepErrors(
          isServerUnknownError: true,
        ),
      );
    }
  }

  SignUpPersonalSettingsTwoStepRedirectType _getRedirectType(
    ProfileLevelType? profileLevelType,
  ) {
    if (profileLevelType == ProfileLevelType.beginner ||
        profileLevelType == ProfileLevelType.average) {
      return SignUpPersonalSettingsTwoStepRedirectType
          .authSignUpPersonalSettingsThirdStepBeginnerAverage;
    }

    return SignUpPersonalSettingsTwoStepRedirectType
        .authSignUpPersonalSettingsThirdStepPro;
  }

  void resetRedirect() {
    state = state.copyWith(redirectType: null);
  }
}
