import 'package:flutter/material.dart';

/// 2×2 grid of dots (reference “Hashtag” tab style).
class HashtagGridNavIcon extends StatelessWidget {
  final Color color;
  final double size;

  const HashtagGridNavIcon({
    super.key,
    required this.color,
    this.size = 22,
  });

  @override
  Widget build(BuildContext context) {
    final dotSize = size * 0.24;
    final gap = size * 0.16;
    final dot = Container(
      width: dotSize,
      height: dotSize,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
    return SizedBox(
      width: size,
      height: size,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              dot,
              SizedBox(width: gap),
              dot,
            ],
          ),
          SizedBox(height: gap),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              dot,
              SizedBox(width: gap),
              dot,
            ],
          ),
        ],
      ),
    );
  }
}
