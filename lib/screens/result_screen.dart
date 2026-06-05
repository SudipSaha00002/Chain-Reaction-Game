import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/game_config.dart';
import '../utils/theme.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({
    super.key,
    required this.winner,
    required this.moveCount,
    required this.durationSeconds,
    required this.mode,
  });

  final Player? winner;
  final int moveCount;
  final int durationSeconds;
  final GameMode mode;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _particleController;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;
  final List<_ConfettiParticle> _confetti = [];

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _scaleAnim = CurvedAnimation(parent: _entryController, curve: Curves.elasticOut);
    _fadeAnim = CurvedAnimation(parent: _entryController, curve: Curves.easeIn);

    // Generate confetti
    if (widget.winner != null) {
      final rand = Random();
      final color = widget.winner!.color;
      for (int i = 0; i < 40; i++) {
        _confetti.add(_ConfettiParticle(
          x: rand.nextDouble(),
          y: rand.nextDouble(),
          size: rand.nextDouble() * 8 + 4,
          speed: rand.nextDouble() * 0.4 + 0.2,
          color: [color, Colors.white, AppTheme.accent][rand.nextInt(3)],
          angle: rand.nextDouble() * 6.28,
        ));
      }
    }
  }

  @override
  void dispose() {
    _entryController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final winner = widget.winner;
    final color = winner?.color ?? AppTheme.accent;
    final isDraw = winner == null;

    return Scaffold(
      body: Stack(
        children: [
          Container(decoration: const BoxDecoration(gradient: AppTheme.bgGradient)),

          // Confetti / particles
          if (!isDraw)
            AnimatedBuilder(
              animation: _particleController,
              builder: (_, __) => CustomPaint(
                painter: _ConfettiPainter(_confetti, _particleController.value),
                child: const SizedBox.expand(),
              ),
            ),

          SafeArea(
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: ScaleTransition(
                  scale: _scaleAnim,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Trophy icon
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color.withValues(alpha: 0.15),
                            border: Border.all(color: color.withValues(alpha: 0.4), width: 2),
                            boxShadow: [
                              BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 32),
                            ],
                          ),
                          child: Icon(
                            isDraw
                                ? Icons.handshake_outlined
                                : Icons.emoji_events_rounded,
                            color: color,
                            size: 48,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Result text
                        Text(
                          isDraw ? 'DRAW!' : '${winner.name.toUpperCase()} WINS!',
                          style: GoogleFonts.rajdhani(
                            color: color,
                            fontSize: 44,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getSubtitle(),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Stats row
                        Row(
                          children: [
                            _StatCard(
                              icon: Icons.swap_horiz_rounded,
                              value: '${widget.moveCount}',
                              label: 'Moves',
                            ),
                            const SizedBox(width: 12),
                            _StatCard(
                              icon: Icons.timer_rounded,
                              value: _formatDuration(widget.durationSeconds),
                              label: 'Duration',
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),

                        // Buttons
                        _ActionButton(
                          label: 'PLAY AGAIN',
                          icon: Icons.replay_rounded,
                          gradient: LinearGradient(
                            colors: [color, color.withValues(alpha: 0.7)],
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            // GameScreen will restart via provider
                          },
                        ),
                        const SizedBox(height: 14),
                        _ActionButton(
                          label: 'MAIN MENU',
                          icon: Icons.home_rounded,
                          gradient: AppTheme.cardGradient,
                          onTap: () =>
                              Navigator.popUntil(context, (r) => r.isFirst),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getSubtitle() {
    final winner = widget.winner;
    if (winner == null) return 'Both players fought hard!';
    if (widget.mode == GameMode.humanVsAI) {
      return winner == Player.red
          ? 'You defeated the AI! 🎉'
          : 'The AI outsmarted you! Better luck next time.';
    }
    if (widget.mode == GameMode.humanVsHuman) {
      return 'Well played ${winner.name} player!';
    }
    return 'AI ${winner.name} wins the battle!';
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) return '${seconds}s';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m}m ${s}s';
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: AppTheme.cardGradient,
          border: Border.all(color: AppTheme.bgBorder),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.accent, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.rajdhani(
                color: AppTheme.textPrimary,
                fontSize: 26,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
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
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: gradient,
          border: Border.all(color: AppTheme.bgBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.textPrimary, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.rajdhani(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfettiParticle {
  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.color,
    required this.angle,
  });

  double x, y, size, speed, angle;
  Color color;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.particles, this.progress);
  final List<_ConfettiParticle> particles;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final y = ((p.y + progress * p.speed) % 1.0) * size.height;
      final x = p.x * size.width;
      final paint = Paint()
        ..color = p.color.withValues(alpha: 0.7)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.angle + progress * 3);
      canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.5),
          paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}
