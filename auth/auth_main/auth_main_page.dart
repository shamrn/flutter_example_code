import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:prime_ballet/auth/common/widgets/log_in_or_skip.dart';
import 'package:prime_ballet/common/extensions/localization_extension.dart';
import 'package:prime_ballet/common/routes.dart';
import 'package:prime_ballet/common/ui/app_assets.dart';
import 'package:prime_ballet/common/ui/app_text_styles.dart';
import 'package:prime_ballet/common/widgets/app_outline_transparent_button.dart';

class AuthMainPage extends StatelessWidget {
  const AuthMainPage({super.key});

  void _onTapSignUp(BuildContext context) {
    Navigator.of(context).pushNamed(Routes.authSignUp);
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 32.h,
        right: 20.w,
        bottom: 18.h,
        left: 20.w,
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              context.locale.authMainTitle,
              style: AppTextStyles.serifSemiBold.copyWith(fontSize: 40.sp),
            ),
          ),
          const Spacer(),
          AppOutlineTransparentButton(
            title: context.locale.authMainButtonTitle,
            onTap: () => _onTapSignUp(context),
          ),
          SizedBox(height: 20.h),
          const LogInOrSkip(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(AppAssets.authBackgroundImage, fit: BoxFit.cover),
          SafeArea(child: _buildBody(context)),
        ],
      ),
    );
  }
}
