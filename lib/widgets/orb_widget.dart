import 'package:flutter/material.dart';
import '../config/game_config.dart';

/// Animated orb widget. Shows 1, 2, or 3 orb circles arranged beautifully.
class OrbWidget extends StatefulWidget {
  const OrbWidget({
    super.key,
    required this.count,
    required this.player,
    required this.isExploding,
    required this.isNew,
  });

  final int count;
  final Player player;
  final bool isExploding;
  final bool isNew;

  @override
  State<OrbWidget> createState() => _OrbWidgetState();
}

class _OrbWidgetState extends State<OrbWidget> with TickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final AnimationController _explodeController;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _explodeAnim;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: GameConfig.orbPlaceDuration,
    );
    _explodeController = AnimationController(
      vsync: this,
      duration: GameConfig.explosionDuration,
    );
    _scaleAnim = CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut);
    _explodeAnim = CurvedAnimation(parent: _explodeController, curve: Curves.easeOut);

    if (widget.isNew) {
      _scaleController.forward();
    } else {
      _scaleController.value = 1.0;
    }
    if (widget.isExploding) {
      _explodeController.forward();
    }
  }

  @override
  void didUpdateWidget(OrbWidget old) {
    super.didUpdateWidget(old);
    if (widget.isNew && !old.isNew) {
      _scaleController.forward(from: 0);
    }
    if (widget.isExploding && !old.isExploding) {
      _explodeController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _explodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.player.color;
    final glowColor = widget.player.glowColor;

    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnim, _explodeAnim]),
      builder: (context, child) {
        final scale = _scaleAnim.value;
        final explodeScale = 1.0 + _explodeAnim.value * 0.5;
        final explodeOpacity = 1.0 - _explodeAnim.value * 0.8;

        return Opacity(
          opacity: explodeOpacity.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: scale * explodeScale,
            child: _buildOrbLayout(color, glowColor),
          ),
        );
      },
    );
  }

  Widget _buildOrbLayout(Color color, Color glowColor) {
    switch (widget.count) {
      case 1:
        return Center(child: _orb(color, glowColor, 10));
      case 2:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _orb(color, glowColor, 8),
            _orb(color, glowColor, 8),
          ],
        );
      case 3:
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _orb(color, glowColor, 7),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _orb(color, glowColor, 7),
                _orb(color, glowColor, 7),
              ],
            ),
          ],
        );
      default:
        // 4+ shouldn't render (explosion should have happened)
        return Center(
          child: Text(
            '${widget.count}',
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10),
          ),
        );
    }
  }

  Widget _orb(Color color, Color glowColor, double radius) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: 0.9), color],
          stops: const [0.2, 1.0],
        ),
        boxShadow: [
          BoxShadow(color: glowColor, blurRadius: 8, spreadRadius: 1),
          BoxShadow(color: glowColor.withValues(alpha: 0.3), blurRadius: 16),
        ],
      ),
    );
  }
}
