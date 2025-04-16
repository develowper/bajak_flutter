import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../helper/styles.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final borderRadius;
  final Color? color;
  final EdgeInsets? margin;
  final EdgeInsets? padding;

  const GlassContainer(
      {super.key,
      required this.child,
      this.borderRadius,
      this.color,
      this.margin,this.padding,});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? Colors.white.withAlpha(50),
        borderRadius: borderRadius ?? BorderRadius.circular(0),
        // Rounded corners
        border: Border.all(color: Colors.white, width: 1), // White border
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
          child: child,
        ),
      ),
    );
  }
}
