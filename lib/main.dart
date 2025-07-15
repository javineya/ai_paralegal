import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/chat_screen.dart';
import 'utils/app_state.dart';

void main() {
  runApp(const AIParalegalApp());
}

class AIParalegalApp extends StatelessWidget {
  const AIParalegalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: Consumer<AppState>(
        builder: (context, appState, child) {
          // Use platform-specific themes
          if (Platform.isIOS) {
            return CupertinoApp(
              title: 'AI Paralegal',
              theme: CupertinoThemeData(
                primaryColor: CupertinoColors.systemBlue,
                brightness: appState.isDarkMode ? Brightness.dark : Brightness.light,
              ),
              home: const ChatScreen(),
              debugShowCheckedModeBanner: false,
            );
          } else {
            return MaterialApp(
              title: 'AI Paralegal',
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color(0xFF1976D2),
                ),
                useMaterial3: true,
                appBarTheme: const AppBarTheme(
                  centerTitle: false,
                  elevation: 0,
                ),
              ),
              darkTheme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color(0xFF1976D2),
                  brightness: Brightness.dark,
                ),
                useMaterial3: true,
                appBarTheme: const AppBarTheme(
                  centerTitle: false,
                  elevation: 0,
                ),
              ),
              themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
              home: const ChatScreen(),
              debugShowCheckedModeBanner: false,
            );
          }
        },
      ),
    );
  }
}
