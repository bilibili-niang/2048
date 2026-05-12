import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:game2048/providers/game_provider.dart';
import 'package:game2048/providers/theme_provider.dart';
import 'package:game2048/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => GameProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
              title: '2048 Game',
              theme: themeProvider.isDarkMode ? ThemeData.dark() : ThemeData.light(),
              home: const HomeScreen(),
              debugShowCheckedModeBanner: false,
            );
          },
      ),
    );
  }
}
