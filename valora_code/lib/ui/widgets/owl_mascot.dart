import 'package:flutter/material.dart';

import '../painters/owl_painter.dart';

export '../painters/owl_painter.dart' show OwlScenario;

/// Mascota búho animada de ValoraCode.
///
/// Usa [OwlPainter] internamente con un loop de flotación suave.
/// Se puede posicionar en cualquier pantalla simplemente instanciándola.
class OwlMascot extends StatefulWidget {
  final OwlScenario scenario;

  /// Tamaño del canvas cuadrado (ancho = alto).
  final double size;

  /// Texto opcional debajo del búho.
  final String? label;

  const OwlMascot({
    super.key,
    this.scenario = OwlScenario.greeting,
    this.size = 160,
    this.label,
  });

  @override
  State<OwlMascot> createState() => _OwlMascotState();
}

class _OwlMascotState extends State<OwlMascot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomPaint(
            size: Size(widget.size, widget.size),
            painter: OwlPainter(
              scenario: widget.scenario,
              animValue: _ctrl.value,
            ),
          ),
          if (widget.label != null) ...[
            const SizedBox(height: 12),
            Text(
              widget.label!,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 13,
                fontWeight: FontWeight.w400,
                height: 1.45,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
