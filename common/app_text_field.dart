import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:prime_ballet/common/ui/app_colors.dart';
import 'package:prime_ballet/common/ui/app_text_styles.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    required String label,
    TextEditingController? controller,
    TextInputType? keyboardType,
    List<TextInputFormatter>? textInputFormatters,
    bool isError = false,
    super.key,
  })  : _controller = controller,
        _label = label,
        _keyboardType = keyboardType,
        _textInputFormatters = textInputFormatters,
        _isError = isError;

  final String _label;
  final TextEditingController? _controller;
  final TextInputType? _keyboardType;
  final List<TextInputFormatter>? _textInputFormatters;
  final bool _isError;

  @override
  Widget build(BuildContext context) {
    return TextField(
      inputFormatters: _textInputFormatters,
      style: AppTextStyles.serifSemiBold.copyWith(fontSize: 14.sp),
      cursorColor: AppColors.primary,
      controller: _controller,
      keyboardType: _keyboardType,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.zero,
        isDense: true,
        label: Text(
          _label,
          style: AppTextStyles.serifSemiBold.copyWith(
            color:
                _isError ? AppColors.error : AppColors.primary.withOpacity(0.5),
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
