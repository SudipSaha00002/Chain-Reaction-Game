import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/game_record.dart';
import '../providers/history_provider.dart';
import '../utils/theme.dart';
import '../widgets/cr_app_bar.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<HistoryProvider>().load(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Row(
                  children: [
                    Expanded(child: const CRAppBar(title: 'HISTORY')),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded,
                          color: AppTheme.textMuted),
                      onPressed: () => _confirmClear(context),
                      tooltip: 'Clear history',
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Consumer<HistoryProvider>(
                  builder: (_, history, __) {
                    if (!history.loaded) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppTheme.accent),
                      );
                    }
                    if (history.records.isEmpty) {
                      return _EmptyState();
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: history.records.length,
                      itemBuilder: (_, i) => _HistoryTile(record: history.records[i]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Clear History?',
            style: GoogleFonts.inter(color: AppTheme.textPrimary)),
        content: Text('This action cannot be undone.',
            style: GoogleFonts.inter(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.inter(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              context.read<HistoryProvider>().clearHistory();
              Navigator.pop(context);
            },
            child: Text('Clear',
                style: GoogleFonts.inter(color: AppTheme.red)),
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.record});
  final GameRecord record;

  @override
  Widget build(BuildContext context) {
    final winner = record.winner;
    final winnerColor = winner?.color ?? AppTheme.accent;
    final winnerLabel = winner == null ? 'Draw' : '${winner.name} Won';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: AppTheme.cardGradient,
        border: Border.all(
          color: winnerColor.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Winner orb
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: winnerColor.withValues(alpha: 0.15),
              border: Border.all(color: winnerColor.withValues(alpha: 0.4)),
            ),
            child: Icon(
              winner == null ? Icons.handshake_outlined : Icons.emoji_events_rounded,
              color: winnerColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      winnerLabel,
                      style: GoogleFonts.inter(
                        color: winnerColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.bgSurface,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        record.mode.label,
                        style: GoogleFonts.inter(
                          color: AppTheme.textMuted,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${record.moveCount} moves • '
                  '${record.rows}×${record.cols} board • '
                  '${_formatDate(record.timestamp)}',
                  style: GoogleFonts.inter(
                    color: AppTheme.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          // Duration
          Text(
            _formatDuration(record.durationSeconds),
            style: GoogleFonts.rajdhani(
              color: AppTheme.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  String _formatDuration(int s) {
    if (s < 60) return '${s}s';
    return '${s ~/ 60}m ${s % 60}s';
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, color: AppTheme.textMuted, size: 64),
          const SizedBox(height: 16),
          Text(
            'No games yet',
            style: GoogleFonts.inter(
              color: AppTheme.textMuted,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Play a game to see it here!',
            style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
