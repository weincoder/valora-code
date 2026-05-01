import 'package:flutter/material.dart';
import '../painters/retro_grid_painter.dart';

class RetroBackground extends StatelessWidget {
  final Widget child;

  const RetroBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: CustomPaint(painter: const RetroGridPainter())),
        child,
      ],
    );
  }
}
