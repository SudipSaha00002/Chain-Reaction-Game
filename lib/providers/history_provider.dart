import 'package:flutter/foundation.dart';
import '../models/game_record.dart';
import '../utils/storage_service.dart';

class HistoryProvider extends ChangeNotifier {
  List<GameRecord> _records = [];
  bool _loaded = false;

  List<GameRecord> get records => _records;
  bool get loaded => _loaded;

  Future<void> load() async {
    _records = await StorageService.loadHistory();
    _loaded = true;
    notifyListeners();
  }

  Future<void> addRecord(GameRecord record) async {
    _records.insert(0, record);
    notifyListeners();
    await StorageService.saveRecord(record);
  }

  Future<void> clearHistory() async {
    _records = [];
    notifyListeners();
    await StorageService.clearHistory();
  }
}
