import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:prime_ballet/common/ui/app_assets.dart';
import 'package:prime_ballet/common/ui/app_colors.dart';
import 'package:prime_ballet/common/ui/app_text_styles.dart';

class AppPasswordTextField extends StatefulWidget {
  const AppPasswordTextField({
    required String label,
    TextEditingController? controller,
    bool isError = false,
    super.key,
  })  : _label = label,
        _controller = controller,
        _isError = isError;

  final String _label;
  final TextEditingController? _controller;
  final bool _isError;

  @override
  State<AppPasswordTextField> createState() => _AppPasswordTextFieldState();
}

class _AppPasswordTextFieldState extends State<AppPasswordTextField> {
  bool _isObscureText = true;

  void _onTapEyeIcon() {
    setState(() => _isObscureText = !_isObscureText);
  }

  Widget _buildIconButton() {
    return InkWell(
      onTap: _onTapEyeIcon,
      child: GestureDetector(
        child: SvgPicture.asset(
          _isObscureText ? AppAssets.eyeIcon : AppAssets.crossedOutEyeIcon,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: AppTextStyles.serifSemiBold.copyWith(fontSize: 14.sp),
      cursorColor: AppColors.primary,
      controller: widget._controller,
      obscureText: _isObscureText,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.zero,
        isDense: true,
        suffixIconConstraints: BoxConstraints(maxWidth: 26.w),
        suffixIcon: _buildIconButton(),
        label: Text(
          widget._label,
          style: AppTextStyles.serifSemiBold.copyWith(
            color: widget._isError
                ? AppColors.error
                : AppColors.primary.withOpacity(0.5),
            fontSize: 14.sp,
          ),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.primary.withOpacity(0.5),
          ),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}
