// models/task_model.dart

import 'package:flutter/material.dart';

class Task {
  int? id; // Add an ID field
  String name;
  DateTime startTime;
  DateTime endTime;
  Color color;

  Task({
    this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'color': color.value,
    };
  }

  static Task fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      name: map['name'],
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      color: Color(map['color']),
    );
  }
}