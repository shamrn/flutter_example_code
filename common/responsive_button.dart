import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ResponsiveButton extends StatefulWidget {
  const ResponsiveButton({
    required Widget child,
    VoidCallback? onTap,
    super.key,
  })  : _onTap = onTap,
        _child = child;

  final Widget _child;
  final VoidCallback? _onTap;

  @override
  State<ResponsiveButton> createState() => _ResponsiveButtonState();
}

class _ResponsiveButtonState extends State<ResponsiveButton> {
  bool isTapped = false;

  void _onHighlightChanged(bool value) {
    setState(() {
      HapticFeedback.lightImpact();
      isTapped = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: widget._onTap,
      onHighlightChanged: widget._onTap != null ? _onHighlightChanged : null,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 250),
        scale: isTapped ? 0.98 : 1,
        child: widget._child,
      ),
    );
  }
}
