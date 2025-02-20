import 'package:flutter/material.dart';
import '../models/pomodoro_model.dart';

class TaskCard extends StatelessWidget {
  final PomodoroTask task;
  final VoidCallback onTap;

  const TaskCard({
    Key? key,
    required this.task,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Color(0xFF5F4B8B).withOpacity(0.8), // Muted Purple with slight transparency
      elevation: 3,
      child: ListTile(
        title: Text(
          task.title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white), // White text for title
        ),
        subtitle: Text(
          '${task.completedPomodoros}/${task.estimatedPomodoros} Pomodoros',
          style: TextStyle(color: Color(0xFFB0B0B0)), // Light Gray for subtitle
        ),
        onTap: onTap,
      ),
    );
  }
}