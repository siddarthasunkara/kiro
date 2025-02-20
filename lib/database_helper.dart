// lib/database_helper.dart

import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models/task_model.dart'; // Import your Task model
import '../models/pomodoro_model.dart'; // Import your PomodoroTask model
import '../models/habit_model.dart'; // Import your Habit model
import '../models/eisenhower_task_model.dart'; // Import your EisenhowerTask model

class DatabaseHelper {
  // Singleton instance
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  /// Get the database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  /// Initialize the database
  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'app_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await _createTaskTable(db);
        await _createHabitTable(db);
        await _createPomodoroTaskTable(db);
        await _createEisenhowerTaskTable(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < newVersion) {
          // Example upgrade logic: Alter table, add new columns, etc.
          await db.execute("ALTER TABLE habits ADD COLUMN description TEXT");
        }
      },
    );
  }

  /// Create `tasks` table
  Future<void> _createTaskTable(Database db) async {
    await db.execute('''
      CREATE TABLE tasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        startTime TEXT,
        endTime TEXT,
        color INTEGER
      )
    ''');
  }

  /// Create `habits` table
  Future<void> _createHabitTable(Database db) async {
    await db.execute('''
      CREATE TABLE habits(
        id TEXT PRIMARY KEY,
        name TEXT,
        completedDays TEXT,
        targetDays INTEGER,
        priority INTEGER
      )
    ''');
  }

  /// Create `eisenhower_tasks` table
  Future<void> _createEisenhowerTaskTable(Database db) async {
    await db.execute('''
    CREATE TABLE eisenhower_tasks (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT,
      notes TEXT,
      deadline INTEGER,
      isCompleted INTEGER,
      category TEXT
    )
  ''');
  }

  /// Create `pomodoro_tasks` table
  Future<void> _createPomodoroTaskTable(Database db) async {
    await db.execute('''
      CREATE TABLE pomodoro_tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        estimatedPomodoros INTEGER,
        completedPomodoros INTEGER
      )
    ''');
  }

  // Task methods
  Future<void> insertTask(Task task) async {
    final db = await database;
    await db.insert(
      'tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Task>> getTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tasks');
    return List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
  }

  Future<void> updateTask(Task task) async {
    final db = await database;
    await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<void> deleteTask(int id) async {
    final db = await database;
    await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Habit methods
  Future<void> insertHabit(Habit habit) async {
    final db = await database;
    await db.insert(
      'habits',
      habit.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Habit>> getHabits() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('habits');

    return List.generate(maps.length, (i) {
      return Habit.fromMap(maps[i]);
    });
  }

  Future<void> updateHabit(Habit habit) async {
    final db = await database;
    await db.update(
      'habits',
      habit.toMap(),
      where: 'id = ?',
      whereArgs: [habit.id],
    );
  }

  Future<void> deleteHabit(String id) async {
    final db = await database;
    await db.delete(
      'habits',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Eisenhower Task methods
  Future<void> insertEisenhowerTask(EisenhowerTask task) async {
    final db = await database;
    await db.insert(
      'eisenhower_tasks',
      {
        'title': task.title,
        'notes': task.notes,
        'deadline': task.deadline?.millisecondsSinceEpoch, // Convert DateTime to int
        'isCompleted': task.isCompleted ? 1 : 0,
        'category': task.category,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<EisenhowerTask>> getEisenhowerTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('eisenhower_tasks');

    return List.generate(maps.length, (i) {
      return EisenhowerTask(
        id: maps[i]['id'],
        title: maps[i]['title'],
        notes: maps[i]['notes'],
        deadline: maps[i]['deadline'] != null
            ? DateTime.fromMillisecondsSinceEpoch(maps[i]['deadline'])
            : null,
        isCompleted: maps[i]['isCompleted'] == 1,
        category: maps[i]['category'],
      );
    });
  }

  Future<void> updateEisenhowerTask(EisenhowerTask task) async {
    final db = await database;
    await db.update(
      'eisenhower_tasks',
      {
        'title': task.title,
        'isCompleted': task.isCompleted ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<void> deleteEisenhowerTask(int id) async {
    final db = await database;
    await db.delete('eisenhower_tasks', where: 'id = ?', whereArgs: [id]);
  }

  // Pomodoro Task methods
  Future<void> insertPomodoroTask(PomodoroTask task) async {
    final db = await database;
    await db.insert(
      'pomodoro_tasks',
      {
        'title': task.title,
        'estimatedPomodoros': task.estimatedPomodoros,
        'completedPomodoros': task.completedPomodoros,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<PomodoroTask>> getPomodoroTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('pomodoro_tasks');

    return List.generate(maps.length, (i) {
      return PomodoroTask(
        id: maps[i]['id'],
        title: maps[i]['title'],
        estimatedPomodoros: maps[i]['estimatedPomodoros'],
        completedPomodoros: maps[i]['completedPomodoros'],
      );
    });
  }

  Future<void> updatePomodoroTask(PomodoroTask task) async {
    final db = await database;
    await db.update(
      'pomodoro_tasks',
      {
        'title': task.title,
        'estimatedPomodoros': task.estimatedPomodoros,
        'completedPomodoros': task.completedPomodoros,
      },
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<void> deletePomodoroTask(int id) async {
    final db = await database;
    await db.delete('pomodoro_tasks', where: 'id = ?', whereArgs: [id]);
  }

  /// Close Database
  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
  }
}