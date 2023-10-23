import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:prime_ballet/auth/common/models/sign_up_personal_settings_two_step_arguments.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_one_step/models/sign_up_personal_settings_one_step_validation_result.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_one_step/provider/sign_up_personal_settings_one_step_provider.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_one_step/provider/sign_up_personal_settings_one_step_state.dart';
import 'package:prime_ballet/common/extensions/localization_extension.dart';
import 'package:prime_ballet/common/providers/consumer_state_with_provider.dart';
import 'package:prime_ballet/common/routes.dart';
import 'package:prime_ballet/common/ui/app_assets.dart';
import 'package:prime_ballet/common/ui/app_colors.dart';
import 'package:prime_ballet/common/ui/app_text_styles.dart';
import 'package:prime_ballet/common/widgets/app_outline_solid_button.dart';
import 'package:prime_ballet/common/widgets/app_text_field.dart';
import 'package:prime_ballet/common/widgets/scroll_selector.dart';

class SignUpPersonalSettingsOneStepPage extends ConsumerStatefulWidget {
  const SignUpPersonalSettingsOneStepPage({super.key});

  @override
  ConsumerState<SignUpPersonalSettingsOneStepPage> createState() =>
      _SignUpPersonalSettingsOneStepState();
}

class _SignUpPersonalSettingsOneStepState extends ConsumerStateWithProvider<
    SignUpPersonalSettingsOneStepProvider,
    SignUpPersonalSettingsOneStepState,
    SignUpPersonalSettingsOneStepPage> {
  final _dateOfBirthMaskTextInputFormatter = MaskTextInputFormatter(
    mask: '##.##.####',
    filter: {'#': RegExp('[0-9]')},
  );

  late final TextEditingController _dateOfBirthTextEditingController;

  @override
  void initState() {
    super.initState();

    _dateOfBirthTextEditingController = TextEditingController()
      ..addListener(_dateOfBirthControllerListener);
  }

  @override
  void dispose() {
    _dateOfBirthTextEditingController.dispose();

    super.dispose();
  }

  void _dateOfBirthControllerListener() {
    ref.read(provider.notifier).dateOfBirthFieldValueHandler(
          _dateOfBirthTextEditingController.text,
        );
  }

  void _errorsListener(
    SignUpPersonalSettingsOneStepState? previous,
    SignUpPersonalSettingsOneStepState next,
  ) {
    if (next.errors?.isServerUnknownError ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.locale.unknownError)),
      );
    }
  }

  void _finishedListener(
    SignUpPersonalSettingsOneStepState? previous,
    SignUpPersonalSettingsOneStepState next,
  ) {
    if (next.isFinished) {
      Navigator.of(context).pushNamed(
        Routes.authSignUpPersonalSettingsTwoStep,
        arguments: const SignUpPersonalSettingsTwoStepArguments(
          isStagedRedirect: true,
        ),
      );

      ref.read(provider.notifier).resetFinished();
    }
  }

  void _onTapContinue() {
    ref.read(provider.notifier).updatePersonalSettings(
          dateOfBirth: _dateOfBirthTextEditingController.text,
        );
  }

  List<Widget> _buildSelectors(SignUpPersonalSettingsOneStepState state) {
    return [
      ScrollSelector<int>(
        title:
            context.locale.authSignUpPersonalSettingsOneStepHeightSelectorTitle,
        values: state.heightValues,
        onValue: (value) async => ref.read(provider.notifier).setHeight(value),
      ),
      SizedBox(height: 24.h),
      ScrollSelector<double>(
        title:
            context.locale.authSignUpPersonalSettingsOneStepWeightSelectorTitle,
        values: state.weightValues,
        onValue: (value) async => ref.read(provider.notifier).setWeight(value),
      ),
      SizedBox(height: 24.h),
      ScrollSelector<String>(
        title:
            context.locale.authSignUpPersonalSettingsOneStepLevelSelectorTitle,
        values: state.levelValues,
        onValue: (value) async => ref.read(provider.notifier).setLevel(value),
      ),
    ];
  }

  Widget _buildValidationResult(
    SignUpPersonalSettingsOneStepValidationResult validationResult,
  ) {
    String text = '';

    if (validationResult.isServerValidateError &&
        validationResult.serverValidateErrorText != null) {
      text = validationResult.serverValidateErrorText!;
    } else if (validationResult.isDateOfBirthInvalidError) {
      text = context.locale.authSignUpPersonalSettingsOneStepIncorrectDateError;
    }

    return Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppTextStyles.latoBold.copyWith(
          fontSize: 13.sp,
          color: AppColors.error,
        ),
      ),
    );
  }

  Widget _buildBody() {
    final validationResult = ref.watch(provider.select(
      (value) => value.validationResult,
    ));

    return LayoutBuilder(builder: (context, constraints) {
      return SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: constraints.maxWidth,
            minHeight: constraints.maxHeight,
          ),
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.locale.authSignUpPersonalSettingsOneStepTitle,
                  style: AppTextStyles.serifSemiBold.copyWith(fontSize: 24.sp),
                ),
                SizedBox(height: 10.h),
                Text(
                  context.locale.authSignUpPersonalSettingsOneStepDescription,
                  style: AppTextStyles.latoRegular.copyWith(fontSize: 16.sp),
                ),
                SizedBox(height: 32.h),
                AppTextField(
                  label: context
                      .locale.authSignUpPersonalSettingsOneStepDateFieldLabel,
                  controller: _dateOfBirthTextEditingController,
                  keyboardType: TextInputType.datetime,
                  textInputFormatters: [
                    _dateOfBirthMaskTextInputFormatter,
                  ],
                  isError: validationResult?.isDateOfBirthInvalidError ?? false,
                ),
                SizedBox(height: 24.h),
                ..._buildSelectors(ref.read(provider)),
                const Spacer(),
                SizedBox(height: 40.h),
                if (validationResult != null) ...[
                  _buildValidationResult(validationResult),
                  SizedBox(height: 20.h),
                ],
                AppOutlineSolidButton(
                  title: context.locale
                      .authSignUpPersonalSettingsOneStepContinueButtonTitle,
                  titleColor: AppColors.white,
                  backgroundColor: AppColors.accent,
                  onTap: _onTapContinue,
                  isEnabled: ref.watch(
                    provider.select((value) => value.isContinueButtonEnable),
                  ),
                  isLoading: ref.watch(
                    provider.select((value) => value.isContinueButtonLoading),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    ref
      ..listen(provider, _errorsListener)
      ..listen(provider, _finishedListener);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(AppAssets.authBackgroundImage, fit: BoxFit.cover),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 52, sigmaY: 52),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  top: 32.h,
                  right: 20.w,
                  bottom: 18.h,
                  left: 20.w,
                ),
                child: _buildBody(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
