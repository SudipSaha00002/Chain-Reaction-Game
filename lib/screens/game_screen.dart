import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/history_provider.dart';
import '../models/game_record.dart';
import '../utils/theme.dart';
import '../widgets/game_board.dart';
import '../widgets/player_indicator.dart';
import 'result_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _resultShown = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: Consumer<GameProvider>(
            builder: (context, provider, _) {
              // Check for game over
              if (provider.state.isOver && !_resultShown) {
                _resultShown = true;
                WidgetsBinding.instance.addPostFrameCallback((_) => _onGameOver(provider));
              }
              if (!provider.state.isOver) {
                _resultShown = false;
              }

              return Column(
                children: [
                  // Top bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close_rounded,
                              color: AppTheme.textSecondary),
                          onPressed: () => _confirmQuit(context),
                        ),
                        Expanded(
                          child: Text(
                            provider.mode.label.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.rajdhani(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        _MoveCounter(moves: provider.state.moveCount),
                        IconButton(
                          icon: const Icon(Icons.refresh_rounded,
                              color: AppTheme.textSecondary),
                          onPressed: () => _confirmRestart(context, provider),
                        ),
                      ],
                    ),
                  ),

                  // Player indicator
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: const PlayerIndicator(),
                  ),

                  // Board
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: const GameBoard(),
                      ),
                    ),
                  ),

                  // Status bar
                  _StatusBar(provider: provider),
                  const SizedBox(height: 8),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _onGameOver(GameProvider provider) async {
    // Save history
    final record = GameRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      mode: provider.mode,
      winner: provider.state.winner,
      moveCount: provider.state.moveCount,
      durationSeconds: provider.durationSeconds,
      timestamp: DateTime.now(),
      rows: provider.state.rows,
      cols: provider.state.cols,
      redHeuristic: provider.redHeuristic,
      blueHeuristic: provider.blueHeuristic,
      redDepth: provider.redDepth,
      blueDepth: provider.blueDepth,
    );
    await context.read<HistoryProvider>().addRecord(record);

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          winner: provider.state.winner,
          moveCount: provider.state.moveCount,
          durationSeconds: provider.durationSeconds,
          mode: provider.mode,
        ),
      ),
    );
  }

  void _confirmQuit(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Quit Game?',
            style: GoogleFonts.inter(color: AppTheme.textPrimary)),
        content: Text('Your progress will be lost.',
            style: GoogleFonts.inter(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.inter(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.popUntil(context, (r) => r.isFirst);
            },
            child: Text('Quit', style: GoogleFonts.inter(color: AppTheme.red)),
          ),
        ],
      ),
    );
  }

  void _confirmRestart(BuildContext context, GameProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Restart?',
            style: GoogleFonts.inter(color: AppTheme.textPrimary)),
        content: Text('Start a new game with same settings.',
            style: GoogleFonts.inter(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.inter(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              provider.resetGame();
            },
            child: Text('Restart', style: GoogleFonts.inter(color: AppTheme.accent)),
          ),
        ],
      ),
    );
  }
}

class _MoveCounter extends StatelessWidget {
  const _MoveCounter({required this.moves});
  final int moves;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.bgBorder),
      ),
      child: Text(
        'Move $moves',
        style: GoogleFonts.rajdhani(
          color: AppTheme.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.provider});
  final GameProvider provider;

  @override
  Widget build(BuildContext context) {
    final isAI = provider.aiIsThinking;
    final player = provider.state.currentPlayer;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: isAI
            ? AppTheme.accent.withValues(alpha: 0.1)
            : player.color.withValues(alpha: 0.08),
        border: Border.all(
          color: isAI
              ? AppTheme.accent.withValues(alpha: 0.3)
              : player.color.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isAI ? Icons.memory_rounded : Icons.touch_app_rounded,
            color: isAI ? AppTheme.accent : player.color,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            isAI
                ? 'AI is thinking...'
                : '${player.name}\'s turn — tap a cell',
            style: GoogleFonts.inter(
              color: isAI ? AppTheme.accent : player.color,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
