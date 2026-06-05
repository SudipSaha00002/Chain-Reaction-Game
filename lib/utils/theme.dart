import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // ── Background ─────────────────────────────────────────────────
  static const Color bgDark = Color(0xFF0A0E1A);
  static const Color bgCard = Color(0xFF111827);
  static const Color bgSurface = Color(0xFF1A2234);
  static const Color bgBorder = Color(0xFF243049);

  // ── Text ───────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFEEF2FF);
  static const Color textSecondary = Color(0xFF8B9EC7);
  static const Color textMuted = Color(0xFF4A5880);

  // ── Accent ─────────────────────────────────────────────────────
  static const Color accent = Color(0xFF6C63FF);
  static const Color accentGlow = Color(0x556C63FF);

  // ── Red Player ─────────────────────────────────────────────────
  static const Color red = Color(0xFFFF4757);
  static const Color redGlow = Color(0x55FF4757);

  // ── Blue Player ────────────────────────────────────────────────
  static const Color blue = Color(0xFF2F86EB);
  static const Color blueGlow = Color(0x552F86EB);

  // ── Gradients ──────────────────────────────────────────────────
  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0A0E1A), Color(0xFF0D1526), Color(0xFF111827)],
  );

  static const LinearGradient redGradient = LinearGradient(
    colors: [Color(0xFFFF4757), Color(0xFFFF6B81)],
  );

  static const LinearGradient blueGradient = LinearGradient(
    colors: [Color(0xFF2F86EB), Color(0xFF54A0FF)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF8A84FF)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A2234), Color(0xFF111827)],
  );

  // ── Shadows ────────────────────────────────────────────────────
  static List<BoxShadow> redShadow = [
    BoxShadow(color: red.withValues(alpha: 0.4), blurRadius: 16, spreadRadius: 2),
  ];

  static List<BoxShadow> blueShadow = [
    BoxShadow(color: blue.withValues(alpha: 0.4), blurRadius: 16, spreadRadius: 2),
  ];

  static List<BoxShadow> accentShadow = [
    BoxShadow(color: accent.withValues(alpha: 0.3), blurRadius: 12, spreadRadius: 1),
  ];

  static List<BoxShadow> cardShadow = [
    BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8)),
  ];

  // ── ThemeData ──────────────────────────────────────────────────
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bgDark,
        colorScheme: const ColorScheme.dark(
          primary: accent,
          secondary: blue,
          surface: bgCard,
          error: red,
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
          displayLarge: GoogleFonts.rajdhani(
            fontSize: 48,
            fontWeight: FontWeight.w700,
            color: textPrimary,
            letterSpacing: 2,
          ),
          displayMedium: GoogleFonts.rajdhani(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
          headlineLarge: GoogleFonts.rajdhani(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          headlineMedium: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          bodyLarge: GoogleFonts.inter(
            fontSize: 16,
            color: textPrimary,
          ),
          bodyMedium: GoogleFonts.inter(
            fontSize: 14,
            color: textSecondary,
          ),
          labelLarge: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textPrimary,
            letterSpacing: 0.5,
          ),
        ),
        cardTheme: CardThemeData(
          color: bgCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: bgBorder, width: 1),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: textPrimary,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ),
        sliderTheme: const SliderThemeData(
          activeTrackColor: accent,
          inactiveTrackColor: bgBorder,
          thumbColor: accent,
          overlayColor: accentGlow,
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? accent : bgBorder,
          ),
          trackColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? accentGlow : bgSurface,
          ),
        ),
      );
}
