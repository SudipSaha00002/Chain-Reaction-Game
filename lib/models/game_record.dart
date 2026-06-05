import '../config/game_config.dart';

/// A saved record of a completed game, used for history display.
class GameRecord {
  const GameRecord({
    required this.id,
    required this.mode,
    required this.winner,
    required this.moveCount,
    required this.durationSeconds,
    required this.timestamp,
    required this.rows,
    required this.cols,
    this.redHeuristic,
    this.blueHeuristic,
    this.redDepth,
    this.blueDepth,
  });

  final String id;
  final GameMode mode;
  final Player? winner; // null = draw
  final int moveCount;
  final int durationSeconds;
  final DateTime timestamp;
  final int rows;
  final int cols;
  final HeuristicStrategy? redHeuristic;
  final HeuristicStrategy? blueHeuristic;
  final int? redDepth;
  final int? blueDepth;

  Map<String, dynamic> toJson() => {
        'id': id,
        'mode': mode.index,
        'winner': winner?.index,
        'moveCount': moveCount,
        'durationSeconds': durationSeconds,
        'timestamp': timestamp.toIso8601String(),
        'rows': rows,
        'cols': cols,
        'redHeuristic': redHeuristic?.index,
        'blueHeuristic': blueHeuristic?.index,
        'redDepth': redDepth,
        'blueDepth': blueDepth,
      };

  factory GameRecord.fromJson(Map<String, dynamic> json) => GameRecord(
        id: json['id'] as String,
        mode: GameMode.values[json['mode'] as int],
        winner: json['winner'] != null ? Player.values[json['winner'] as int] : null,
        moveCount: json['moveCount'] as int,
        durationSeconds: json['durationSeconds'] as int,
        timestamp: DateTime.parse(json['timestamp'] as String),
        rows: json['rows'] as int,
        cols: json['cols'] as int,
        redHeuristic: json['redHeuristic'] != null
            ? HeuristicStrategy.values[json['redHeuristic'] as int]
            : null,
        blueHeuristic: json['blueHeuristic'] != null
            ? HeuristicStrategy.values[json['blueHeuristic'] as int]
            : null,
        redDepth: json['redDepth'] as int?,
        blueDepth: json['blueDepth'] as int?,
      );
}
