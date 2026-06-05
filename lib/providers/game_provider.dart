import 'package:flutter/foundation.dart';
import '../config/game_config.dart';
import '../engine/ai_isolate.dart';
import '../engine/ai_player.dart';
import '../engine/chain_reaction_engine.dart';
import '../models/game_state.dart';

/// Current phase of the game loop.
enum GamePhase { idle, humanTurn, aiThinking, animating, gameOver }

/// Central game state provider.
class GameProvider extends ChangeNotifier {
  GameState _state = GameState.initial(rows: 9, cols: 6);
  GamePhase _phase = GamePhase.humanTurn;
  bool _aiIsThinking = false;
  int? _lastMoveRow;
  int? _lastMoveCol;
  DateTime? _gameStartTime;
  int _durationSeconds = 0;

  // Config
  GameMode _mode = GameMode.humanVsAI;
  BoardSize _boardSize = BoardSize.medium;
  HeuristicStrategy _redHeuristic = GameConfig.defaultHeuristic;
  HeuristicStrategy _blueHeuristic = GameConfig.defaultHeuristic;
  int _redDepth = GameConfig.defaultDepth;
  int _blueDepth = GameConfig.defaultDepth;
  double _timeLimitSeconds = GameConfig.defaultTimeLimitSeconds;
  int _animationDelayMs = 200;

  // Getters
  GameState get state => _state;
  GamePhase get phase => _phase;
  bool get aiIsThinking => _aiIsThinking;
  int? get lastMoveRow => _lastMoveRow;
  int? get lastMoveCol => _lastMoveCol;
  GameMode get mode => _mode;
  BoardSize get boardSize => _boardSize;
  HeuristicStrategy get redHeuristic => _redHeuristic;
  HeuristicStrategy get blueHeuristic => _blueHeuristic;
  int get redDepth => _redDepth;
  int get blueDepth => _blueDepth;
  double get timeLimitSeconds => _timeLimitSeconds;
  int get animationDelayMs => _animationDelayMs;
  int get durationSeconds => _durationSeconds;
  DateTime? get gameStartTime => _gameStartTime;

  /// Configure and start a new game.
  void startGame({
    required GameMode mode,
    required BoardSize boardSize,
    HeuristicStrategy? redHeuristic,
    HeuristicStrategy? blueHeuristic,
    int? redDepth,
    int? blueDepth,
    double? timeLimitSeconds,
    int? animationDelayMs,
  }) {
    _mode = mode;
    _boardSize = boardSize;
    if (redHeuristic != null) _redHeuristic = redHeuristic;
    if (blueHeuristic != null) _blueHeuristic = blueHeuristic;
    if (redDepth != null) _redDepth = redDepth;
    if (blueDepth != null) _blueDepth = blueDepth;
    if (timeLimitSeconds != null) _timeLimitSeconds = timeLimitSeconds;
    if (animationDelayMs != null) _animationDelayMs = animationDelayMs;

    _state = GameState.initial(rows: boardSize.rows, cols: boardSize.cols);
    _phase = GamePhase.humanTurn;
    _aiIsThinking = false;
    _lastMoveRow = null;
    _lastMoveCol = null;
    _gameStartTime = DateTime.now();
    _durationSeconds = 0;
    notifyListeners();

    // If first player is AI, trigger it
    _triggerAIIfNeeded();
  }

  void resetGame() {
    startGame(
      mode: _mode,
      boardSize: _boardSize,
      redHeuristic: _redHeuristic,
      blueHeuristic: _blueHeuristic,
      redDepth: _redDepth,
      blueDepth: _blueDepth,
      timeLimitSeconds: _timeLimitSeconds,
      animationDelayMs: _animationDelayMs,
    );
  }

  /// Human places an orb — only valid during humanTurn phase.
  Future<void> humanMove(int row, int col) async {
    if (_phase != GamePhase.humanTurn) return;
    if (!_state.isValidMove(row, col, _state.currentPlayer)) return;

    _applyMove(row, col);

    if (!_state.isOver) {
      await _triggerAIIfNeeded();
    }
  }

  void _applyMove(int row, int col) {
    _lastMoveRow = row;
    _lastMoveCol = col;
    _state = ChainReactionEngine.makeMove(_state, row, col);
    _durationSeconds = DateTime.now().difference(_gameStartTime!).inSeconds;

    if (_state.isOver) {
      _phase = GamePhase.gameOver;
    } else {
      _phase = GamePhase.humanTurn;
    }
    notifyListeners();
  }

  Future<void> _triggerAIIfNeeded() async {
    if (_state.isOver) return;

    final isAITurn = _isAITurn(_state.currentPlayer);
    if (!isAITurn) return;

    _phase = GamePhase.aiThinking;
    _aiIsThinking = true;
    notifyListeners();

    // Small delay so UI can render the "AI thinking" state
    await Future.delayed(Duration(milliseconds: _animationDelayMs));

    final player = _state.currentPlayer;
    final heuristic = player == Player.red ? _redHeuristic : _blueHeuristic;
    final depth = player == Player.red ? _redDepth : _blueDepth;

    final args = AIArgs(
      state: _state,
      player: player,
      depth: depth,
      weights: heuristic.weights,
      timeLimitMs: (_timeLimitSeconds * 1000).toInt(),
    );

    try {
      final result = await computeAIMove(args);
      if (result.row >= 0) {
        _applyMove(result.row, result.col);
      }
    } catch (e) {
      debugPrint('AI error: $e');
    } finally {
      _aiIsThinking = false;
      notifyListeners();
    }

    // In AI vs AI, trigger the next AI too
    if (!_state.isOver && _mode == GameMode.aiVsAI) {
      await Future.delayed(Duration(milliseconds: _animationDelayMs));
      await _triggerAIIfNeeded();
    }
  }

  bool _isAITurn(Player player) {
    switch (_mode) {
      case GameMode.humanVsHuman:
        return false;
      case GameMode.humanVsAI:
        return player == Player.blue;
      case GameMode.aiVsAI:
        return true;
    }
  }

  // Settings update (no game restart)
  void updateSettings({
    HeuristicStrategy? redHeuristic,
    HeuristicStrategy? blueHeuristic,
    int? redDepth,
    int? blueDepth,
    double? timeLimitSeconds,
    int? animationDelayMs,
  }) {
    if (redHeuristic != null) _redHeuristic = redHeuristic;
    if (blueHeuristic != null) _blueHeuristic = blueHeuristic;
    if (redDepth != null) _redDepth = redDepth;
    if (blueDepth != null) _blueDepth = blueDepth;
    if (timeLimitSeconds != null) _timeLimitSeconds = timeLimitSeconds;
    if (animationDelayMs != null) _animationDelayMs = animationDelayMs;
    notifyListeners();
  }
}
