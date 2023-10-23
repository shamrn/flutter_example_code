import 'dart:io';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_one_step/helpers/date_validation_helper.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_one_step/models/sign_up_personal_settings_one_step_errors.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_one_step/models/sign_up_personal_settings_one_step_request.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_one_step/models/sign_up_personal_settings_one_step_validation_result.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_one_step/provider/sign_up_personal_settings_one_step_repository.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_one_step/provider/sign_up_personal_settings_one_step_state.dart';
import 'package:prime_ballet/common/dio/helpers/api_error_helper.dart';
import 'package:prime_ballet/common/helpers/number_generate_helper.dart';
import 'package:prime_ballet/common/models/profile_level_type.dart';
import 'package:prime_ballet/common/providers/base_state_notifier.dart';

@injectable
class SignUpPersonalSettingsOneStepProvider
    extends BaseStateNotifier<SignUpPersonalSettingsOneStepState> {
  SignUpPersonalSettingsOneStepProvider({
    required SignUpPersonalSettingsOneStepRepository
        signUpPersonalSettingsOneStepRepository,
  })  : _signUpPersonalSettingsOneStepRepository =
            signUpPersonalSettingsOneStepRepository,
        super(const SignUpPersonalSettingsOneStepState());

  final SignUpPersonalSettingsOneStepRepository
      _signUpPersonalSettingsOneStepRepository;

  @override
  Future<void> onInit() async {
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

    state = state.copyWith(
      heightValues: heightValues,
      weightValues: weightValues,
      levelValues: ProfileLevelType.valuesAsSting,
    );
  }

  void dateOfBirthFieldValueHandler(String value) {
    state = state.copyWith(isContinueButtonEnable: value.length == 10);
  }

  Future<void> setHeight(int value) async {
    state = state.copyWith(selectedHeightValue: value);
  }

  Future<void> setWeight(double value) async {
    state = state.copyWith(selectedWeightValue: value);
  }

  Future<void> setLevel(String value) async {
    state = state.copyWith(
      selectedLevelValue: ProfileLevelType.getValueByString(value),
    );
  }

  Future<void> updatePersonalSettings({
    required String dateOfBirth,
  }) async {
    state = state.copyWith(
      isContinueButtonLoading: true,
      validationResult: null,
      errors: null,
    );

    if (!DateValidationHelper.isValidDate(
      dateOfBirth,
    )) {
      state = state.copyWith(
        isContinueButtonLoading: false,
        validationResult: const SignUpPersonalSettingsOneStepValidationResult(
          isDateOfBirthInvalidError: true,
        ),
      );

      return;
    }

    try {
      await _signUpPersonalSettingsOneStepRepository
          .update(SignUpPersonalSettingsOneStepRequest(
        dateOfBirth: dateOfBirth,
        height: state.selectedHeightValue,
        weight: state.selectedWeightValue,
        level: state.selectedLevelValue,
      ));

      state = state.copyWith(
        isContinueButtonLoading: false,
        isFinished: true,
      );
    } on DioException catch (dioException) {
      final response = dioException.response;

      if (response?.statusCode == HttpStatus.badRequest) {
        final serverValidationTextDateOfBirth = ApiErrorHelper.getErrorByKey(
          dioException,
          key: 'date_of_birth',
        );

        if (serverValidationTextDateOfBirth != null) {
          state = state.copyWith(
            isContinueButtonLoading: false,
            validationResult: SignUpPersonalSettingsOneStepValidationResult(
              isDateOfBirthInvalidError: true,
              isServerValidateError: true,
              serverValidateErrorText:
                  serverValidationTextDateOfBirth.toString(),
            ),
          );
        }

        return;
      }
      state = state.copyWith(
        isContinueButtonLoading: false,
        errors: const SignUpPersonalSettingsOneStepErrors(
          isServerUnknownError: true,
        ),
      );
    } on Exception catch (_) {
      state = state.copyWith(
        isContinueButtonLoading: false,
        errors: const SignUpPersonalSettingsOneStepErrors(
          isServerUnknownError: true,
        ),
      );
    }
  }

  void resetFinished() {
    state = state.copyWith(isFinished: false);
  }
}
