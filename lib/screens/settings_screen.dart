import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../config/game_config.dart';
import '../providers/game_provider.dart';
import '../utils/theme.dart';
import '../widgets/cr_app_bar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late HeuristicStrategy _redHeuristic;
  late HeuristicStrategy _blueHeuristic;
  late double _redDepth;
  late double _blueDepth;
  late double _timeLimit;
  late double _animDelay;

  @override
  void initState() {
    super.initState();
    final p = context.read<GameProvider>();
    _redHeuristic = p.redHeuristic;
    _blueHeuristic = p.blueHeuristic;
    _redDepth = p.redDepth.toDouble();
    _blueDepth = p.blueDepth.toDouble();
    _timeLimit = p.timeLimitSeconds;
    _animDelay = p.animationDelayMs.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              const CRAppBar(title: 'SETTINGS'),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      _SettingsCard(
                        title: 'Red Player (Player 1)',
                        color: AppTheme.red,
                        children: [
                          _HeuristicDropdown(
                            value: _redHeuristic,
                            onChanged: (v) => setState(() => _redHeuristic = v),
                          ),
                          const SizedBox(height: 16),
                          _SliderRow(
                            label: 'Search Depth',
                            value: _redDepth,
                            min: 1,
                            max: 5,
                            divisions: 4,
                            onChanged: (v) => setState(() => _redDepth = v),
                            format: (v) => v.round().toString(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _SettingsCard(
                        title: 'Blue Player (AI)',
                        color: AppTheme.blue,
                        children: [
                          _HeuristicDropdown(
                            value: _blueHeuristic,
                            onChanged: (v) => setState(() => _blueHeuristic = v),
                          ),
                          const SizedBox(height: 16),
                          _SliderRow(
                            label: 'Search Depth',
                            value: _blueDepth,
                            min: 1,
                            max: 5,
                            divisions: 4,
                            onChanged: (v) => setState(() => _blueDepth = v),
                            format: (v) => v.round().toString(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _SettingsCard(
                        title: 'Performance',
                        color: AppTheme.accent,
                        children: [
                          _SliderRow(
                            label: 'AI Time Limit',
                            value: _timeLimit,
                            min: 1,
                            max: 15,
                            divisions: 14,
                            onChanged: (v) => setState(() => _timeLimit = v),
                            format: (v) => '${v.round()}s',
                          ),
                          const SizedBox(height: 16),
                          _SliderRow(
                            label: 'Move Delay',
                            value: _animDelay,
                            min: 0,
                            max: 1000,
                            divisions: 10,
                            onChanged: (v) => setState(() => _animDelay = v),
                            format: (v) => '${v.round()}ms',
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Heuristic info cards
                      const SectionLabel('HEURISTIC GUIDE'),
                      const SizedBox(height: 12),
                      ...HeuristicStrategy.values.map((h) => _HeuristicInfoTile(h)),
                      const SizedBox(height: 32),
                      _SaveButton(onSave: _save),
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

  void _save() {
    context.read<GameProvider>().updateSettings(
          redHeuristic: _redHeuristic,
          blueHeuristic: _blueHeuristic,
          redDepth: _redDepth.round(),
          blueDepth: _blueDepth.round(),
          timeLimitSeconds: _timeLimit,
          animationDelayMs: _animDelay.round(),
        );
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Settings saved!', style: GoogleFonts.inter()),
        backgroundColor: AppTheme.accent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.title,
    required this.color,
    required this.children,
  });

  final String title;
  final Color color;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: AppTheme.cardGradient,
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  boxShadow: [BoxShadow(color: color, blurRadius: 6)],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.inter(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}

class _HeuristicDropdown extends StatelessWidget {
  const _HeuristicDropdown({required this.value, required this.onChanged});
  final HeuristicStrategy value;
  final ValueChanged<HeuristicStrategy> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Heuristic Strategy',
          style: GoogleFonts.inter(
            color: AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.bgSurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.bgBorder),
          ),
          child: DropdownButton<HeuristicStrategy>(
            value: value,
            isExpanded: true,
            dropdownColor: AppTheme.bgCard,
            underline: const SizedBox(),
            style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 14),
            onChanged: (v) => v != null ? onChanged(v) : null,
            items: HeuristicStrategy.values
                .map((h) => DropdownMenuItem(
                      value: h,
                      child: Text(h.label),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
    required this.format,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;
  final String Function(double) format;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Slider(
                value: value,
                min: min,
                max: max,
                divisions: divisions,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 44,
          alignment: Alignment.center,
          child: Text(
            format(value),
            style: GoogleFonts.rajdhani(
              color: AppTheme.accent,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}

class _HeuristicInfoTile extends StatelessWidget {
  const _HeuristicInfoTile(this.h);
  final HeuristicStrategy h;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.bgBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  h.label,
                  style: GoogleFonts.inter(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  h.description,
                  style: GoogleFonts.inter(
                    color: AppTheme.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.onSave});
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSave,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: AppTheme.accentGradient,
          boxShadow: [
            BoxShadow(
              color: AppTheme.accent.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          'SAVE SETTINGS',
          textAlign: TextAlign.center,
          style: GoogleFonts.rajdhani(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}
