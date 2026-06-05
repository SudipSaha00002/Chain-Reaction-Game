import '../config/game_config.dart';
import 'cell.dart';

/// Full snapshot of the game state.
/// Designed to be copied cheaply for the AI search tree.
class GameState {
  GameState({
    required this.rows,
    required this.cols,
    required this.board,
    required this.currentPlayer,
    this.isOver = false,
    this.winner,
    this.moveCount = 0,
    this.redMovesMade = 0,
    this.blueMovesMade = 0,
  });

  final int rows;
  final int cols;
  final List<List<Cell>> board;
  final Player currentPlayer;
  final bool isOver;
  final Player? winner;
  final int moveCount;
  final int redMovesMade;
  final int blueMovesMade;

  /// Creates an empty starting board
  factory GameState.initial({required int rows, required int cols}) {
    final board = List.generate(
      rows,
      (_) => List.filled(cols, const Cell()),
    );
    return GameState(
      rows: rows,
      cols: cols,
      board: board,
      currentPlayer: Player.red,
    );
  }

  /// Deep copy of this state (used by AI)
  GameState copy() {
    return GameState(
      rows: rows,
      cols: cols,
      board: [for (final row in board) [...row]],
      currentPlayer: currentPlayer,
      isOver: isOver,
      winner: winner,
      moveCount: moveCount,
      redMovesMade: redMovesMade,
      blueMovesMade: blueMovesMade,
    );
  }

  GameState copyWith({
    Player? currentPlayer,
    bool? isOver,
    Player? winner,
    bool clearWinner = false,
    List<List<Cell>>? board,
    int? moveCount,
    int? redMovesMade,
    int? blueMovesMade,
  }) {
    return GameState(
      rows: rows,
      cols: cols,
      board: board ?? this.board,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      isOver: isOver ?? this.isOver,
      winner: clearWinner ? null : (winner ?? this.winner),
      moveCount: moveCount ?? this.moveCount,
      redMovesMade: redMovesMade ?? this.redMovesMade,
      blueMovesMade: blueMovesMade ?? this.blueMovesMade,
    );
  }

  Cell getCell(int row, int col) => board[row][col];

  int orbsFor(Player p) {
    int total = 0;
    for (final row in board) {
      for (final cell in row) {
        if (cell.player == p) total += cell.count;
      }
    }
    return total;
  }

  bool isValidMove(int row, int col, Player player) {
    if (row < 0 || row >= rows || col < 0 || col >= cols) return false;
    final cell = board[row][col];
    return cell.isEmpty || cell.player == player;
  }
}
