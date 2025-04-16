import 'package:flutter/material.dart';
import 'dart:async';

class NumberController extends ChangeNotifier {
  String _current = '';

  String get current => _current;

  void change(String value) {
    _current = value;
    notifyListeners();
  }
}

class MyCallNumber extends StatefulWidget {
  final NumberController numberController;
  final TextStyle? textStyle;

  const MyCallNumber({
    super.key,
    required this.numberController,
    this.textStyle,
  });

  @override
  State<MyCallNumber> createState() => _MyCallNumberState();
}

class _MyCallNumberState extends State<MyCallNumber>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  String _displayedNumber = '';

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.3)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.3, end: 0.9)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.9, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 40,
      ),
    ]).animate(_controller);

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    widget.numberController.addListener(_onNumberChanged);
  }

  void _onNumberChanged() {
    setState(() {
      _displayedNumber = widget.numberController.current;
    });
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    widget.numberController.removeListener(_onNumberChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = widget.textStyle ??
        const TextStyle(fontSize: 48, fontWeight: FontWeight.bold);

    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Opacity(
          opacity: _fadeAnim.value,
          child: Transform.scale(
            scale: _scaleAnim.value,
            child: Text(
              _displayedNumber,
              style: textStyle,
            ),
          ),
        );
      },
    );
  }
}
