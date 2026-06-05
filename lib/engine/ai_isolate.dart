import 'package:flutter/foundation.dart';
import '../engine/ai_player.dart';

/// Runs the AI in a separate Dart isolate via Flutter's compute(),
/// preventing UI freezes during deep minimax searches.
Future<AIResult> computeAIMove(AIArgs args) async {
  return compute(runAI, args);
}
