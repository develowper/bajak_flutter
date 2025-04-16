import 'package:flutter/material.dart';

class FadeInOut extends StatefulWidget {
  final Widget child;   // The widget to animate
  final Duration duration;  // Duration of the fade-in and fade-out effect
  final bool repeat;  // Whether the animation should repeat or play once

  // Constructor
  const FadeInOut({
    Key? key,
    required this.child,
    this.duration = const Duration(seconds: 2),
    this.repeat = true,  // Default to true, so animation will repeat
  }) : super(key: key);

  @override
  _FadeInOutState createState() => _FadeInOutState();
}

class _FadeInOutState extends State<FadeInOut> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // Set up the animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
      lowerBound: 0.0,
      upperBound: 1.0,
    );

    // If repeat is true, make the animation repeat
    if (widget.repeat) {
      _animationController.repeat(reverse: true);  // Repeat with reverse effect (fade in and out)
    } else {
      _animationController.forward();  // Play once (fade in)
    }

    // Define the fade-in and fade-out animation
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();  // Don't forget to dispose the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: widget.child,  // The widget passed as child argument
    );
  }
}
