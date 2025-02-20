import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/eisenhower_task_model.dart';

class QuadrantWidget extends StatelessWidget {
  final String title;
  final List<EisenhowerTask> tasks;
  final Color color;
  final VoidCallback onAddTask;
  final Function(int, bool) onTaskComplete;
  final Function(int) onTaskDelete;

  const QuadrantWidget({
    Key? key,
    required this.title,
    required this.tasks,
    required this.color,
    required this.onAddTask,
    required this.onTaskComplete,
    required this.onTaskDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1), // Softened color for background
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quadrant Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: color, // Use the provided color for the header
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add, color: Colors.white),
                    onPressed: onAddTask,
                  ),
                ],
              ),
            ),

            // Task List
            Expanded(
              child: tasks.isEmpty
                  ? Center(
                child: Text(
                  'No tasks',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              )
                  : ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];

                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: task.isCompleted
                          ? Color(0xFF292929).withOpacity(0.8) // Darker background for completed tasks
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: task.isCompleted,
                          onChanged: (value) {
                            if (value != null) {
                              onTaskComplete(index, value);
                            }
                          },
                          activeColor: Color(0xFF00A676), // Vibrant Emerald Green for checkbox
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task.title,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: task.isCompleted ? Colors.white70 : Colors.white,
                                  decoration: task.isCompleted
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                ),
                              ),
                              if (task.deadline != null)
                                Text(
                                  'Deadline: ${DateFormat.yMMMd().format(task.deadline!)}',
                                  style: TextStyle(fontSize: 12, color: Color(0xFFE07A5F)), // Muted Orange
                                ),
                              if (task.notes != null && task.notes!.isNotEmpty)
                                Text(
                                  'Notes: ${task.notes}',
                                  style: TextStyle(fontSize: 12, color: Colors.white70),
                                ),
                            ],
                          ),
                        ),
                        if (task.isCompleted)
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => onTaskDelete(index),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}