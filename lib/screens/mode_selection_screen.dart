import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../config/game_config.dart';
import '../providers/game_provider.dart';
import '../utils/theme.dart';
import '../widgets/cr_app_bar.dart';
import 'game_screen.dart';

class ModeSelectionScreen extends StatefulWidget {
  const ModeSelectionScreen({super.key});

  @override
  State<ModeSelectionScreen> createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen> {
  GameMode _selectedMode = GameMode.humanVsAI;
  BoardSize _boardSize = BoardSize.medium;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              const CRAppBar(title: 'SELECT MODE'),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      const SectionLabel('Game Mode'),
                      const SizedBox(height: 12),
                      ...GameMode.values.map((mode) => _ModeCard(
                            mode: mode,
                            isSelected: _selectedMode == mode,
                            onTap: () => setState(() => _selectedMode = mode),
                          )),
                      const SizedBox(height: 28),
                      const SectionLabel('Board Size'),
                      const SizedBox(height: 12),
                      Row(
                        children: BoardSize.values.map((size) {
                          final selected = _boardSize == size;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _boardSize = size),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  gradient: selected
                                      ? AppTheme.accentGradient
                                      : AppTheme.cardGradient,
                                  border: Border.all(
                                    color: selected
                                        ? AppTheme.accent
                                        : AppTheme.bgBorder,
                                  ),
                                ),
                                child: Text(
                                  size.label,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    color: selected
                                        ? Colors.white
                                        : AppTheme.textSecondary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 40),
                      _StartButton(
                        mode: _selectedMode,
                        boardSize: _boardSize,
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.mode,
    required this.isSelected,
    required this.onTap,
  });

  final GameMode mode;
  final bool isSelected;
  final VoidCallback onTap;

  IconData get _icon {
    switch (mode) {
      case GameMode.humanVsHuman:
        return Icons.people_alt_rounded;
      case GameMode.humanVsAI:
        return Icons.person_outline_rounded;
      case GameMode.aiVsAI:
        return Icons.memory_rounded;
    }
  }

  String get _description {
    switch (mode) {
      case GameMode.humanVsHuman:
        return 'Two players on same device. Red goes first.';
      case GameMode.humanVsAI:
        return 'Play as Red against the AI (Blue). Configure AI in Settings.';
      case GameMode.aiVsAI:
        return 'Watch two AI agents battle with configurable strategies.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    AppTheme.accent.withValues(alpha: 0.25),
                    AppTheme.accent.withValues(alpha: 0.1),
                  ],
                )
              : AppTheme.cardGradient,
          border: Border.all(
            color: isSelected ? AppTheme.accent : AppTheme.bgBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: isSelected
                    ? AppTheme.accent.withValues(alpha: 0.2)
                    : AppTheme.bgSurface,
              ),
              child: Icon(
                _icon,
                color: isSelected ? AppTheme.accent : AppTheme.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mode.label,
                    style: GoogleFonts.inter(
                      color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _description,
                    style: GoogleFonts.inter(
                      color: AppTheme.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppTheme.accent, size: 20),
          ],
        ),
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  const _StartButton({required this.mode, required this.boardSize});
  final GameMode mode;
  final BoardSize boardSize;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final provider = context.read<GameProvider>();
        provider.startGame(mode: mode, boardSize: boardSize);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const GameScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: AppTheme.accentGradient,
          boxShadow: [
            BoxShadow(
              color: AppTheme.accent.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              'START GAME',
              style: GoogleFonts.rajdhani(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

