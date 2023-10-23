import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';
import 'package:prime_ballet/auth/common/models/sign_up_arguments.dart';
import 'package:prime_ballet/auth/sign_up_verification/provider/sign_up_verification_provider.dart';
import 'package:prime_ballet/auth/sign_up_verification/provider/sign_up_verification_state.dart';
import 'package:prime_ballet/common/extensions/localization_extension.dart';
import 'package:prime_ballet/common/providers/auto_dispose_consumer_state_with_provider.dart';
import 'package:prime_ballet/common/routes.dart';
import 'package:prime_ballet/common/ui/app_assets.dart';
import 'package:prime_ballet/common/ui/app_colors.dart';
import 'package:prime_ballet/common/ui/app_text_styles.dart';
import 'package:prime_ballet/common/widgets/app_outline_transparent_button.dart';

class SignUpVerificationPage extends ConsumerStatefulWidget {
  const SignUpVerificationPage({
    required SignUpArguments signUpData,
    super.key,
  }) : _signUpData = signUpData;

  @override
  ConsumerState<SignUpVerificationPage> createState() =>
      // ignore: no_logic_in_create_state
      _SignUpVerificationState(_signUpData);

  final SignUpArguments _signUpData;
}

class _SignUpVerificationState extends AutoDisposeConsumerStateWithProvider<
    SignUpVerificationProvider,
    SignUpVerificationState,
    SignUpVerificationPage> {
  _SignUpVerificationState(SignUpArguments signUpData)
      : super(param1: signUpData);

  late final TextEditingController _pinPutTextEditingController;

  @override
  void initState() {
    super.initState();

    _pinPutTextEditingController = TextEditingController()
      ..addListener(_pinPutControllerListener);
  }

  @override
  void dispose() {
    _pinPutTextEditingController.dispose();

    super.dispose();
  }

  void _pinPutControllerListener() {
    ref.read(provider.notifier).pinPutFieldValueHandler(
          _pinPutTextEditingController.text,
        );
  }

  void _showSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  void _errorsListener(
    SignUpVerificationState? previous,
    SignUpVerificationState next,
  ) {
    final errors = next.errors;

    if (errors == null) return;

    if (errors.isServerUnknownError) {
      _showSnackBar(context.locale.unknownError);
    }

    if (errors.isOtpSendErrors) {
      _showSnackBar(context.locale.authSignUpVerificationOtpSendErrors);
    }

    if (errors.isBadRequest) {
      Navigator.of(context).pop(next.dioException);
    }
  }

  void _signUpFinishedListener(
    SignUpVerificationState? previous,
    SignUpVerificationState next,
  ) {
    if (next.isFinishedSignUp) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        Routes.authSignUpPersonalSettingsOneStep,
        (route) => false,
      );
    }
  }

  void _onTapEmailIsWrong() {
    Navigator.of(context).pop();
  }

  void _onTapResendCode() {
    ref.read(provider.notifier).resendCode();
    _pinPutTextEditingController.text = '';
  }

  void _onTapSetUp() {
    ref
        .read(provider.notifier)
        .verifyAndSignUp(_pinPutTextEditingController.text);
  }

  Widget _buildPinPut(bool isCodeInvalidError) {
    return Pinput(
      controller: _pinPutTextEditingController,
      length: 6,
      showCursor: false,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      defaultPinTheme: PinTheme(
        width: 42.5.w,
        height: 60.h,
        textStyle: AppTextStyles.latoBold.copyWith(fontSize: 24.sp),
        decoration: BoxDecoration(
          color: AppColors.pinPutBackground,
          borderRadius: BorderRadius.circular(3.r),
          border: isCodeInvalidError
              ? Border.all(width: 2.w, color: AppColors.error)
              : null,
        ),
      ),
    );
  }

  Widget _buildResendCode({
    required bool isEnable,
    required int countdownSeconds,
  }) {
    return Center(
      child: TextButton(
        onPressed: isEnable ? _onTapResendCode : null,
        child: Text(
          isEnable
              ? context.locale.authSignUpVerificationResendCodeButtonEnableTitle
              : context.locale
                  .authSignUpVerificationResendCodeButtonDisableTitle(
                  countdownSeconds,
                ),
          style: AppTextStyles.latoBold.copyWith(
            fontSize: 13.sp,
            color: AppColors.textPrimary.withOpacity(isEnable ? 1.0 : 0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    final state = ref.watch(provider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.locale.authSignUpVerificationTitle,
          style: AppTextStyles.serifSemiBold.copyWith(fontSize: 40.sp),
        ),
        SizedBox(height: 30.h),
        Text(
          context.locale.authSignUpVerificationDescription,
          style: AppTextStyles.latoRegular.copyWith(fontSize: 16.sp),
        ),
        Text(
          state.email ?? '',
          style: AppTextStyles.latoBold.copyWith(fontSize: 16.sp),
        ),
        SizedBox(height: 14.h),
        Row(
          children: [
            GestureDetector(
              onTap: _onTapEmailIsWrong,
              child: Text(
                context.locale.authSignUpVerificationEmailIsWrongButtonTitle,
                style: AppTextStyles.latoBold.copyWith(
                  fontSize: 16.sp,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            SizedBox(width: 4.w),
            Text(
              context
                  .locale.authSignUpVerificationEmailIsWrongButtonDescription,
              style: AppTextStyles.latoRegular.copyWith(fontSize: 16.sp),
            ),
          ],
        ),
        SizedBox(height: 30.h),
        Text(
          context.locale.authSignUpVerificationPinPutTitle,
          style: AppTextStyles.serifSemiBold.copyWith(fontSize: 14.sp),
        ),
        SizedBox(height: 16.h),
        _buildPinPut(state.errors?.isCodeInvalidError ?? false),
        SizedBox(height: 10.h),
        _buildResendCode(
          isEnable: state.isResendCodeEnable,
          countdownSeconds: state.resendCodeCountdownSeconds,
        ),
        const Spacer(),
        if (state.errors?.isCodeInvalidError ?? false)
          Center(
            child: Text(
              state.errors?.serverErrorText ?? '',
              style: AppTextStyles.latoBold.copyWith(
                fontSize: 16.sp,
                color: AppColors.error,
              ),
            ),
          ),
        SizedBox(height: 20.h),
        AppOutlineTransparentButton(
          title: context.locale.authSignUpVerificationSetUpButtonTitle,
          onTap: _onTapSetUp,
          isEnabled: state.isSetUpButtonEnable,
          isLoading: state.isSetUpButtonLoading,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    ref
      ..listen(provider, _errorsListener)
      ..listen(provider, _signUpFinishedListener);

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
