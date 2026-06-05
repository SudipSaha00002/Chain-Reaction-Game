import '../config/game_config.dart';

/// Represents a single cell on the board.
/// Immutable — create new instances for state changes.
class Cell {
  const Cell({this.count = 0, this.player});

  final int count;
  final Player? player;

  bool get isEmpty => count == 0 || player == null;

  Cell copyWith({int? count, Player? player, bool clearPlayer = false}) {
    return Cell(
      count: count ?? this.count,
      player: clearPlayer ? null : (player ?? this.player),
    );
  }

  Cell withAddedOrb(Player p) {
    return Cell(count: count + 1, player: p);
  }

  @override
  String toString() => isEmpty ? '0' : '$count${player!.shortName}';

  @override
  bool operator ==(Object other) =>
      other is Cell && other.count == count && other.player == player;

  @override
  int get hashCode => Object.hash(count, player);
}
