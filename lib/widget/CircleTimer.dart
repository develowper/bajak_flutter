import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:games/helper/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CircleTimer extends StatelessWidget {
  CountDownController controller;
  double height;
  Style style = Get.find<Style>();
  int duration;
  int initialDuration;
  Function? onComplete;

  Color? fillColor;

  Color? ringColor;
  TextStyle? textStyle;
  double? strokeWidth;

  CircleTimer(
      {super.key,
      required this.controller,
      required this.height,
      required this.duration,
      this.onComplete,
      this.fillColor,
      this.ringColor,
      this.textStyle,
      this.strokeWidth,
      required this.initialDuration});

  @override
  Widget build(
    BuildContext context,
  ) {
    return CircularCountDownTimer(
      duration: duration,
      initialDuration: 0,
      controller: controller,
      width: height,
      height: height,
      ringColor: ringColor ?? style.primaryColor.withOpacity(.3),
      ringGradient: null,
      fillColor: fillColor ?? style.primaryColor,
      fillGradient: null,
      backgroundColor: Colors.transparent,
      backgroundGradient: null,
      strokeWidth:strokeWidth?? style.cardMargin,
      strokeCap: StrokeCap.round,
      textStyle:textStyle?? style.textMediumStyle.copyWith(fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
      textFormat: CountdownTextFormat.S,
      isReverse: true,
      isReverseAnimation: false,
      isTimerTextShown: true,
      autoStart: false,

      onStart: () {
        // debugPrint('Countdown Started');
      },
      onComplete: () {
        debugPrint('Countdown Ended');
        if (onComplete != null) onComplete!();
      },
      onChange: (String timeStamp) {
        // debugPrint('Countdown Changed $timeStamp');
      },

      timeFormatterFunction: (defaultFormatterFunction, duration) {
        // if (duration.inSeconds == 0) {
        //   return "Start";
        // } else {
        return Function.apply(defaultFormatterFunction, [duration]);
        // }
      },
    );
  }
}
