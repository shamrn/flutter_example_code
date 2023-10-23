import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:prime_ballet/auth/common/models/sign_up_personal_settings_third_step_beginner_average_arguments.dart';
import 'package:prime_ballet/auth/common/models/sign_up_personal_settings_third_step_pro_arguments.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_two_step/models/sign_up_personal_settings_two_step_redirect_type.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_two_step/provider/sign_up_personal_settings_two_step_provider.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_two_step/provider/sign_up_personal_settings_two_step_state.dart';
import 'package:prime_ballet/common/extensions/localization_extension.dart';
import 'package:prime_ballet/common/providers/consumer_state_with_provider.dart';
import 'package:prime_ballet/common/routes.dart';
import 'package:prime_ballet/common/ui/app_assets.dart';
import 'package:prime_ballet/common/ui/app_colors.dart';
import 'package:prime_ballet/common/ui/app_text_styles.dart';
import 'package:prime_ballet/common/widgets/app_outline_solid_button.dart';
import 'package:prime_ballet/common/widgets/app_top_bar.dart';
import 'package:prime_ballet/common/widgets/scroll_selector.dart';

class SignUpPersonalSettingsTwoStepPage extends ConsumerStatefulWidget {
  const SignUpPersonalSettingsTwoStepPage({
    bool isStagedRedirect = false,
    Key? key,
  })  : _isStagedRedirect = isStagedRedirect,
        super(key: key);

  final bool _isStagedRedirect;

  @override
  ConsumerState<SignUpPersonalSettingsTwoStepPage> createState() =>
      _SignUpPersonalSettingsTwoStepState();
}

class _SignUpPersonalSettingsTwoStepState extends ConsumerStateWithProvider<
    SignUpPersonalSettingsTwoStepProvider,
    SignUpPersonalSettingsTwoStepState,
    SignUpPersonalSettingsTwoStepPage> {
  void _errorsListener(
    SignUpPersonalSettingsTwoStepState? previous,
    SignUpPersonalSettingsTwoStepState next,
  ) {
    if (next.errors?.isServerUnknownError ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.locale.unknownError)),
      );
    }
  }

  void _redirectToPageListener(
    SignUpPersonalSettingsTwoStepState? previous,
    SignUpPersonalSettingsTwoStepState next,
  ) {
    if (next.redirectType != null) {
      switch (next.redirectType!) {
        case SignUpPersonalSettingsTwoStepRedirectType
              .authSignUpPersonalSettingsThirdStepBeginnerAverage:
          Navigator.of(context).pushNamed(
            Routes.authSignUpPersonalSettingsThirdStepBeginnerAverage,
            arguments:
                const SignUpPersonalSettingsThirdStepBeginnerAverageArguments(
              isStagedRedirect: true,
            ),
          );

        case SignUpPersonalSettingsTwoStepRedirectType
              .authSignUpPersonalSettingsThirdStepPro:
          Navigator.of(context).pushNamed(
            Routes.authSignUpPersonalSettingsThirdStepPro,
            arguments: const SignUpPersonalSettingsThirdStepProArguments(
              isStagedRedirect: true,
            ),
          );
      }

      ref.read(provider.notifier).resetRedirect();
    }
  }

  void _onTapContinue() {
    ref.read(provider.notifier).updatePersonalSettings();
  }

  List<Widget> _buildSelectors(SignUpPersonalSettingsTwoStepState state) {
    return [
      ScrollSelector<int>(
        title: context.locale
            .authSignUpPersonalSettingsTwoStepNumberOfSessionsSelectorTitle,
        values: state.numberOfSessionsValues,
        onValue: (value) async =>
            ref.read(provider.notifier).setNumberOfSessions(value),
      ),
      SizedBox(height: 24.h),
      ScrollSelector<int>(
        title: context
            .locale.authSignUpPersonalSettingsTwoStepTrainingTimeSelectorTitle,
        values: state.trainingTimeValues,
        onValue: (value) async =>
            ref.read(provider.notifier).setTrainingTime(value),
      ),
    ];
  }

  Widget _buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.locale.authSignUpPersonalSettingsTwoStepTitle,
          style: AppTextStyles.serifSemiBold.copyWith(fontSize: 24.sp),
        ),
        SizedBox(height: 10.h),
        Text(
          context.locale.authSignUpPersonalSettingsTwoStepDescription,
          style: AppTextStyles.latoRegular.copyWith(fontSize: 16.sp),
        ),
        SizedBox(height: 32.h),
        SizedBox(height: 24.h),
        ..._buildSelectors(ref.read(provider)),
        const Spacer(),
        SizedBox(height: 40.h),
        AppOutlineSolidButton(
          title: context
              .locale.authSignUpPersonalSettingsTwoStepContinueButtonTitle,
          titleColor: AppColors.white,
          backgroundColor: AppColors.accent,
          onTap: _onTapContinue,
          isLoading: ref.watch(
            provider.select((value) => value.isContinueButtonLoading),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    ref
      ..listen(provider, _errorsListener)
      ..listen(provider, _redirectToPageListener);

    return Scaffold(
      appBar: widget._isStagedRedirect ? const AppTopBar() : null,
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(AppAssets.authBackgroundImage, fit: BoxFit.cover),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 52, sigmaY: 52),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  top: 4.h,
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
