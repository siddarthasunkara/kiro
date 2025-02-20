import 'dart:io'; // Required for platform checks
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:kiro/screens/home_screen.dart';
import 'package:kiro/screens/habit_tracker_screen.dart';

import 'package:sqflite/sqflite.dart'; // Core Sqflite package
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // Desktop database support
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart'; // Web database support

import 'package:kiro/models/pomodoro_model.dart' as pomodoro; // Alias for Pomodoro model
import 'package:kiro/models/eisenhower_task_model.dart' as eisenhower; // Alias for Eisenhower model

Future<void> main() async {
  // Ensure that Flutter is initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();

  // Select the correct database factory based on the platform
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb; // Web support
  } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit(); // Initialize for desktop
    databaseFactory = databaseFactoryFfi; // Use FFI for desktop
  } else {
    databaseFactory = databaseFactory; // Default for Android & iOS
  }

  runApp(KiroApp());
}

class KiroApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kiro',
      theme: ThemeData.light().copyWith(
        primaryColor: Color(0xFFff7300),
        scaffoldBackgroundColor: Colors.white,
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: Color(0xFFff7300),
        scaffoldBackgroundColor: Color(0xFF222222),
      ),
      themeMode: ThemeMode.system,
      home: HomeScreen(),
    );
  }
}
