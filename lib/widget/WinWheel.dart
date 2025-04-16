import 'package:flutter/material.dart';
import 'dart:math';

import 'package:get/get.dart';

import '../helper/styles.dart';

class WinwheelController {
  late _WinWheelState _state;

  void _attach(_WinWheelState state) {
    _state = state;
  }

  void spinToSelectedIndex(int index) {
    _state.spinToSelectedIndex(index);
  }
}

Style style = Get.find<Style>();

class WinWheel extends StatefulWidget {
  final List labels;
  final WinwheelController controller;
  final Function? onCompleted;

  WinWheel({required this.labels, required this.controller, this.onCompleted});

  @override
  _WinWheelState createState() => _WinWheelState();
}

class _WinWheelState extends State<WinWheel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Animation<double>? _animation;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    widget.controller._attach(this);
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );
    if (widget.onCompleted != null) {
      _controller.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onCompleted!();
        }
      });
    }
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void spinToSelectedIndex(int index) {
    selectedIndex = index;
    final random = Random();
    final randomRotations = random.nextInt(3) + 3;
    // Randomly spins 3 to 5 times
    final segmentAngle = 2 * pi / widget.labels.length;
    final targetAngle = segmentAngle * selectedIndex;
    final randomAngleOffset = (random.nextDouble()) * (segmentAngle);
    // Dynamic random offset based on segment length
    final finalAngle =
        randomRotations * 2 * pi + targetAngle + randomAngleOffset;
    _animation =
        Tween<double>(begin: 0, end: finalAngle).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.reset();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: 300,
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(style.cardMargin),
            child: Transform.rotate(
              angle: _animation != null ? -_animation!.value : 0,
              child: CustomPaint(
                  painter: WinwheelPainter(labels: widget.labels),
                  size: Size.infinite),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/winwheel.png"),
                repeat: ImageRepeat.noRepeat,
                fit: BoxFit.fill,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class WinwheelPainter extends CustomPainter {
  final List labels;

  Random random = Random();

  WinwheelPainter({required this.labels});

  @override
  void paint(Canvas canvas, Size size) {
    double radius = min(size.width / 2, size.height / 2);
    Offset center = Offset(size.width / 2, size.height / 2);
    double sweepAngle = 2 * pi / labels.length;

    Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 0;

    Paint strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white
      ..strokeWidth = 1;

    for (int i = 0; i < labels.length; i++) {
      paint.color = _getColorForItem(i);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2 + i * sweepAngle,
        sweepAngle,
        true,
        paint,
      );
// Draw stroke
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2 + i * sweepAngle,
        sweepAngle,
        true,
        strokePaint,
      );
      _drawText(canvas, size, center, radius, sweepAngle, i, labels[i]);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  void _drawText(Canvas canvas, Size size, Offset center, double radius,
      double sweepAngle, int index, item) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: item['name'].toString(),
        style: style.textMediumLightStyle.copyWith(fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    final angle = -pi / 2 + (index * sweepAngle) + (sweepAngle / 2);
    final offset = Offset(
      center.dx + (radius / 1.5) * cos(angle),
      center.dy + (radius / 1.5) * sin(angle),
    );
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.rotate(angle);
    canvas.translate(-textPainter.width / 2, -textPainter.height / 2);
    textPainter.paint(canvas, Offset.zero);
    canvas.restore();
  }

  Color _getColorForItem(int index) {
    final colors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
    ];
    return colors[index % (colors.length)];
    return colors[random.nextInt(colors.length)];
  }
}
