import 'package:flutter/material.dart';

class RowOverlap extends StatelessWidget {
  final List<Widget> children;
  final double maxSpacing;
  final double overlapFactor;

  const RowOverlap({
    Key? key,
    required this.children,
    this.maxSpacing = 50,
    this.overlapFactor = 0.5, // Increased overlap factor
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double screenWidth = constraints.maxWidth;
        int itemCount = children.length;
        double spacing = maxSpacing;
        double totalWidth = (itemCount - 1) * spacing;
        double leftPadding =
            ((screenWidth - (totalWidth == 0 ? spacing : totalWidth)) / 2)-(itemCount==0? (spacing/4):0);
        // Adjust spacing if it overflows
        // print("$totalWidth > $screenWidth");
        if (totalWidth > screenWidth) {
          spacing = screenWidth / (itemCount - 1);
        }
        leftPadding = leftPadding < 0 ? 0 : leftPadding;

        return Stack(
          children: List.generate(itemCount, (index) {
            return Positioned(
              left: (spacing * index * overlapFactor) + leftPadding,
              child: children[index],
            );
          }),
        );
      },
    );
  }
}
