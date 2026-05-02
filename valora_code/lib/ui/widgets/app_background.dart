import 'package:flutter/material.dart';

/// Fondo degradado morado de marca para todas las pantallas.
///
/// Envuelve [child] en un [Container] con el mismo gradiente que el splash.
class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A0A6E), Color(0xFF1A0047), Color(0xFF0F0035)],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: child,
    );
  }
}
