import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:prime_ballet/auth/sign_in/models/sign_in_validation_result.dart';
import 'package:prime_ballet/auth/sign_in/provider/sign_in_provider.dart';
import 'package:prime_ballet/auth/sign_in/provider/sign_in_state.dart';
import 'package:prime_ballet/common/extensions/localization_extension.dart';
import 'package:prime_ballet/common/models/personal_settings_redirect_type.dart';
import 'package:prime_ballet/common/providers/consumer_state_with_provider.dart';
import 'package:prime_ballet/common/routes.dart';
import 'package:prime_ballet/common/ui/app_assets.dart';
import 'package:prime_ballet/common/ui/app_colors.dart';
import 'package:prime_ballet/common/ui/app_text_styles.dart';
import 'package:prime_ballet/common/widgets/app_outline_transparent_button.dart';
import 'package:prime_ballet/common/widgets/app_password_text_field.dart';
import 'package:prime_ballet/common/widgets/app_text_field.dart';

class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  @override
  ConsumerState<SignInPage> createState() => _SignInState();
}

class _SignInState
    extends ConsumerStateWithProvider<SignInProvider, SignInState, SignInPage> {
  late final TextEditingController _emailTextEditingController;
  late final TextEditingController _passwordTextEditingController;

  @override
  void initState() {
    super.initState();

    _emailTextEditingController = TextEditingController()
      ..addListener(_emailControllerListener);

    _passwordTextEditingController = TextEditingController()
      ..addListener(_passwordControllerListener);
  }

  @override
  void dispose() {
    _emailTextEditingController.dispose();
    _passwordTextEditingController.dispose();

    super.dispose();
  }

  void _emailControllerListener() {
    ref.read(provider.notifier).emailFieldValueHandler(
          _emailTextEditingController.text,
        );
  }

  void _passwordControllerListener() {
    ref.read(provider.notifier).passwordFieldValueHandler(
          _passwordTextEditingController.text,
        );
  }

  void _errorsListener(SignInState? previous, SignInState next) {
    if (next.errors?.isServerUnknownError ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.locale.unknownError)),
      );
    }
  }

  void _redirectToPageListener(SignInState? previous, SignInState next) =>
      switch (next.personalSettingsRedirectHelperType) {
        PersonalSettingsRedirectType.authSignUpPersonalSettingsOneStep =>
          Navigator.of(context)
              .pushReplacementNamed(Routes.authSignUpPersonalSettingsOneStep),
        PersonalSettingsRedirectType.authSignUpPersonalSettingsTwoStep =>
          Navigator.of(context)
              .pushReplacementNamed(Routes.authSignUpPersonalSettingsTwoStep),
        PersonalSettingsRedirectType
              .authSignUpPersonalSettingsThirdStepBeginnerAverage =>
          Navigator.of(context).pushReplacementNamed(
            Routes.authSignUpPersonalSettingsThirdStepBeginnerAverage,
          ),
        PersonalSettingsRedirectType.authSignUpPersonalSettingsThirdStepPro =>
          Navigator.of(context).pushReplacementNamed(
            Routes.authSignUpPersonalSettingsThirdStepPro,
          ),
        PersonalSettingsRedirectType.home =>
          Navigator.of(context).pushReplacementNamed(Routes.home),
        _ => null
      };

  void _onTapForgotPassword() {}

  void _onTapSetUp() {
    ref.read(provider.notifier).signIn(
          email: _emailTextEditingController.text,
          password: _passwordTextEditingController.text,
        );
  }

  void _onTapSignUp() {
    Navigator.of(context).pushNamed(Routes.authSignUp);
  }

  Widget _buildTitleAndForms(SignInValidationResult validationResult) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.locale.authSignInTitle,
            style: AppTextStyles.serifSemiBold.copyWith(fontSize: 40.sp),
          ),
          SizedBox(height: 40.h),
          AppTextField(
            label: context.locale.authSignInEmailFieldLabel,
            controller: _emailTextEditingController,
            keyboardType: TextInputType.emailAddress,
            isError: validationResult.isEmailInvalidError,
          ),
          SizedBox(height: 38.h),
          AppPasswordTextField(
            label: context.locale.authSignInPasswordFieldLabel,
            controller: _passwordTextEditingController,
          ),
          Align(
            alignment: Alignment.topRight,
            child: TextButton(
              onPressed: _onTapForgotPassword,
              child: Text(
                context.locale.authSignInForgotPasswordButtonTitle,
                style: AppTextStyles.latoRegular.copyWith(fontSize: 13.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextError(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: AppTextStyles.latoBold.copyWith(
        fontSize: 13.sp,
        color: AppColors.error,
      ),
    );
  }

  Widget _buildError({
    required SignInValidationResult validationResult,
  }) {
    if (validationResult.isServerValidateError &&
        validationResult.serverValidateErrorText != null) {
      return _buildTextError(validationResult.serverValidateErrorText!);
    }

    return _buildTextError(context.locale.authSignInIncorrectEmailError);
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          context.locale.authSignInFooterFirstText,
          style: AppTextStyles.latoRegular.copyWith(fontSize: 13.sp),
        ),
        SizedBox(width: 4.w),
        GestureDetector(
          onTap: _onTapSignUp,
          child: Text(
            context.locale.authSignInFooterSecondText,
            style: AppTextStyles.latoBold.copyWith(
              fontSize: 13.sp,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        SizedBox(width: 4.w),
        Text(
          context.locale.authSignInFooterThirdText,
          style: AppTextStyles.latoRegular.copyWith(fontSize: 13.sp),
        ),
      ],
    );
  }

  Widget _buildBody() {
    final state = ref.watch(provider);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: constraints.maxWidth,
              minHeight: constraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  _buildTitleAndForms(state.validationResult),
                  const Spacer(),
                  if (!state.validationResult.isFieldsValid ||
                      state.validationResult.isServerValidateError) ...[
                    _buildError(validationResult: state.validationResult),
                    SizedBox(height: 20.h),
                  ],
                  AppOutlineTransparentButton(
                    title: context.locale.authSignInSetUpButtonTitle,
                    onTap: _onTapSetUp,
                    isEnabled: state.isSetUpButtonEnable,
                    isLoading: state.isSetUpButtonLoading,
                  ),
                  SizedBox(height: 20.h),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref
      ..listen(provider, _errorsListener)
      ..listen(provider, _redirectToPageListener);

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
