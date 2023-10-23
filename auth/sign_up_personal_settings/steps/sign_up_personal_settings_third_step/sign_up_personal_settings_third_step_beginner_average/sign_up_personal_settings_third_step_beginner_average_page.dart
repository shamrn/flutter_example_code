import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_third_step/sign_up_personal_settings_third_step_beginner_average/models/sign_up_personal_settings_third_step_beginner_average_ui.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_third_step/sign_up_personal_settings_third_step_beginner_average/provider/sign_up_personal_settings_third_step_beginner_average_provider.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_third_step/sign_up_personal_settings_third_step_beginner_average/provider/sign_up_personal_settings_third_step_beginner_average_state.dart';
import 'package:prime_ballet/common/extensions/localization_extension.dart';
import 'package:prime_ballet/common/providers/consumer_state_with_provider.dart';
import 'package:prime_ballet/common/routes.dart';
import 'package:prime_ballet/common/ui/app_colors.dart';
import 'package:prime_ballet/common/ui/app_text_styles.dart';
import 'package:prime_ballet/common/widgets/app_container_shimmer.dart';
import 'package:prime_ballet/common/widgets/app_outline_solid_button.dart';
import 'package:prime_ballet/common/widgets/app_top_bar.dart';

class SignUpPersonalSettingsThirdStepBeginnerAveragePage
    extends ConsumerStatefulWidget {
  const SignUpPersonalSettingsThirdStepBeginnerAveragePage({
    bool isStagedRedirect = false,
    super.key,
  }) : _isStagedRedirect = isStagedRedirect;

  final bool _isStagedRedirect;

  @override
  ConsumerState<SignUpPersonalSettingsThirdStepBeginnerAveragePage>
      createState() => _SignUpPersonalSettingsThirdStepMiddleLevelState();
}

class _SignUpPersonalSettingsThirdStepMiddleLevelState
    extends ConsumerStateWithProvider<
        SignUpPersonalSettingsThirdStepBeginnerAverageProvider,
        SignUpPersonalSettingsThirdStepBeginnerAverageState,
        SignUpPersonalSettingsThirdStepBeginnerAveragePage> {
  void _errorsListener(
    SignUpPersonalSettingsThirdStepBeginnerAverageState? previous,
    SignUpPersonalSettingsThirdStepBeginnerAverageState next,
  ) {
    if (next.errors?.isServerUnknownError ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.locale.unknownError)),
      );
    }
  }

  void _finishListener(
    SignUpPersonalSettingsThirdStepBeginnerAverageState? previous,
    SignUpPersonalSettingsThirdStepBeginnerAverageState next,
  ) {
    if (next.isFinish) {
      Navigator.of(context).pushNamedAndRemoveUntil(Routes.home, (_) => false);
    }
  }

  void _onTapItem(int id) {
    ref.read(provider.notifier).toggleExerciseIdSelection(id);
  }

  void _onTapContinue() {
    ref.read(provider.notifier).saveSelectedExercise();
  }

  Widget _buildTitle({required bool isLoading, required String? userName}) {
    return Row(
      children: [
        Text(
          context.locale.authSignUpPersonalSettingsThirdStepTitle,
          style: AppTextStyles.serifSemiBold.copyWith(
            fontSize: 24.sp,
          ),
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 250),
          alignment: Alignment.centerLeft,
          crossFadeState:
              isLoading ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          firstChild: AppContainerShimmer(
            width: 80.w,
            height: 18.h,
            borderRadius: BorderRadius.circular(3.r),
          ),
          secondChild: Text(
            userName ?? '',
            style: AppTextStyles.serifSemiBold.copyWith(
              fontSize: 24.sp,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Text(
      context.locale.authSignUpPersonalSettingsThirdStepDescription,
      style: AppTextStyles.latoRegular.copyWith(
        fontSize: 16.sp,
      ),
    );
  }

  Widget _buildShimmerItem() {
    return AppContainerShimmer(
      width: double.infinity,
      height: 56.h,
      borderRadius: BorderRadius.circular(32.r),
    );
  }

  Widget _buildItem(
    SignUpPersonalSettingsThirdStepBeginnerAverageUi exercise,
  ) {
    final isSelectedItem = ref.read(provider.notifier).isExerciseSelected(
          exercise.id,
        );

    return GestureDetector(
      onTap: () => _onTapItem(exercise.id),
      child: AnimatedContainer(
        height: 56.h,
        duration: const Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn,
        decoration: BoxDecoration(
          color: isSelectedItem ? AppColors.primary.withOpacity(0.5) : null,
          borderRadius: BorderRadius.circular(32.r),
          border: Border.all(
            color: isSelectedItem
                ? AppColors.transparent
                : AppColors.primary.withOpacity(0.5),
          ),
        ),
        child: Center(
          child: Text(
            exercise.title,
            style: AppTextStyles.serifSemiBold.copyWith(
              fontSize: 16.sp,
              color: isSelectedItem
                  ? AppColors.white
                  : AppColors.textPrimary.withOpacity(0.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItems({
    required bool isLoading,
    required List<SignUpPersonalSettingsThirdStepBeginnerAverageUi>
        exerciseList,
  }) {
    return Expanded(
      child: ListView.separated(
        itemBuilder: (_, index) => AnimatedCrossFade(
          duration: const Duration(milliseconds: 250),
          crossFadeState:
              isLoading ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          firstChild: _buildShimmerItem(),
          secondChild: isLoading
              ? const SizedBox.shrink()
              : _buildItem(exerciseList[index]),
        ),
        separatorBuilder: (_, __) => SizedBox(height: 10.h),
        itemCount: isLoading ? 10 : exerciseList.length,
      ),
    );
  }

  Widget _buildBody() {
    final state = ref.watch(provider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle(isLoading: state.isLoading, userName: state.userName),
        SizedBox(height: 8.h),
        _buildDescription(),
        SizedBox(height: 30.h),
        _buildItems(
          isLoading: state.isLoading,
          exerciseList: state.exerciseList,
        ),
        SizedBox(height: 20.h),
        AppOutlineSolidButton(
          title: context
              .locale.authSignUpPersonalSettingsThirdStepContinueButtonTitle,
          titleColor: AppColors.white,
          backgroundColor: AppColors.accent,
          onTap: _onTapContinue,
          isEnabled: state.isContinueButtonEnable,
          isLoading: state.isContinueButtonLoading,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    ref
      ..listen(provider, _errorsListener)
      ..listen(provider, _finishListener);

    return Scaffold(
      appBar: widget._isStagedRedirect ? const AppTopBar() : null,
      body: SafeArea(
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
    );
  }
}
