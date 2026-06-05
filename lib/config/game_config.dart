import 'package:flutter/material.dart';

/// Supported board size configurations
enum BoardSize {
  small(6, 5, '6 × 5'),
  medium(9, 6, '9 × 6'),
  large(10, 8, '10 × 8');

  const BoardSize(this.rows, this.cols, this.label);
  final int rows;
  final int cols;
  final String label;
}

/// AI heuristic strategies
enum HeuristicStrategy {
  orbCount('Orb Count', 'Maximizes orb count advantage'),
  criticalMass('Critical Mass', 'Pushes cells toward explosion'),
  strategicPosition('Strategic Position', 'Favors corners and edges'),
  opponentMobility('Opponent Mobility', 'Restricts opponent moves'),
  explosionPotential('Explosion Potential', 'Triggers chain reactions'),
  balanced('Balanced', 'Combines all strategies');

  const HeuristicStrategy(this.label, this.description);
  final String label;
  final String description;

  /// Returns the weight vector for this heuristic [orbCount, criticalMass, strategic, mobility, explosion]
  List<double> get weights {
    switch (this) {
      case HeuristicStrategy.orbCount:
        return [1.0, 0, 0, 0, 0];
      case HeuristicStrategy.criticalMass:
        return [0, 1.0, 0, 0, 0];
      case HeuristicStrategy.strategicPosition:
        return [0, 0, 1.0, 0, 0];
      case HeuristicStrategy.opponentMobility:
        return [0.3, 0.2, 0.2, 0.15, 0.15];
      case HeuristicStrategy.explosionPotential:
        return [0.5, 0.3, 0.1, 0.05, 0.05];
      case HeuristicStrategy.balanced:
        return [0.25, 0.25, 0.2, 0.15, 0.15];
    }
  }
}

/// Game mode
enum GameMode {
  humanVsHuman('Human vs Human'),
  humanVsAI('Human vs AI'),
  aiVsAI('AI vs AI');

  const GameMode(this.label);
  final String label;
}

/// Player identifier
enum Player {
  red,
  blue;

  Player get opponent => this == Player.red ? Player.blue : Player.red;

  Color get color => this == Player.red ? GameConfig.redColor : GameConfig.blueColor;
  Color get dimColor => this == Player.red ? GameConfig.redDimColor : GameConfig.blueDimColor;
  Color get glowColor => this == Player.red ? GameConfig.redGlowColor : GameConfig.blueGlowColor;

  String get name => this == Player.red ? 'Red' : 'Blue';
  String get shortName => this == Player.red ? 'R' : 'B';
}

/// Central configuration constants
class GameConfig {
  GameConfig._();

  // ── Player Colors ──────────────────────────────────────────────
  static const Color redColor = Color(0xFFFF4757);
  static const Color redDimColor = Color(0x55FF4757);
  static const Color redGlowColor = Color(0xAAFF4757);

  static const Color blueColor = Color(0xFF2F86EB);
  static const Color blueDimColor = Color(0x552F86EB);
  static const Color blueGlowColor = Color(0xAA2F86EB);

  // ── AI Defaults ────────────────────────────────────────────────
  static const int defaultDepth = 3;
  static const double defaultTimeLimitSeconds = 5.0;
  static const HeuristicStrategy defaultHeuristic = HeuristicStrategy.balanced;

  // ── Animation Durations ────────────────────────────────────────
  static const Duration orbPlaceDuration = Duration(milliseconds: 300);
  static const Duration explosionDuration = Duration(milliseconds: 400);
  static const Duration moveDelay = Duration(milliseconds: 200);
  static const Duration aiMoveDelay = Duration(milliseconds: 500);

  // ── Game Rules ─────────────────────────────────────────────────
  /// Critical mass = number of orthogonal neighbors
  static int criticalMass(int row, int col, int rows, int cols) {
    final isTopBottom = row == 0 || row == rows - 1;
    final isLeftRight = col == 0 || col == cols - 1;
    if (isTopBottom && isLeftRight) return 2; // corner
    if (isTopBottom || isLeftRight) return 3; // edge
    return 4; // middle
  }

  static List<(int, int)> neighbors(int row, int col, int rows, int cols) {
    final result = <(int, int)>[];
    if (row > 0) result.add((row - 1, col));
    if (row < rows - 1) result.add((row + 1, col));
    if (col > 0) result.add((row, col - 1));
    if (col < cols - 1) result.add((row, col + 1));
    return result;
  }
}
