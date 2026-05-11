import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './services/storage_service.dart';
import './services/vibration_service.dart';
import './providers/game_provider.dart';
import './providers/theme_provider.dart';
import './components/level_select.dart';
import './screens/game_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  StorageService storageService = StorageService();
  await storageService.init();
  
  ThemeProvider themeProvider = ThemeProvider(storageService);
  await themeProvider.init();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => themeProvider),
        ChangeNotifierProvider(
          create: (_) => GameProvider(storageService, VibrationService()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int? _selectedGridSize;

  @override
  Widget build(BuildContext context) {
    ThemeProvider themeProvider = Provider.of<ThemeProvider>(context);
    GameProvider gameProvider = Provider.of<GameProvider>(context);
    
    return MaterialApp(
      title: '2048',
      theme: themeProvider.themeData,
      darkTheme: ThemeProvider._darkTheme,
      themeMode: themeProvider.themeMode,
      home: _selectedGridSize == null
          ? LevelSelect(
              onLevelSelected: (size) {
                gameProvider.setGridSize(size);
                setState(() => _selectedGridSize = size);
              },
              isDarkMode: themeProvider.themeMode == ThemeMode.dark,
            )
          : GameScreen(gridSize: _selectedGridSize!),
    );
  }
}