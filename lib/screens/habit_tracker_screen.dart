import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/habit_model.dart';
import '../models/priority_level.dart';
import '../database_helper.dart';

class HabitTrackerScreen extends StatefulWidget {
  @override
  _HabitTrackerScreenState createState() => _HabitTrackerScreenState();
}

class _HabitTrackerScreenState extends State<HabitTrackerScreen> {
  int daysInMonth = _getDaysInMonth(DateTime.now());
  String get currentMonthYear => DateFormat.yMMMM().format(DateTime.now());
  String _viewMode = "daily"; // Default view mode (daily, weekly, or monthly)

  List<Habit> habits = [];

  static int _getDaysInMonth(DateTime date) {
    DateTime firstDayOfNextMonth = DateTime(date.year, date.month + 1, 1);
    DateTime lastDayOfThisMonth = firstDayOfNextMonth.subtract(Duration(days: 1));
    return lastDayOfThisMonth.day;
  }

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    habits = await DatabaseHelper().getHabits();
    setState(() {});
  }

  void _addHabitDialog() {
    String name = '';
    PriorityLevel priority = PriorityLevel.medium;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Habit'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (value) {
                    name = value;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Habit Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<PriorityLevel>(
                  value: priority,
                  onChanged: (value) {
                    if (value != null) priority = value;
                  },
                  items: PriorityLevel.values.map((level) {
                    return DropdownMenuItem(
                      value: level,
                      child: Text(level.toString().split('.').last.capitalize()),
                    );
                  }).toList(),
                  decoration: const InputDecoration(
                    labelText: 'Priority Level',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (name.isNotEmpty) {
                  String id = DateTime.now().toString();
                  Habit newHabit = Habit(
                    id: id,
                    name: name,
                    daysInMonth: daysInMonth,
                    completedDays: List.generate(daysInMonth, (index) => false),
                    targetDays: daysInMonth,
                    priority: priority,
                  );
                  await DatabaseHelper().insertHabit(newHabit);
                  _loadHabits();
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Habit "$name" added successfully!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a habit name.')),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _toggleDayCompletion(Habit habit, int dayIndex) {
    setState(() {
      habit.completedDays[dayIndex] = !habit.completedDays[dayIndex];
      DatabaseHelper().updateHabit(habit);
    });
  }

  void _resetHabit(Habit habit) {
    setState(() {
      habit.resetForNextMonth(daysInMonth);
      DatabaseHelper().updateHabit(habit);
    });
  }

  void _toggleViewMode(String mode) {
    setState(() {
      _viewMode = mode;
    });
  }

  void _confirmDeleteHabit(Habit habit) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Habit'),
          content: Text('Are you sure you want to delete the habit "${habit.name}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await DatabaseHelper().deleteHabit(habit.id);
                _loadHabits();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Habit "${habit.name}" deleted successfully!')),
                );
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDailyView() {
    return ListView.builder(
      itemCount: habits.length,
      itemBuilder: (context, index) {
        return _buildHabitCard(habits[index]);
      },
    );
  }

  Widget _buildWeeklyView() {
    return ListView.builder(
      itemCount: habits.length,
      itemBuilder: (context, index) {
        final habit = habits[index];
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8),
          elevation: 4,
          child: Column(
            children: [
              ListTile(
                title: Text(habit.name, style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Weekly Progress', style: TextStyle(color: Colors.grey)),
              ),
              _buildWeekRows(habit),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWeekRows(Habit habit) {
    final weeks = List.generate(4, (i) => habit.completedDays.skip(i * 7).take(7).toList());
    return Column(
      children: weeks.map((week) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: week.map((day) {
            return Container(
              width: 30,
              height: 30,
              margin: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: day ? Color(0xFF00A676) : Color(0xFFE07A5F), // Vibrant Emerald Green for completed, Muted Orange for not completed
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }

  Widget _buildMonthlyView() {
    return ListView.builder(
      itemCount: habits.length,
      itemBuilder: (context, index) {
        final habit = habits[index];
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8),
          elevation: 4,
          child: Column(
            children: [
              ListTile(
                title: Text(habit.name, style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Monthly Completion', style: TextStyle(color: Colors.grey)),
              ),
              LinearProgressIndicator(
                value: habit.completionPercentage / 100,
                color: Color(0xFF00A676), // Vibrant Emerald Green
                backgroundColor: Colors.grey[300],
              ),
              SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHabitCard(Habit habit) {
    double completion = habit.completionPercentage;
    int streak = habit.currentStreak;

    Color priorityColor;
    String priorityLabel;

    switch (habit.priority) {
      case PriorityLevel.high:
        priorityColor = Color(0xFFE07A5F); // Muted Orange
        priorityLabel = 'High';
        break;
      case PriorityLevel.medium:
        priorityColor = Color(0xFF00A676); // Vibrant Emerald Green
        priorityLabel = 'Medium';
        break;
      case PriorityLevel.low:
        priorityColor = Color(0xFF1A1E3B); // Deep Navy Blue
        priorityLabel = 'Low';
        break;
    }

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      child: Column(
        children: [
          ListTile(
            title: Text(
              habit.name,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: priorityColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        priorityLabel,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text('Completion: ${completion.toStringAsFixed(1)}%'),
                  ],
                ),
                Text('Streak: $streak day${streak > 1 ? 's' : ''}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Color(0xFF1A1E3B)), // Deep Navy Blue
                  onPressed: () => _editHabitDialog(habit),
                ),
                IconButton(
                  icon: Icon(Icons.refresh, color: Color(0xFFE07A5F)), // Muted Orange
                  onPressed: () => _resetHabit(habit),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDeleteHabit(habit),
                ),
              ],
            ),
          ),
          _buildCompactCalendar(habit),
        ],
      ),
    );
  }

  Widget _buildCompactCalendar(Habit habit) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(daysInMonth, (index) {
          if (index < habit.completedDays.length) {
            DateTime date = DateTime(DateTime.now().year, DateTime.now().month, index + 1);
            String dayOfMonth = DateFormat.d().format(date);

            return GestureDetector(
              onTap: () => _toggleDayCompletion(habit, index),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: habit.completedDays[index] ? Color(0xFF00A676) : Color(0xFFE07A5F), // Vibrant Emerald Green for completed, Muted Orange for not completed
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black12),
                ),
                width: 30,
                height: 30,
                child: Center(child: Text(dayOfMonth, style: TextStyle(color: Colors.white))),
              ),
            );
          }
          return SizedBox.shrink();
        }),
      ),
    );
  }

  void _editHabitDialog(Habit habit) {
    String name = habit.name;
    PriorityLevel priority = habit.priority;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Habit'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (value) {
                    name = value;
                  },
                  decoration: InputDecoration(
                    labelText: 'Habit Name',
                    border: OutlineInputBorder(),
                    hintText: habit.name,
                  ),
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<PriorityLevel>(
                  value: priority,
                  onChanged: (value) {
                    if (value != null) priority = value;
                  },
                  items: PriorityLevel.values.map((level) {
                    return DropdownMenuItem(
                      value: level,
                      child: Text(level.toString().split('.').last.capitalize()),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'Priority Level',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (name.isNotEmpty) {
                  habit.name = name;
                  habit.priority = priority;
                  await DatabaseHelper().updateHabit(habit);
                  _loadHabits();
                  Navigator.of(context).pop();
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Habit Tracker'),
        backgroundColor: Color(0xFF1A1E3B), // Deep Navy Blue
        actions: [
          PopupMenuButton<String>(
            onSelected: _toggleViewMode,
            itemBuilder: (context) {
              return ['Daily', 'Weekly', 'Monthly'].map((String choice) {
                return PopupMenuItem<String>(
                  value: choice.toLowerCase(),
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              currentMonthYear,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: _viewMode == 'daily'
                ? _buildDailyView()
                : _viewMode == 'weekly'
                ? _buildWeeklyView()
                : _buildMonthlyView(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addHabitDialog,
        child: Icon(Icons.add),
        backgroundColor: Color(0xFF00A676), // Vibrant Emerald Green
      ),
    );
  }
}