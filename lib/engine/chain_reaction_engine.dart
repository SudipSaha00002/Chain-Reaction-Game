import 'dart:collection';
import '../config/game_config.dart';
import '../models/cell.dart';
import '../models/game_state.dart';

/// Core game engine — pure logic, no UI dependencies.
/// Uses iterative BFS-based explosion handling (no recursion) to avoid stack overflows.
class ChainReactionEngine {
  ChainReactionEngine._();

  /// Places an orb at (row, col) for [player] and resolves all chain explosions.
  /// Returns the new [GameState], or the unchanged state if the move is invalid.
  static GameState makeMove(GameState state, int row, int col) {
    if (state.isOver) return state;
    if (!state.isValidMove(row, col, state.currentPlayer)) return state;

    final player = state.currentPlayer;

    // Deep copy board
    final board = [for (final r in state.board) [...r]];

    // Place the orb
    board[row][col] = board[row][col].withAddedOrb(player);

    // Resolve explosions with BFS
    _resolveExplosions(board, state.rows, state.cols, player);

    // Check winner
    final result = _checkGameOver(board, state.rows, state.cols, state.moveCount + 1);

    final nextPlayer = player.opponent;
    return state.copyWith(
      board: board,
      currentPlayer: result.$1 ? (result.$2 ?? nextPlayer) : nextPlayer,
      isOver: result.$1,
      winner: result.$2,
      clearWinner: result.$1 && result.$2 == null,
      moveCount: state.moveCount + 1,
      redMovesMade: player == Player.red ? state.redMovesMade + 1 : state.redMovesMade,
      blueMovesMade: player == Player.blue ? state.blueMovesMade + 1 : state.blueMovesMade,
    );
  }

  /// BFS explosion resolution — port of the Python recursive handler,
  /// rewritten iteratively for safety.
  static void _resolveExplosions(
    List<List<Cell>> board,
    int rows,
    int cols,
    Player explodingPlayer,
  ) {
    // Queue of cells that need to be checked for explosion
    final queue = Queue<(int, int)>();

    // Seed: find all cells that are already at or over critical mass
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final cm = GameConfig.criticalMass(r, c, rows, cols);
        if (board[r][c].count >= cm && board[r][c].player == explodingPlayer) {
          queue.add((r, c));
        }
      }
    }

    // BFS
    while (queue.isNotEmpty) {
      final (row, col) = queue.removeFirst();
      final cm = GameConfig.criticalMass(row, col, rows, cols);

      if (board[row][col].count < cm) continue; // no longer critical

      // Explode: remove critical mass orbs from this cell
      final remaining = board[row][col].count - cm;
      board[row][col] = remaining == 0
          ? const Cell()
          : Cell(count: remaining, player: board[row][col].player);

      // Distribute one orb to each neighbor, converting to explodingPlayer
      for (final (nr, nc) in GameConfig.neighbors(row, col, rows, cols)) {
        final newCount = board[nr][nc].count + 1;
        board[nr][nc] = Cell(count: newCount, player: explodingPlayer);

        // If neighbor is now at critical mass, enqueue it
        if (newCount >= GameConfig.criticalMass(nr, nc, rows, cols)) {
          queue.add((nr, nc));
        }
      }
    }
  }

  /// Returns (isOver, winner). winner==null means draw.
  /// Game is only over after at least 2 total moves (both players have played).
  static (bool, Player?) _checkGameOver(
    List<List<Cell>> board,
    int rows,
    int cols,
    int moveCount,
  ) {
    if (moveCount < 2) return (false, null);

    int redOrbs = 0;
    int blueOrbs = 0;

    for (final row in board) {
      for (final cell in row) {
        if (cell.player == Player.red) redOrbs += cell.count;
        if (cell.player == Player.blue) blueOrbs += cell.count;
      }
    }

    if (redOrbs == 0 && blueOrbs > 0) return (true, Player.blue);
    if (blueOrbs == 0 && redOrbs > 0) return (true, Player.red);
    if (redOrbs == 0 && blueOrbs == 0) return (true, null); // draw

    return (false, null);
  }

  /// Returns all valid moves for [player] in the given [state].
  static List<(int, int)> validMoves(GameState state, Player player) {
    final moves = <(int, int)>[];
    for (int r = 0; r < state.rows; r++) {
      for (int c = 0; c < state.cols; c++) {
        if (state.isValidMove(r, c, player)) moves.add((r, c));
      }
    }
    return moves;
  }

  /// Applies a move to a copied state — for AI search tree simulation.
  static GameState simulateMove(GameState state, int row, int col, Player player) {
    // Override currentPlayer so makeMove works correctly
    final tempState = state.copyWith(currentPlayer: player);
    return makeMove(tempState, row, col);
  }
}
