import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:prime_ballet/auth/common/models/sign_up_arguments.dart';
import 'package:prime_ballet/auth/common/widgets/log_in_or_skip.dart';
import 'package:prime_ballet/auth/sign_up/models/sign_up_validation_result.dart';
import 'package:prime_ballet/auth/sign_up/provider/sign_up_provider.dart';
import 'package:prime_ballet/auth/sign_up/provider/sign_up_state.dart';
import 'package:prime_ballet/common/extensions/localization_extension.dart';
import 'package:prime_ballet/common/providers/consumer_state_with_provider.dart';
import 'package:prime_ballet/common/routes.dart';
import 'package:prime_ballet/common/ui/app_assets.dart';
import 'package:prime_ballet/common/ui/app_colors.dart';
import 'package:prime_ballet/common/ui/app_text_styles.dart';
import 'package:prime_ballet/common/widgets/app_outline_transparent_button.dart';
import 'package:prime_ballet/common/widgets/app_password_text_field.dart';
import 'package:prime_ballet/common/widgets/app_text_field.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpState();
}

class _SignUpState
    extends ConsumerStateWithProvider<SignUpProvider, SignUpState, SignUpPage> {
  late final TextEditingController _nameTextEditingController;
  late final TextEditingController _emailTextEditingController;
  late final TextEditingController _passwordTextEditingController;
  late final TextEditingController _confirmPasswordTextEditingController;

  @override
  void initState() {
    super.initState();

    _nameTextEditingController = TextEditingController()
      ..addListener(_nameControllerListener);

    _emailTextEditingController = TextEditingController()
      ..addListener(_emailControllerListener);

    _passwordTextEditingController = TextEditingController()
      ..addListener(_passwordControllerListener);

    _confirmPasswordTextEditingController = TextEditingController()
      ..addListener(_confirmPasswordControllerListener);
  }

  @override
  void dispose() {
    _nameTextEditingController.dispose();
    _emailTextEditingController.dispose();
    _passwordTextEditingController.dispose();
    _confirmPasswordTextEditingController.dispose();

    super.dispose();
  }

  void _nameControllerListener() {
    ref.read(provider.notifier).nameFieldValueHandler(
          _nameTextEditingController.text,
        );
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

  void _confirmPasswordControllerListener() {
    ref.read(provider.notifier).confirmPasswordFieldValueHandler(
          _confirmPasswordTextEditingController.text,
        );
  }

  Future<void> validationFinishedListener(
    SignUpState? previous,
    SignUpState next,
  ) async {
    if (next.isValidationFinished) {
      ref.read(provider.notifier).resetValidationFinished();

      final serverValidationResult = await Navigator.of(context).pushNamed(
        Routes.authSignUpVerification,
        arguments: SignUpArguments(
          name: _nameTextEditingController.text,
          email: _emailTextEditingController.text,
          password: _passwordTextEditingController.text,
        ),
      );

      ref.read(provider.notifier).handleServerValidation(
            serverValidationResult,
          );
    }
  }

  void _onTapSetUp() {
    ref.read(provider.notifier).validate(
          name: _nameTextEditingController.text,
          email: _emailTextEditingController.text,
          password: _passwordTextEditingController.text,
          confirmPassword: _confirmPasswordTextEditingController.text,
        );
  }

  void _onTapTermsAndConditions() {}

  void _onTapPrivacyPolicy() {}

  Widget _buildTitle() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        context.locale.authSignUpTitle,
        style: AppTextStyles.serifSemiBold.copyWith(fontSize: 40.sp),
      ),
    );
  }

  List<Widget> _buildForms({
    required SignUpValidationResult validationResult,
  }) {
    return [
      AppTextField(
        label: context.locale.authSignUpNameFieldLabel,
        controller: _nameTextEditingController,
        keyboardType: TextInputType.name,
        isError: validationResult.isNameInvalidError,
      ),
      SizedBox(height: 38.h),
      AppTextField(
        label: context.locale.authSignUpEmailFieldLabel,
        controller: _emailTextEditingController,
        keyboardType: TextInputType.emailAddress,
        isError: validationResult.isEmailInvalidError,
      ),
      SizedBox(height: 38.h),
      AppPasswordTextField(
        label: context.locale.authSignUpPasswordFieldLabel,
        controller: _passwordTextEditingController,
        isError: validationResult.isPasswordInvalidError,
      ),
      SizedBox(height: 38.h),
      AppPasswordTextField(
        label: context.locale.authSignUpConfirmPasswordFieldLabel,
        controller: _confirmPasswordTextEditingController,
        isError: validationResult.isPasswordMismatchError,
      ),
    ];
  }

  Widget _buildTextError(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: AppTextStyles.latoBold
          .copyWith(fontSize: 13.sp, color: AppColors.error),
    );
  }

  List<Widget> _buildErrors({
    required SignUpValidationResult validationResult,
  }) {
    final textErrorList = <Widget>[];

    if (validationResult.isServerValidateError) {
      for (final errorText in validationResult.serverValidateErrorTexts) {
        textErrorList.add(_buildTextError(errorText));
      }
    } else {
      if (validationResult.isNameInvalidError) {
        textErrorList.add(
          _buildTextError(context.locale.authSignUpIncorrectNameError),
        );
      }

      if (validationResult.isEmailInvalidError) {
        textErrorList.add(
          _buildTextError(context.locale.authSignUpIncorrectEmailError),
        );
      }

      if (validationResult.isPasswordInvalidError) {
        textErrorList.add(_buildTextError(
          context.locale.authSignUpIncorrectPasswordError,
        ));
      }

      if (validationResult.isPasswordMismatchError) {
        textErrorList.add(
          _buildTextError(context.locale.authSignUpMismatchPasswordError),
        );
      }
    }

    return textErrorList;
  }

  Widget _buildConditions() {
    return Column(
      children: [
        Text(
          context.locale.authSignUpConditionsFirstText,
          style: AppTextStyles.latoRegular.copyWith(fontSize: 13.sp),
        ),
        SizedBox(height: 2.h),
        GestureDetector(
          onTap: _onTapTermsAndConditions,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                context.locale.authSignUpConditionsSecondText,
                style: AppTextStyles.latoBold.copyWith(
                  fontSize: 13.sp,
                  decoration: TextDecoration.underline,
                ),
              ),
              SizedBox(width: 4.w),
              Text(
                context.locale.authSignUpConditionsThirdText,
                style: AppTextStyles.latoRegular.copyWith(fontSize: 13.sp),
              ),
              SizedBox(width: 4.w),
              GestureDetector(
                onTap: _onTapPrivacyPolicy,
                child: Text(
                  context.locale.authSignUpConditionsFourthText,
                  style: AppTextStyles.latoBold.copyWith(
                    fontSize: 13.sp,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
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
                  Expanded(
                    child: Column(
                      children: [
                        _buildTitle(),
                        SizedBox(height: 35.h),
                        ..._buildForms(
                          validationResult: state.validationResult,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 40.h),
                  if (state.validationResult.isFieldsValid) _buildConditions(),
                  if (!state.validationResult.isFieldsValid) ...[
                    ..._buildErrors(validationResult: state.validationResult),
                  ],
                  SizedBox(height: 20.h),
                  AppOutlineTransparentButton(
                    title: context.locale.authSignUpSetUpButtonTitle,
                    onTap: _onTapSetUp,
                    isEnabled: state.isSetUpButtonEnable,
                  ),
                  SizedBox(height: 20.h),
                  const LogInOrSkip(),
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
    ref.listen(provider, validationFinishedListener);

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
