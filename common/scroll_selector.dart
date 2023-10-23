import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:prime_ballet/common/ui/app_colors.dart';
import 'package:prime_ballet/common/ui/app_text_styles.dart';

class ScrollSelector<T> extends StatefulWidget {
  const ScrollSelector({
    required String title,
    required List<T> values,
    required Future<void> Function(T value) onValue,
    super.key,
  })  : _title = title,
        _values = values,
        _onValue = onValue;

  @override
  State<ScrollSelector<T>> createState() => _ScrollSelectorState<T>();

  final String _title;
  final List<T> _values;
  final Future<void> Function(T value) _onValue;
}

class _ScrollSelectorState<T> extends State<ScrollSelector<T>> {
  static const _additionalLength = 1;
  static const _numberMainLine = 1;
  static const _numberDividerLine = 4;
  final _lineWidth = 18.w;
  final _scrollCompensation = 12.w;

  late final ScrollController _scrollController;
  late double _selectedIndexValue;

  double opacity = 1.0;

  double get _itemWidth => _lineWidth * (_numberMainLine + _numberDividerLine);

  @override
  void initState() {
    super.initState();

    final startOffset = _itemWidth * widget._values.length / 2;

    _scrollController =
        ScrollController(initialScrollOffset: startOffset + _scrollCompensation)
          ..addListener(_scrollListener);

    _selectedIndexValue = (startOffset ~/ _itemWidth).toDouble();
  }

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  void _scrollListener() {
    final offset = _scrollController.offset;

    setState(() {
      if (!offset.isNegative && offset < _itemWidth * widget._values.length) {
        final oldValue = _selectedIndexValue;

        _selectedIndexValue =
            ((offset - _scrollCompensation) ~/ _itemWidth).toDouble();

        if (oldValue != _selectedIndexValue) {
          HapticFeedback.lightImpact();
        }
      }
    });
  }

  Shader _buildSharedCallback({
    required Rect rect,
    required Alignment begin,
    required Alignment end,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: <Color>[
        Colors.black.withOpacity(1.0),
        Colors.black.withOpacity(1.0),
        Colors.black.withOpacity(1.0),
        Colors.black.withOpacity(1.0),
        Colors.black.withOpacity(0.1),
      ],
    ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.width));
  }

  Widget _buildValue({
    required T value,
    required bool isSelected,
    required double opacity,
  }) {
    return Text(
      value.toString(),
      style: AppTextStyles.serifSemiBold.copyWith(
        fontSize: isSelected ? 20.sp : 16.sp,
        color: AppColors.textPrimary.withOpacity(opacity),
      ),
    );
  }

  Widget _buildLine({required double opacity, required double height}) {
    return SizedBox(
      height: height,
      child: VerticalDivider(
        thickness: 1.67.w,
        width: _lineWidth,
        color: AppColors.primary.withOpacity(opacity),
      ),
    );
  }

  List<Widget> _buildLines({
    required int number,
    required double opacity,
    required double height,
  }) {
    return [
      for (var i = 0; i < number; i++)
        _buildLine(opacity: opacity, height: height),
    ];
  }

  Widget _buildItem(int index) {
    final value = widget._values[index];

    final isSelected = index.toDouble() == _selectedIndexValue;

    if (isSelected) Future(() => widget._onValue(value));

    final lines = <Widget>[
      ..._buildLines(
        number: _numberDividerLine ~/ 2,
        opacity: 0.4,
        height: 24.h,
      ),
      _buildLine(opacity: isSelected ? 1.0 : 0.4, height: 40.h),
      ..._buildLines(
        number: _numberDividerLine ~/ 2,
        opacity: 0.4,
        height: 24.h,
      ),
    ];

    return SizedBox(
      width: _itemWidth,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildValue(
            value: value,
            isSelected: isSelected,
            opacity: isSelected ? 1.0 : 0.4,
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: lines,
          ),
        ],
      ),
    );
  }

  Widget _buildBody(int index) {
    if (index < _additionalLength || index > widget._values.length) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: _buildLines(
          number: MediaQuery.of(context).size.width / 2 ~/ _lineWidth,
          opacity: 0.3,
          height: 24.h,
        ),
      );
    } else {
      return _buildItem(index - _additionalLength);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120.h,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: 2,
            child: Text(
              widget._title,
              style: AppTextStyles.serifSemiBold.copyWith(
                fontSize: 14.sp,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: ShaderMask(
              shaderCallback: (rect) => _buildSharedCallback(
                rect: rect,
                begin: Alignment.topLeft,
                end: Alignment.topRight,
              ),
              blendMode: BlendMode.dstIn,
              child: ShaderMask(
                shaderCallback: (rect) => _buildSharedCallback(
                  rect: rect,
                  begin: Alignment.topRight,
                  end: Alignment.topLeft,
                ),
                blendMode: BlendMode.dstIn,
                child: ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (_, index) => _buildBody(index),
                  itemCount: widget._values.length + _additionalLength * 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
