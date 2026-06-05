import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_record.dart';

class StorageService {
  static const _historyKey = 'game_history';
  static const _settingsKey = 'game_settings';

  // ── Game History ────────────────────────────────────────────────

  static Future<List<GameRecord>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_historyKey) ?? [];
    return raw
        .map((s) => GameRecord.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  static Future<void> saveRecord(GameRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_historyKey) ?? [];
    existing.insert(0, jsonEncode(record.toJson())); // most recent first
    // Keep max 100 records
    if (existing.length > 100) existing.removeLast();
    await prefs.setStringList(_historyKey, existing);
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  // ── Settings ────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_settingsKey);
    if (raw == null) return {};
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  static Future<void> saveSettings(Map<String, dynamic> settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(settings));
  }
}
