import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../helper/styles.dart';

class AnimatedButton extends StatefulWidget {
  final Widget child;
  final Function? onTap;
  final ButtonStyle? buttonStyle;
  Style style = Get.find<Style>();

  AnimatedButton(
      {super.key, required this.child, this.onTap, this.buttonStyle});

  @override
  _AnimatedButtonState createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late double _scale;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      lowerBound: 0.0,
      upperBound: 0.1,
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    _scale = 1 - _controller.value;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      child: Transform.scale(
        scale: _scale,
        child: TextButton(
            style: widget.buttonStyle,
            onPressed: () => {if (widget.onTap != null) widget.onTap!()},
            child: widget.child),
      ),
    );
  }
}
