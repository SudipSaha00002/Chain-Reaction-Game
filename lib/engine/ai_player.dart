import 'dart:math';
import '../config/game_config.dart';
import '../models/game_state.dart';
import 'chain_reaction_engine.dart';

/// Arguments bundle sent to the AI isolate.
class AIArgs {
  const AIArgs({
    required this.state,
    required this.player,
    required this.depth,
    required this.weights,
    required this.timeLimitMs,
  });

  final GameState state;
  final Player player;
  final int depth;
  final List<double> weights;
  final int timeLimitMs;
}

/// Result returned from the AI isolate.
class AIResult {
  const AIResult(this.row, this.col);
  final int row;
  final int col;
}

/// Minimax AI with alpha-beta pruning and iterative deepening.
/// All 5 heuristics from the Python implementation.
class AIPlayer {
  AIPlayer({
    required this.player,
    required this.depth,
    required this.weights,
    required this.timeLimitMs,
  });

  final Player player;
  final int depth;
  final List<double> weights; // [orbCount, criticalMass, strategic, mobility, explosion]
  final int timeLimitMs;

  late DateTime _startTime;
  bool _timeUp = false;

  /// Entry point: returns the best (row, col) move.
  (int, int)? findBestMove(GameState state) {
    _startTime = DateTime.now();
    _timeUp = false;

    (int, int)? bestMove;

    // Iterative deepening: try increasing depths until time runs out
    for (int d = 1; d <= depth; d++) {
      final result = _minimax(state, d, -double.infinity, double.infinity, true);
      if (result.$2 != null) bestMove = result.$2;
      if (_timeUp) break;
    }

    return bestMove;
  }

  /// Minimax with alpha-beta pruning.
  (double, (int, int)?) _minimax(
    GameState state,
    int depthLeft,
    double alpha,
    double beta,
    bool maximizing,
  ) {
    // Check time limit
    if (DateTime.now().difference(_startTime).inMilliseconds >= timeLimitMs) {
      _timeUp = true;
      return (_evaluate(state), null);
    }

    if (depthLeft == 0 || state.isOver) {
      return (_evaluate(state), null);
    }

    final currentPlayer = maximizing ? player : player.opponent;
    final moves = ChainReactionEngine.validMoves(state, currentPlayer);

    if (moves.isEmpty) return (_evaluate(state), null);

    (int, int)? bestMove;

    if (maximizing) {
      double maxEval = -double.infinity;
      for (final (r, c) in moves) {
        final nextState = ChainReactionEngine.simulateMove(state, r, c, currentPlayer);
        final (eval, _) = _minimax(nextState, depthLeft - 1, alpha, beta, false);
        if (eval > maxEval) {
          maxEval = eval;
          bestMove = (r, c);
        }
        alpha = max(alpha, eval);
        if (beta <= alpha) break; // alpha-beta cut
        if (_timeUp) break;
      }
      return (maxEval, bestMove);
    } else {
      double minEval = double.infinity;
      for (final (r, c) in moves) {
        final nextState = ChainReactionEngine.simulateMove(state, r, c, currentPlayer);
        final (eval, _) = _minimax(nextState, depthLeft - 1, alpha, beta, true);
        if (eval < minEval) {
          minEval = eval;
          bestMove = (r, c);
        }
        beta = min(beta, eval);
        if (beta <= alpha) break; // alpha-beta cut
        if (_timeUp) break;
      }
      return (minEval, bestMove);
    }
  }

  /// Weighted sum of all 5 heuristics.
  double _evaluate(GameState state) {
    if (state.isOver) {
      if (state.winner == player) return 1e9;
      if (state.winner == player.opponent) return -1e9;
      return 0; // draw
    }
    return weights[0] * _heuristicOrbCount(state) +
        weights[1] * _heuristicCriticalMass(state) +
        weights[2] * _heuristicStrategicPosition(state) +
        weights[3] * _heuristicOpponentMobility(state) +
        weights[4] * _heuristicExplosionPotential(state);
  }

  // ── Heuristic 1: Orb Count ─────────────────────────────────────
  double _heuristicOrbCount(GameState state) {
    int mine = 0, theirs = 0;
    for (final row in state.board) {
      for (final cell in row) {
        if (cell.player == player) mine += cell.count;
        if (cell.player == player.opponent) theirs += cell.count;
      }
    }
    final total = mine + theirs;
    if (total == 0) return 0;
    return (mine - theirs) / total;
  }

  // ── Heuristic 2: Critical Mass ─────────────────────────────────
  double _heuristicCriticalMass(GameState state) {
    double score = 0;
    for (int r = 0; r < state.rows; r++) {
      for (int c = 0; c < state.cols; c++) {
        final cell = state.board[r][c];
        if (cell.isEmpty) continue;
        final cm = GameConfig.criticalMass(r, c, state.rows, state.cols);
        final ratio = cell.count / cm;
        score += cell.player == player ? ratio : -ratio;
      }
    }
    return score / (state.rows * state.cols);
  }

  // ── Heuristic 3: Strategic Position ───────────────────────────
  double _heuristicStrategicPosition(GameState state) {
    double score = 0;
    for (int r = 0; r < state.rows; r++) {
      for (int c = 0; c < state.cols; c++) {
        final cell = state.board[r][c];
        if (cell.isEmpty) continue;
        final cm = GameConfig.criticalMass(r, c, state.rows, state.cols);
        final posValue = 1.0 / cm; // corners=0.5, edges=0.33, middle=0.25
        score += cell.player == player
            ? posValue * cell.count
            : -posValue * cell.count;
      }
    }
    return score;
  }

  // ── Heuristic 4: Opponent Mobility ────────────────────────────
  double _heuristicOpponentMobility(GameState state) {
    int myMoves = 0, theirMoves = 0;
    for (int r = 0; r < state.rows; r++) {
      for (int c = 0; c < state.cols; c++) {
        if (state.isValidMove(r, c, player)) myMoves++;
        if (state.isValidMove(r, c, player.opponent)) theirMoves++;
      }
    }
    final total = myMoves + theirMoves;
    if (total == 0) return 0;
    return (myMoves - theirMoves) / total;
  }

  // ── Heuristic 5: Explosion Potential ──────────────────────────
  double _heuristicExplosionPotential(GameState state) {
    double score = 0;
    for (int r = 0; r < state.rows; r++) {
      for (int c = 0; c < state.cols; c++) {
        final cell = state.board[r][c];
        if (cell.isEmpty) continue;
        final cm = GameConfig.criticalMass(r, c, state.rows, state.cols);
        if (cell.count != cm - 1) continue; // only 1 away from exploding

        for (final (nr, nc) in GameConfig.neighbors(r, c, state.rows, state.cols)) {
          final neighbor = state.board[nr][nc];
          if (cell.player == player) {
            if (neighbor.player == player.opponent) {
              score += 1.0; // can capture opponent
            } else if (neighbor.isEmpty) {
              score += 0.5; // can expand territory
            }
          } else {
            if (neighbor.player == player) {
              score -= 1.0; // opponent can capture my cell
            }
          }
        }
      }
    }
    return score / (state.rows * state.cols);
  }
}

/// Top-level function for use with Flutter's compute().
/// Must be a top-level function, not a class method.
AIResult runAI(AIArgs args) {
  final ai = AIPlayer(
    player: args.player,
    depth: args.depth,
    weights: args.weights,
    timeLimitMs: args.timeLimitMs,
  );
  final move = ai.findBestMove(args.state);
  if (move == null) {
    // Fallback: pick any valid move
    final moves = ChainReactionEngine.validMoves(args.state, args.player);
    if (moves.isEmpty) return const AIResult(-1, -1);
    return AIResult(moves.first.$1, moves.first.$2);
  }
  return AIResult(move.$1, move.$2);
}
