import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:prime_ballet/common/ui/app_colors.dart';
import 'package:prime_ballet/common/ui/app_text_styles.dart';
import 'package:prime_ballet/common/ui/app_transparent_image.dart';
import 'package:video_player/video_player.dart';

class SignUpPersonalSettingsThirdStepExerciseProItem extends StatefulWidget {
  const SignUpPersonalSettingsThirdStepExerciseProItem({
    required String title,
    required VideoPlayerController videoPlayerController,
    required String imageUrl,
    required VoidCallback onTapCheckBox,
    required void Function(VideoPlayerController videoPlayerController)
        onTagTogglePlayer,
    bool isSelected = false,
    super.key,
  })  : _title = title,
        _videoPlayerController = videoPlayerController,
        _imageUrl = imageUrl,
        _onTapCheckBox = onTapCheckBox,
        _onTapTogglePlayer = onTagTogglePlayer,
        _isSelected = isSelected;

  final String _title;
  final VideoPlayerController _videoPlayerController;
  final String _imageUrl;
  final VoidCallback _onTapCheckBox;
  final void Function(VideoPlayerController videoPlayerController)
      _onTapTogglePlayer;
  final bool _isSelected;

  @override
  State<SignUpPersonalSettingsThirdStepExerciseProItem> createState() =>
      _SignUpPersonalSettingsThirdStepExerciseProItemState();
}

class _SignUpPersonalSettingsThirdStepExerciseProItemState
    extends State<SignUpPersonalSettingsThirdStepExerciseProItem> {
  bool _isVideoPlayerPlaying = false;
  bool _hasBeenVideoPlayerPlayed = false;

  void _videoPlayerControllerListener() {
    if (widget._videoPlayerController.value.isPlaying !=
        _isVideoPlayerPlaying) {
      _isVideoPlayerPlaying = widget._videoPlayerController.value.isPlaying;

      if (!_hasBeenVideoPlayerPlayed) _hasBeenVideoPlayerPlayed = true;

      setState(() {});
    }
  }

  Widget _buildCheckBox() {
    return Align(
      alignment: Alignment.topRight,
      child: InkWell(
        onTap: widget._onTapCheckBox,
        child: SizedBox(
          width: 40.w,
          height: 40.w,
          child: Center(
            child: Container(
              width: 18.w,
              height: 18.w,
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border.all(color: AppColors.primary, width: 1.5.w),
                borderRadius: BorderRadius.circular(1.r),
              ),
              child: AnimatedOpacity(
                opacity: widget._isSelected ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 150),
                child: Icon(
                  Icons.check,
                  color: AppColors.primary,
                  size: 14.w,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayer() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: AnimatedCrossFade(
        duration: const Duration(milliseconds: 600),
        crossFadeState: _hasBeenVideoPlayerPlayed
            ? CrossFadeState.showFirst
            : CrossFadeState.showSecond,
        firstChild: SizedBox(
          width: 160.w,
          height: 160.w,
          child: VideoPlayer(widget._videoPlayerController),
        ),
        secondChild: FadeInImage.memoryNetwork(
          placeholder: appTransparentImage,
          image: widget._imageUrl,
          width: 160.w,
          height: 160.w,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildPlayerToggle() {
    final isPlaying = widget._videoPlayerController.value.isPlaying;

    return Center(
      child: AnimatedOpacity(
        opacity: isPlaying ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Icon(
          Icons.play_arrow,
          key: ValueKey(isPlaying),
          size: 40.w,
          color: isPlaying
              ? AppColors.background.withOpacity(0.5)
              : AppColors.background,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    widget._videoPlayerController.addListener(_videoPlayerControllerListener);

    return Column(
      children: [
        GestureDetector(
          onTap: () => widget._onTapTogglePlayer(
            widget._videoPlayerController,
          ),
          child: SizedBox(
            width: 160.w,
            height: 160.w,
            child: Stack(
              children: [
                _buildPlayer(),
                _buildCheckBox(),
                _buildPlayerToggle(),
              ],
            ),
          ),
        ),
        SizedBox(height: 5.h),
        Text(
          widget._title,
          style: AppTextStyles.latoRegular.copyWith(fontSize: 14.sp),
        ),
      ],
    );
  }
}
