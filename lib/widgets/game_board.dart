import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../config/game_config.dart';
import 'game_cell.dart';

/// The full game board rendered as a grid.
class GameBoard extends StatelessWidget {
  const GameBoard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final state = provider.state;
    final phase = provider.phase;
    final enabled = phase == GamePhase.humanTurn;

    return AspectRatio(
      aspectRatio: state.cols / state.rows,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF243049), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 32,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: state.cols,
            ),
            itemCount: state.rows * state.cols,
            itemBuilder: (context, index) {
              final row = index ~/ state.cols;
              final col = index % state.cols;
              final cell = state.board[row][col];
              final isLast =
                  provider.lastMoveRow == row && provider.lastMoveCol == col;

              // In human vs AI: disable tapping on AI's turn or opponent's cells
              bool canTap = enabled;
              if (canTap && provider.mode == GameMode.humanVsAI) {
                canTap = state.currentPlayer == Player.red;
              }

              return GameCell(
                cell: cell,
                row: row,
                col: col,
                rows: state.rows,
                cols: state.cols,
                isLastMove: isLast,
                enabled: canTap,
                onTap: () => provider.humanMove(row, col),
              );
            },
          ),
        ),
      ),
    );
  }
}
