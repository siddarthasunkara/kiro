// models/habit_model.dart

import 'priority_level.dart';

class Habit {
  final String id;
  late final String name;
  List<bool> completedDays;
  int targetDays;
  PriorityLevel priority;

  Habit({
    required this.id,
    required this.name,
    required int daysInMonth,
    List<bool>? completedDays,
    this.targetDays = 20,
    this.priority = PriorityLevel.medium,
  }) : completedDays = completedDays ?? List.generate(daysInMonth, (_) => false);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'completedDays': completedDays.join(','), // Store as a comma-separated string
      'targetDays': targetDays,
      'priority': priority.index,
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'],
      name: map['name'],
      daysInMonth: map['completedDays'].split(',').length, // Get the number of days
      completedDays: map['completedDays']
          .split(',')
          .map((e) => e.trim() == 'true') // Convert to bool
          .toList()
          .cast<bool>(), // Ensure the list is of type List<bool>
      targetDays: map['targetDays'],
      priority: PriorityLevel.values[map['priority']],
    );
  }
  void resetForNextMonth(int daysInMonth) {
    completedDays = List.generate(daysInMonth, (_) => false);
  }

  int get currentStreak {
    int streak = 0;
    for (int i = completedDays.length - 1; i >= 0; i--) {
      if (completedDays[i]) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  double get completionPercentage {
    int completedCount = completedDays.where((day) => day).length;
    return (completedCount / completedDays.length) * 100;
  }
}