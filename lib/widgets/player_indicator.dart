import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../config/game_config.dart';
import '../utils/theme.dart';

/// Top bar showing both players' orb counts and whose turn it is.
class PlayerIndicator extends StatelessWidget {
  const PlayerIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final state = provider.state;
    final redOrbs = state.orbsFor(Player.red);
    final blueOrbs = state.orbsFor(Player.blue);
    final currentPlayer = state.currentPlayer;
    final aiThinking = provider.aiIsThinking;

    return Row(
      children: [
        _PlayerCard(
          player: Player.red,
          orbCount: redOrbs,
          isActive: currentPlayer == Player.red,
          label: provider.mode == GameMode.aiVsAI ? 'AI 1' : 'Player 1',
        ),
        const SizedBox(width: 12),
        _TurnIndicator(isAiThinking: aiThinking, currentPlayer: currentPlayer),
        const SizedBox(width: 12),
        _PlayerCard(
          player: Player.blue,
          orbCount: blueOrbs,
          isActive: currentPlayer == Player.blue,
          label: provider.mode == GameMode.humanVsHuman ? 'Player 2' : 'AI',
        ),
      ],
    );
  }
}

class _PlayerCard extends StatelessWidget {
  const _PlayerCard({
    required this.player,
    required this.orbCount,
    required this.isActive,
    required this.label,
  });

  final Player player;
  final int orbCount;
  final bool isActive;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = player.color;
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: isActive
                ? [color.withValues(alpha: 0.2), color.withValues(alpha: 0.08)]
                : [AppTheme.bgCard, AppTheme.bgSurface],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: isActive ? color.withValues(alpha: 0.6) : AppTheme.bgBorder,
            width: isActive ? 1.5 : 1,
          ),
          boxShadow: isActive
              ? [BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 12)]
              : null,
        ),
        child: Column(
          crossAxisAlignment: player == Player.red
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: player == Player.red
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.end,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                    boxShadow: isActive
                        ? [BoxShadow(color: color, blurRadius: 6)]
                        : null,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    color: isActive ? color : AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '$orbCount orbs',
              style: GoogleFonts.rajdhani(
                color: isActive ? AppTheme.textPrimary : AppTheme.textSecondary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              textAlign:
                  player == Player.blue ? TextAlign.right : TextAlign.left,
            ),
          ],
        ),
      ),
    );
  }
}

class _TurnIndicator extends StatefulWidget {
  const _TurnIndicator({required this.isAiThinking, required this.currentPlayer});
  final bool isAiThinking;
  final Player currentPlayer;

  @override
  State<_TurnIndicator> createState() => _TurnIndicatorState();
}

class _TurnIndicatorState extends State<_TurnIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, __) {
        final opacity = widget.isAiThinking ? (0.5 + _pulse.value * 0.5) : 1.0;
        return Opacity(
          opacity: opacity,
          child: Column(
            children: [
              Icon(
                widget.isAiThinking ? Icons.memory_rounded : Icons.swap_horiz,
                color: AppTheme.accent,
                size: 20,
              ),
              const SizedBox(height: 2),
              Text(
                widget.isAiThinking ? 'AI...' : 'VS',
                style: GoogleFonts.inter(
                  color: AppTheme.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
