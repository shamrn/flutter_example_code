import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_third_step/sign_up_personal_settings_third_step_pro/models/sign_up_personal_settings_third_step_pro_ui.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_third_step/sign_up_personal_settings_third_step_pro/provider/sign_up_personal_settings_third_step_pro_provider.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_third_step/sign_up_personal_settings_third_step_pro/provider/sign_up_personal_settings_third_step_pro_state.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_third_step/sign_up_personal_settings_third_step_pro/widgets/sign_up_personal_settings_third_step_exercise_pro_item.dart';
import 'package:prime_ballet/common/extensions/localization_extension.dart';
import 'package:prime_ballet/common/providers/consumer_state_with_provider.dart';
import 'package:prime_ballet/common/routes.dart';
import 'package:prime_ballet/common/ui/app_colors.dart';
import 'package:prime_ballet/common/ui/app_text_styles.dart';
import 'package:prime_ballet/common/widgets/app_container_shimmer.dart';
import 'package:prime_ballet/common/widgets/app_outline_solid_button.dart';
import 'package:prime_ballet/common/widgets/app_top_bar.dart';
import 'package:video_player/video_player.dart';

class SignUpPersonalSettingsThirdStepProPage extends ConsumerStatefulWidget {
  const SignUpPersonalSettingsThirdStepProPage({
    bool isStagedRedirect = false,
    super.key,
  }) : _isStagedRedirect = isStagedRedirect;

  final bool _isStagedRedirect;

  @override
  ConsumerState<SignUpPersonalSettingsThirdStepProPage> createState() =>
      _SignUpPersonalSettingsThirdStepProState();
}

class _SignUpPersonalSettingsThirdStepProState
    extends ConsumerStateWithProvider<
        SignUpPersonalSettingsThirdStepProProvider,
        SignUpPersonalSettingsThirdStepProState,
        SignUpPersonalSettingsThirdStepProPage> {
  final List<VideoPlayerController> _videoPlayerControllerList = [];

  @override
  void dispose() {
    for (final videoPlayerController in _videoPlayerControllerList) {
      videoPlayerController.dispose();
    }

    super.dispose();
  }

  VideoPlayerController _getOrCreateVideoPlayerController(String videoUrl) {
    final videoPlayerController = _videoPlayerControllerList.firstWhere(
      (videoPlayerController) => videoPlayerController.dataSource == videoUrl,
      orElse: () => VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
      )..initialize(),
    );

    if (!_videoPlayerControllerList.contains(videoPlayerController)) {
      _videoPlayerControllerList.add(videoPlayerController);
    }

    return videoPlayerController;
  }

  void _errorsListener(
    SignUpPersonalSettingsThirdStepProState? previous,
    SignUpPersonalSettingsThirdStepProState next,
  ) {
    if (next.errors?.isServerUnknownError ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.locale.unknownError)),
      );
    }
  }

  void _finishListener(
    SignUpPersonalSettingsThirdStepProState? previous,
    SignUpPersonalSettingsThirdStepProState next,
  ) {
    if (next.isFinish) {
      Navigator.of(context).pushNamedAndRemoveUntil(Routes.home, (_) => false);
    }
  }

  void _onTapCheckBox(int id) {
    ref.read(provider.notifier).toggleExerciseIdSelection(id);
  }

  void _onTapContinue() {
    ref.read(provider.notifier).saveSelectedExercise();
  }

  void _onTapToggleVideo(VideoPlayerController videoPlayerController) {
    videoPlayerController.value.isPlaying
        ? videoPlayerController.pause()
        : videoPlayerController.play();

    for (final controller in _videoPlayerControllerList) {
      if (controller.value.isPlaying && videoPlayerController != controller) {
        controller.pause();
      }
    }
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
    return Column(
      children: [
        AppContainerShimmer(
          width: 160.w,
          height: 160.w,
          borderRadius: BorderRadius.circular(8.r),
        ),
        SizedBox(height: 5.h),
        AppContainerShimmer(
          width: 140.w,
          height: 15.h,
          borderRadius: BorderRadius.circular(3.r),
        ),
      ],
    );
  }

  Widget _buildItem(SignUpPersonalSettingsThirdStepProUi exerciseUi) {
    final isSelected = ref.read(provider.notifier).isExerciseSelected(
          exerciseUi.id,
        );
    final videoPlayerController = _getOrCreateVideoPlayerController(
      exerciseUi.videoUrl,
    );

    return SignUpPersonalSettingsThirdStepExerciseProItem(
      title: exerciseUi.title,
      videoPlayerController: videoPlayerController,
      imageUrl: exerciseUi.imageUrl,
      onTapCheckBox: () => _onTapCheckBox(exerciseUi.id),
      onTagTogglePlayer: _onTapToggleVideo,
      isSelected: isSelected,
    );
  }

  Widget _buildItems({
    required bool isLoading,
    required List<SignUpPersonalSettingsThirdStepProUi> exerciseList,
  }) {
    return Expanded(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Wrap(
          spacing: 13.w,
          runSpacing: 13.h,
          children: List.generate(
            isLoading ? 4 : exerciseList.length,
            (index) => AnimatedCrossFade(
              duration: const Duration(milliseconds: 250),
              crossFadeState: isLoading
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: _buildShimmerItem(),
              secondChild: isLoading
                  ? const SizedBox.shrink()
                  : _buildItem(
                      exerciseList[index],
                    ),
            ),
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
        _buildTitle(isLoading: state.isLoading, userName: state.userName),
        SizedBox(height: 8.h),
        _buildDescription(),
        SizedBox(height: 30.h),
        _buildItems(
          isLoading: state.isLoading,
          exerciseList: state.exerciseList,
        ),
        SizedBox(height: 13.h),
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
