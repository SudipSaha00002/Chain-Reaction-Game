import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/theme.dart';
import 'mode_selection_screen.dart';
import 'settings_screen.dart';
import 'history_screen.dart';

class TitleScreen extends StatefulWidget {
  const TitleScreen({super.key});

  @override
  State<TitleScreen> createState() => _TitleScreenState();
}

class _TitleScreenState extends State<TitleScreen> with TickerProviderStateMixin {
  late final AnimationController _floatController;
  late final AnimationController _particleController;
  late final Animation<double> _floatAnim;
  final List<_Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();
    _floatAnim = CurvedAnimation(parent: _floatController, curve: Curves.easeInOut);

    final rand = Random();
    for (int i = 0; i < 20; i++) {
      _particles.add(_Particle(
        x: rand.nextDouble(),
        y: rand.nextDouble(),
        radius: rand.nextDouble() * 4 + 2,
        speed: rand.nextDouble() * 0.3 + 0.1,
        color: [AppTheme.red, AppTheme.blue, AppTheme.accent][rand.nextInt(3)],
      ));
    }
  }

  @override
  void dispose() {
    _floatController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated background
          Container(decoration: const BoxDecoration(gradient: AppTheme.bgGradient)),

          // Particle field
          AnimatedBuilder(
            animation: _particleController,
            builder: (_, __) => CustomPaint(
              painter: _ParticlePainter(_particles, _particleController.value),
              child: const SizedBox.expand(),
            ),
          ),

          // Main content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // Animated logo orb cluster
                      AnimatedBuilder(
                        animation: _floatAnim,
                        builder: (_, __) => Transform.translate(
                          offset: Offset(0, -8 * _floatAnim.value),
                          child: _LogoOrbs(),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Title
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [AppTheme.red, AppTheme.accent, AppTheme.blue],
                        ).createShader(bounds),
                        child: Text(
                          'CHAIN\nREACTION',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.rajdhani(
                            fontSize: 52,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 0.95,
                            letterSpacing: 4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Strategic Board Game with AI',
                        style: GoogleFonts.inter(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 52),
                      // Buttons
                      _MenuButton(
                        label: 'PLAY',
                        icon: Icons.play_arrow_rounded,
                        gradient: AppTheme.accentGradient,
                        onTap: () => Navigator.push(
                          context,
                          _fadeRoute(const ModeSelectionScreen()),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _MenuButton(
                        label: 'SETTINGS',
                        icon: Icons.tune_rounded,
                        gradient: AppTheme.cardGradient,
                        onTap: () => Navigator.push(
                          context,
                          _fadeRoute(const SettingsScreen()),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _MenuButton(
                        label: 'HISTORY',
                        icon: Icons.history_rounded,
                        gradient: AppTheme.cardGradient,
                        onTap: () => Navigator.push(
                          context,
                          _fadeRoute(const HistoryScreen()),
                        ),
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Route _fadeRoute(Widget page) => PageRouteBuilder(
        pageBuilder: (_, a, __) => page,
        transitionsBuilder: (_, a, __, child) =>
            FadeTransition(opacity: a, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      );
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.label,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final LinearGradient gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: gradient,
          border: Border.all(color: AppTheme.bgBorder, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accent.withValues(alpha: 0.15),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.textPrimary, size: 22),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.rajdhani(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoOrbs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 10,
            top: 10,
            child: _GlowOrb(color: AppTheme.red, size: 44),
          ),
          Positioned(
            right: 10,
            top: 10,
            child: _GlowOrb(color: AppTheme.blue, size: 44),
          ),
          Positioned(
            bottom: 10,
            child: _GlowOrb(color: AppTheme.accent, size: 44),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.color, required this.size});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: 0.9), color.withValues(alpha: 0.6)],
        ),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 20, spreadRadius: 4),
        ],
      ),
    );
  }
}

class _Particle {
  _Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.color,
  });

  double x, y, radius, speed;
  Color color;
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter(this.particles, this.progress);
  final List<_Particle> particles;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final y = ((p.y + progress * p.speed) % 1.0) * size.height;
      final x = p.x * size.width;
      final paint = Paint()
        ..color = p.color.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(Offset(x, y), p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}
