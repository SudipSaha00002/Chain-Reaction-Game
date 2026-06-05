import 'package:flutter_test/flutter_test.dart';
import 'package:chain_reaction_game/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ChainReactionApp());
  });
}
