import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../helper/styles.dart';

class Loader extends StatefulWidget {
  final bool repeat;
  late Color color;
  late double size;
  late Indicator indicator;
  late final Style style;

  Loader(
      {Key? key,
      Color? color,
      double? size,
      Indicator? indicator,
      this.repeat = false}) {
    style = Get.find<Style>();

    this.color = color ?? style.primaryColor;
    this.size = size ?? 32;
    this.indicator = indicator ?? Indicator.ballPulse;
  }

  @override
  _LoaderState createState() => _LoaderState();
}

class _LoaderState extends State<Loader> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation_rotation;
  late Animation<double> animation_radius_in;
  late Animation<double> animation_radius_out;

  final double initialRadius = 1;
  double radius = 0.0;

  @override
  void dispose() {
    // TODO: implement dispose
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 3500));

    animation_rotation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
        parent: controller, curve: Interval(0.0, 1.0, curve: Curves.ease)));

    animation_radius_in = Tween<double>(
      begin: 1.1,
      end: 0.9,
    ).animate(CurvedAnimation(
        parent: controller,
        curve: Interval(0.5, 1.0, curve: Curves.elasticIn)));

    animation_radius_out = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(
        parent: controller,
        curve: Interval(0.0, 0.5, curve: Curves.elasticOut)));

    controller.addListener(() {
      setState(() {
        if (controller.value >= 0.75 && controller.value <= 1.0) {
          radius = animation_radius_in.value * initialRadius;
        } else if (controller.value >= 0.0 && controller.value <= 0.25) {
          radius = animation_radius_out.value * initialRadius;
        }
      });
    });
    controller.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: widget.size,
        child: LoadingIndicator(
          indicatorType: widget.indicator,

          /// Required, The loading type of the widget
          colors: [widget.color],

          /// Optional, The color collections
          strokeWidth: 2,

          /// Optional, The stroke of the line, only applicable to widget which contains line
          // backgroundColor: Colors.black,

          /// Optional, Background of the widget
          // pathBackgroundColor: Colors.black

          /// Optional, the stroke backgroundColor
        ),
      ),
    );
  }
}

class Dot extends StatelessWidget {
  final Color? color;
  final double? radius;

  Dot({this.color, this.radius});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: this.radius,
        height: this.radius,
        decoration: BoxDecoration(
          color: this.color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
