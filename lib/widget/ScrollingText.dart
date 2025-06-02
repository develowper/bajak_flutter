import 'package:flutter/material.dart';

class ScrollingText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final double speed; // pixels per second
  final bool repeat;
  final AxisDirection direction;
  final Color? backgroundColor;
  final EdgeInsets padding;

  const ScrollingText({
    Key? key,
    required this.text,
    this.style = const TextStyle(fontSize: 18),
    this.speed = 50.0,
    this.repeat = true,
    this.direction = AxisDirection.left,
    this.backgroundColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 8.0),
  }) : super(key: key);

  @override
  State<ScrollingText> createState() => _ScrollingTextState();
}

class _ScrollingTextState extends State<ScrollingText>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _textKey = GlobalKey();
  bool _shouldScroll = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _startScrolling() async {
    if (!_shouldScroll || !mounted) return;

    while (mounted && widget.repeat) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final duration = Duration(
        milliseconds: ((maxScroll + 1) / widget.speed * 1000).round(),
      );

      try {
        await _scrollController.animateTo(
          widget.direction == AxisDirection.left ? maxScroll : 0,
          duration: duration,
          curve: Curves.linear,
        );
        await Future.delayed(const Duration(milliseconds: 2000));
        if (mounted) {
          _scrollController.jumpTo(
            widget.direction == AxisDirection.left ? 0 : maxScroll,
          );
        }
      } catch (_) {
        break;
      }
    }

    if (!widget.repeat && mounted) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final duration = Duration(
        milliseconds: ((maxScroll + 1) / widget.speed * 1000).round(),
      );
      await _scrollController.animateTo(
        widget.direction == AxisDirection.left ? maxScroll : 0,
        duration: duration,
        curve: Curves.linear,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final textContext = _textKey.currentContext;
          if (textContext != null) {
            final box = textContext.findRenderObject() as RenderBox;
            final textWidth = box.size.width;
            final availableWidth = constraints.maxWidth;
            final shouldScroll = textWidth > availableWidth;

            if (shouldScroll != _shouldScroll) {
              setState(() {
                _shouldScroll = shouldScroll;
              });

              if (shouldScroll) {
                _startScrolling();
              }
            }
          }
        });

        final textWidgetForMeasurement = Padding(
          padding: widget.padding,
          child: Text(
            widget.text,
            key: _textKey,
            style: widget.style,
            softWrap: false,
            overflow: TextOverflow.visible,
            maxLines: 1,
          ),
        );

        final textWidget = Padding(
          padding: widget.padding,
          child: Text(
            widget.text,
            style: widget.style,
            softWrap: false,
            overflow: TextOverflow.visible,
            maxLines: 1,
          ),
        );

        return Container(
          decoration: BoxDecoration(color: widget.backgroundColor),
          // height: widget.style.fontSize! * 1.5, // optional height control
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            child: Row(
              children: [
                textWidgetForMeasurement,
                if (_shouldScroll) const SizedBox(width: 40),
                // if (_shouldScroll && widget.repeat) textWidget,
              ],
            ),
          ),
        );
      },
    );
  }
}
