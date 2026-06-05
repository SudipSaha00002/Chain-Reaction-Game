import 'package:flutter/material.dart';
import '../config/game_config.dart';
import '../models/cell.dart';
import '../utils/theme.dart';
import 'orb_widget.dart';

/// A single cell on the game board with tap handling and visual state.
class GameCell extends StatefulWidget {
  const GameCell({
    super.key,
    required this.cell,
    required this.row,
    required this.col,
    required this.rows,
    required this.cols,
    required this.isLastMove,
    required this.onTap,
    this.enabled = true,
  });

  final Cell cell;
  final int row;
  final int col;
  final int rows;
  final int cols;
  final bool isLastMove;
  final VoidCallback onTap;
  final bool enabled;

  @override
  State<GameCell> createState() => _GameCellState();
}

class _GameCellState extends State<GameCell> with SingleTickerProviderStateMixin {
  late final AnimationController _highlightController;
  late final Animation<double> _highlightAnim;
  bool _isNew = false;

  @override
  void initState() {
    super.initState();
    _highlightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _highlightAnim = CurvedAnimation(parent: _highlightController, curve: Curves.easeOut);
  }

  @override
  void didUpdateWidget(GameCell old) {
    super.didUpdateWidget(old);
    if (widget.isLastMove && !old.isLastMove) {
      _highlightController.forward(from: 0);
      setState(() => _isNew = true);
      Future.delayed(GameConfig.orbPlaceDuration, () {
        if (mounted) setState(() => _isNew = false);
      });
    }
  }

  @override
  void dispose() {
    _highlightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final criticalMass = GameConfig.criticalMass(widget.row, widget.col, widget.rows, widget.cols);
    final player = widget.cell.player;
    final color = player?.color;
    final dimColor = player?.dimColor;

    return GestureDetector(
      onTap: widget.enabled ? widget.onTap : null,
      child: AnimatedBuilder(
        animation: _highlightAnim,
        builder: (context, child) {
          final glowStrength = widget.isLastMove ? (1.0 - _highlightAnim.value) : 0.0;
          return Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: widget.cell.isEmpty
                    ? [AppTheme.bgSurface, AppTheme.bgCard]
                    : [
                        Color.lerp(AppTheme.bgSurface, dimColor!, 0.6)!,
                        Color.lerp(AppTheme.bgCard, dimColor, 0.4)!,
                      ],
              ),
              border: Border.all(
                color: widget.cell.isEmpty
                    ? AppTheme.bgBorder
                    : (color ?? AppTheme.bgBorder).withValues(alpha: 0.6),
                width: widget.isLastMove ? 1.5 : 1,
              ),
              boxShadow: glowStrength > 0.01
                  ? [
                      BoxShadow(
                        color: (color ?? AppTheme.accent)
                            .withValues(alpha: 0.5 * glowStrength),
                        blurRadius: 12 * glowStrength,
                        spreadRadius: 2 * glowStrength,
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Critical mass hint dots in corner
                Positioned(
                  top: 3,
                  right: 4,
                  child: _CriticalMassIndicator(
                    criticalMass: criticalMass,
                    currentCount: widget.cell.count,
                    player: player,
                  ),
                ),
                // Orbs
                if (!widget.cell.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(6),
                    child: OrbWidget(
                      count: widget.cell.count,
                      player: player!,
                      isExploding: false,
                      isNew: _isNew,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Tiny indicator showing how full a cell is toward critical mass.
class _CriticalMassIndicator extends StatelessWidget {
  const _CriticalMassIndicator({
    required this.criticalMass,
    required this.currentCount,
    required this.player,
  });

  final int criticalMass;
  final int currentCount;
  final Player? player;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(criticalMass, (i) {
        final filled = i < currentCount;
        return Container(
          width: 4,
          height: 4,
          margin: const EdgeInsets.only(left: 1),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled
                ? (player?.color ?? AppTheme.textMuted)
                : AppTheme.textMuted.withValues(alpha: 0.3),
          ),
        );
      }),
    );
  }
}
