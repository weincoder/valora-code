import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes/app_router.dart';
import '../../../config/theme/app_theme.dart';
import '../../painters/orb_painter.dart';
import '../../widgets/owl_mascot.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  // Fade in: 0→0.25  |  visible: 0.25→0.80  |  fade out: 0.80→1.0
  late final Animation<double> _fadeIn;
  late final Animation<double> _fadeOut;
  late final Animation<double> _scaleIn;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    );

    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.24, curve: Curves.easeIn),
      ),
    );

    _scaleIn = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.30, curve: Curves.easeOutBack),
      ),
    );

    _fadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.80, 1.0, curve: Curves.easeOut),
      ),
    );

    _ctrl.forward().then((_) {
      if (mounted) context.go(AppRouter.home);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0035),
      body: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          // During fade-out phase use fadeOut value; otherwise use fadeIn
          final contentOpacity = _ctrl.value < 0.80
              ? _fadeIn.value
              : _fadeOut.value;

          // Orbs static — no animation movement
          const orbAnim = 0.5;

          return Stack(
            fit: StackFit.expand,
            children: [
              // ── Background gradient ─────────────────────────────────────
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF2A0A6E),
                      Color(0xFF1A0047),
                      Color(0xFF0F0035),
                    ],
                    stops: [0.0, 0.55, 1.0],
                  ),
                ),
              ),

              // ── Floating orbs ───────────────────────────────────────────
              Opacity(
                opacity: _fadeIn.value.clamp(0.0, 1.0),
                child: Positioned.fill(
                  child: CustomPaint(painter: OrbPainter(animValue: orbAnim)),
                ),
              ),

              // ── Content ─────────────────────────────────────────────────
              Opacity(
                opacity: contentOpacity.clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: _scaleIn.value,
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const OwlMascot(
                          scenario: OwlScenario.greeting,
                          size: 190,
                        ),
                        const SizedBox(height: 36),
                        const Text(
                          'ValoraCode',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1.2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Simplifica tu negocio',
                          style: TextStyle(
                            color: AppTheme.accentColor.withValues(alpha: 0.90),
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'con estilo',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.45),
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        const SizedBox(height: 60),
                        // Loading dots
                        _LoadingDots(progress: _ctrl.value),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Tres puntos animados que indican progreso de carga.
class _LoadingDots extends StatelessWidget {
  final double progress;

  const _LoadingDots({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final dotProgress = ((progress * 3 - i) % 1.0).clamp(0.0, 1.0);
        final scale = 0.7 + dotProgress * 0.3;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accentColor.withValues(
                  alpha: 0.35 + dotProgress * 0.65,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
