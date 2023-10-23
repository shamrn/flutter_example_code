import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:prime_ballet/common/extensions/localization_extension.dart';
import 'package:prime_ballet/common/routes.dart';
import 'package:prime_ballet/common/ui/app_text_styles.dart';

class LogInOrSkip extends StatelessWidget {
  const LogInOrSkip({super.key});

  void _onTapLogIn(BuildContext context) {
    Navigator.of(context).pushNamed(Routes.authSignIn);
  }

  void _onTapSkip(BuildContext context) {
    Navigator.of(context).pushNamed(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          context.locale.authLogInOrSkipFirstText,
          style: AppTextStyles.latoRegular.copyWith(fontSize: 13.sp),
        ),
        SizedBox(width: 4.w),
        GestureDetector(
          onTap: () => _onTapLogIn(context),
          child: Text(
            context.locale.authLogInOrSkipSecondText,
            style: AppTextStyles.latoBold.copyWith(
              fontSize: 13.sp,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        SizedBox(width: 3.w),
        Text(
          context.locale.authLogInOrSkipThirdText,
          style: AppTextStyles.latoRegular.copyWith(fontSize: 13.sp),
        ),
        SizedBox(width: 3.w),
        GestureDetector(
          onTap: () => _onTapSkip(context),
          child: Text(
            context.locale.authLogInOrSkipFourthText,
            style: AppTextStyles.latoBold.copyWith(
              fontSize: 13.sp,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
