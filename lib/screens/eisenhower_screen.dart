import 'package:flutter/material.dart';
import '../models/eisenhower_task_model.dart';
import '../models/categories.dart';
import '../widgets/add_task_dialog.dart';
import '../widgets/quadrant_widget.dart';
import '../database_helper.dart';

class EisenhowerMatrixScreen extends StatefulWidget {
  const EisenhowerMatrixScreen({super.key});

  @override
  _EisenhowerMatrixScreenState createState() => _EisenhowerMatrixScreenState();
}

class _EisenhowerMatrixScreenState extends State<EisenhowerMatrixScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final Map<String, List<EisenhowerTask>> tasks = {
    Categories.urgentImportant: [],
    Categories.notUrgentImportant: [],
    Categories.urgentNotImportant: [],
    Categories.notUrgentNotImportant: [],
  };

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    tasks.forEach((key, value) => value.clear());
    List<EisenhowerTask> dbTasks = await _dbHelper.getEisenhowerTasks();
    for (var task in dbTasks) {
      tasks[task.category]?.add(task);
    }
    setState(() {});
  }

  Future<void> _addTask(String category, EisenhowerTask task) async {
    await _dbHelper.insertEisenhowerTask(task);
    await _loadTasks();
  }

  Future<void> _updateTaskCompletion(String category, int index, bool isCompleted) async {
    EisenhowerTask task = tasks[category]![index];
    task.isCompleted = isCompleted;
    await _dbHelper.updateEisenhowerTask(task);
    setState(() {});
  }

  Future<void> _deleteTask(String category, int index) async {
    EisenhowerTask task = tasks[category]![index];
    await _dbHelper.deleteEisenhowerTask(task.id!);
    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eisenhower Matrix', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF1A1E3B), // Deep Navy Blue for AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Card(
                      elevation: 4,
                      color: Color(0xFF5F4B8B), // Muted Purple for the card background
                      child: QuadrantWidget(
                        title: 'Urgent & Important',
                        tasks: tasks[Categories.urgentImportant]!,
                        color: Color(0xFF00A676), // Vibrant Emerald Green for quadrant color
                        onAddTask: () => _showAddTaskDialog(Categories.urgentImportant),
                        onTaskComplete: (index, isCompleted) => _updateTaskCompletion(Categories.urgentImportant, index, isCompleted),
                        onTaskDelete: (index) => _deleteTask(Categories.urgentImportant, index),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Card(
                      elevation: 4,
                      color: Color(0xFF5F4B8B), // Muted Purple for the card background
                      child: QuadrantWidget(
                        title: 'Not Urgent & Important',
                        tasks: tasks[Categories.notUrgentImportant]!,
                        color: Color(0xFF00A676), // Vibrant Emerald Green for quadrant color
                        onAddTask: () => _showAddTaskDialog(Categories.notUrgentImportant),
                        onTaskComplete: (index, isCompleted) => _updateTaskCompletion(Categories.notUrgentImportant, index, isCompleted),
                        onTaskDelete: (index) => _deleteTask(Categories.notUrgentImportant, index),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Card(
                      elevation: 4,
                      color: Color(0xFF5F4B8B), // Muted Purple for the card background
                      child: QuadrantWidget(
                        title: 'Urgent & Not Important',
                        tasks: tasks[Categories.urgentNotImportant]!,
                        color: Color(0xFF00A676), // Vibrant Emerald Green for quadrant color
                        onAddTask: () => _showAddTaskDialog(Categories.urgentNotImportant),
                        onTaskComplete: (index, isCompleted) => _updateTaskCompletion(Categories.urgentNotImportant, index, isCompleted),
                        onTaskDelete: (index) => _deleteTask(Categories.urgentNotImportant, index),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Card(
                      elevation: 4,
                      color: Color(0xFF5F4B8B), // Muted Purple for the card background
                      child: QuadrantWidget(
                        title: 'Not Urgent & Not Important',
                        tasks: tasks[Categories.notUrgentNotImportant]!,
                        color: Color(0xFF00A676), // Vibrant Emerald Green for quadrant color
                        onAddTask: () => _showAddTaskDialog(Categories.notUrgentNotImportant),
                        onTaskComplete: (index, isCompleted) => _updateTaskCompletion(Categories.notUrgentNotImportant, index, isCompleted),
                        onTaskDelete: (index) => _deleteTask(Categories.notUrgentNotImportant, index),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(Categories.urgentImportant), // Default to adding to the first category
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor: Color(0xFF00A676), // Vibrant Emerald Green for the floating action button
      ),
    );
  }

  void _showAddTaskDialog(String category) {
    showDialog(
      context: context,
      builder: (_) => AddTaskDialog(
        category: category,
        onAddTask: (task) => _addTask(category, task),
      ),
    );
  }
}