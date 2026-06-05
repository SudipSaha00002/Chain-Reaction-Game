import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/game_provider.dart';
import 'providers/history_provider.dart';
import 'screens/title_screen.dart';
import 'utils/theme.dart';

void main() {
  runApp(const ChainReactionApp());
}

class ChainReactionApp extends StatelessWidget {
  const ChainReactionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
      ],
      child: MaterialApp(
        title: 'Chain Reaction',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const TitleScreen(),
      ),
    );
  }
}
