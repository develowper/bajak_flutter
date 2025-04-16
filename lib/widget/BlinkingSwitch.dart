import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BlinkingSwitch extends StatefulWidget {
  final Widget firstChild;
  final Widget secondChild;
  final Duration blinkDuration;
  final int blinkCount;
  final Duration fadeDuration;
  final Rx changeKey;

  BlinkingSwitch({
    required this.firstChild,
    required this.secondChild,
    this.blinkDuration = const Duration(milliseconds: 100),
    this.blinkCount = 5,
    this.fadeDuration = const Duration(milliseconds: 200),
    Key? key,
    required this.changeKey,
  }) : super(key: key);

  @override
  State<BlinkingSwitch> createState() => _BlinkingSwitchState();
}

class _BlinkingSwitchState extends State<BlinkingSwitch> {
  @override
  void initState() {
    before = widget.changeKey.value;
    widget.changeKey.listen((value) {
      toggleVisibility();
    });
    super.initState();
  }

  @override
  void dispose() {
    if (_transitionTimer?.isActive ?? false) {
      _transitionTimer?.cancel();
    }
    super.dispose();
  }

  var showFirst = true.obs;

  var isBlinking = false.obs;

  Timer? _transitionTimer;

  var before;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AnimatedOpacity(
        opacity: isBlinking.value ? 0 : 1.0,
        duration: widget.fadeDuration,
        child: () {
          return showFirst.value ? widget.firstChild : widget.secondChild;
        }(),
      ),
    );
  }

  void toggleVisibility() async {
    if (isBlinking.value) return; // Prevent multiple toggles while blinking

    isBlinking.value = true;

    for (int i = 0; i < widget.blinkCount; i++) {
      await Future.delayed(widget.blinkDuration ~/ 2);
      isBlinking.toggle();
      await Future.delayed(widget.blinkDuration ~/ 2);
      isBlinking.toggle();
    }

    _transitionTimer = Timer(widget.fadeDuration, () {
      showFirst.toggle();
      isBlinking.value = false;
    });
  }
}
