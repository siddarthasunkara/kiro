import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../database_helper.dart';

class TimeBlockingScreen extends StatefulWidget {
  @override
  _TimeBlockingScreenState createState() => _TimeBlockingScreenState();
}

class _TimeBlockingScreenState extends State<TimeBlockingScreen> {
  DateTime selectedDate = DateTime.now();
  List<Task> tasks = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();

  final List<Color> taskColors = [
    Color(0xFF1A1E3B), // Deep Navy Blue
    Color(0xFF5F4B8B), // Muted Purple
    Color(0xFF00A676), // Vibrant Emerald Green
    Color(0xFFE07A5F), // Muted Orange
    Color(0xFFE9A86F), // Warm Amber
    Color(0xFFF2CC8F), // Warm Yellow
    Color(0xFFB0B0B0), // Light Gray
    Color(0xFF202124), // Dark Charcoal Black
  ];

  String getFormattedDate(DateTime date) => DateFormat('EEE, MMM d').format(date);

  List<Task> getTasksForSelectedDate() {
    String dateKey = DateFormat('yyyy-MM-dd').format(selectedDate);
    return tasks.where((task) => DateFormat('yyyy-MM-dd').format(task.startTime) == dateKey).toList();
  }

  Future<void> addOrUpdateTask(Task task, {Task? existingTask}) async {
    if (existingTask != null) {
      await _dbHelper.updateTask(task);
    } else {
      await _dbHelper.insertTask(task);
    }
    loadTasks();
  }

  Future<void> deleteTask(Task task) async {
    await _dbHelper.deleteTask(task.id!);
    loadTasks();
  }

  void loadTasks() async {
    tasks = await _dbHelper.getTasks();
    setState(() {});
  }

  void _showTaskDialog({Task? task, DateTime? timeSlot}) {
    String taskName = task?.name ?? '';
    DateTime startTime = task?.startTime ?? timeSlot!;
    DateTime endTime = task?.endTime ?? startTime.add(Duration(hours: 1));
    Color taskColor = task?.color ?? taskColors[0];
    bool showColorPicker = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(task == null ? 'Add Task' : 'Edit Task'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: TextEditingController(text: taskName),
                      onChanged: (value) => taskName = value,
                      decoration: InputDecoration(labelText: 'Task Name'),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Start: ${DateFormat.jm().format(startTime)}"),
                        ElevatedButton(
                          onPressed: () async {
                            TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(startTime),
                            );
                            if (picked != null) {
                              setDialogState(() {
                                startTime = DateTime(
                                  selectedDate.year,
                                  selectedDate.month,
                                  selectedDate.day,
                                  picked.hour,
                                  picked.minute,
                                );
                                if (startTime.isAfter(endTime)) {
                                  endTime = startTime.add(Duration(hours: 1));
                                }
                              });
                            }
                          },
                          child: Text('Change'),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("End: ${DateFormat.jm().format(endTime)}"),
                        ElevatedButton(
                          onPressed: () async {
                            TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(endTime),
                            );
                            if (picked != null) {
                              setDialogState(() {
                                endTime = DateTime(
                                  selectedDate.year,
                                  selectedDate.month,
                                  selectedDate.day,
                                  picked.hour,
                                  picked.minute,
                                );
                                if (endTime.isBefore(startTime)) {
                                  startTime = endTime.subtract(Duration(hours: 1));
                                }
                              });
                            }
                          },
                          child: Text('Change'),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        setDialogState(() {
                          showColorPicker = !showColorPicker;
                        });
                      },
                      child: Text('Choose Color'),
                    ),
                    if (showColorPicker)
                      Wrap(
                        spacing: 10,
                        children: taskColors.map((color) {
                          return GestureDetector(
                            onTap: () {
                              setDialogState(() {
                                taskColor = color;
                              });
                            },
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: taskColor == color ? Colors.black : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (taskName.isNotEmpty) {
                      addOrUpdateTask(
                        Task(
                          id: task?.id, // Keep the existing ID if editing
                          name: taskName,
                          startTime: startTime,
                          endTime: endTime,
                          color: taskColor,
                        ),
                        existingTask: task,
                      );
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(task == null ? 'Add' : 'Update'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void previousDay() {
    setState(() {
      selectedDate = selectedDate.subtract(Duration(days: 1));
    });
  }

  void nextDay() {
    setState(() {
      selectedDate = selectedDate.add(Duration(days: 1));
    });
  }

  @override
  void initState() {
    super.initState();
    loadTasks(); // Load tasks when the screen is initialized
  }

  @override
  Widget build(BuildContext context) {
    final hours = List.generate(24, (index) => index);
    final tasksForToday = getTasksForSelectedDate();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xFFF8F8F8), // Soft Warm Gray background
        ),
        child: Column(
          children: [
            AppBar(
              backgroundColor: Color(0xFF1A1E3B), // Deep Navy Blue for AppBar
              title: Text('Time Blocking', style: TextStyle(color: Colors.white)),
              actions: [
                IconButton(onPressed: previousDay, icon: Icon(Icons.arrow_back, color: Colors.white)),
                IconButton(onPressed: nextDay, icon: Icon(Icons.arrow_forward, color: Colors.white)),
              ],
            ),
            Container(
              padding: EdgeInsets.all(16),
              color: Color(0xFF1A1E3B), // Deep Navy Blue for date display
              child: Center(
                child: Text(
                  getFormattedDate(selectedDate),
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Row(
                  children: [
                    Column(
                      children: hours.map((hour) {
                        final timeLabel = DateFormat.j().format(DateTime(0, 0, 0, hour));
                        return Container(
                          height: 60,
                          width: 50,
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(right: 8),
                          child: Text(
                            timeLabel,
                            style: TextStyle(fontSize: 14, color: Color(0xFF202124)), // Dark Charcoal Black for better readability
                          ),
                        );
                      }).toList(),
                    ),
                    Expanded(
                      child: Stack(
                        children: [
                          Column(
                            children: hours.map((hour) {
                              return GestureDetector(
                                onTap: () => _showTaskDialog(timeSlot: DateTime(selectedDate.year, selectedDate.month, selectedDate.day, hour)),
                                child: Container(
                                  height: 60,
                                  margin: EdgeInsets.only(bottom: 1),
                                  color: Color(0xFF292929), // Neutral Dark Gray for time slots
                                ),
                              );
                            }).toList(),
                          ),
                          ...tasksForToday.map((task) {
                            final int startHour = task.startTime.hour;
                            final int endHour = task.endTime.hour;

                            return Positioned(
                              top: startHour * 60, // Position based on start hour
                              height: (endHour - startHour + (task.endTime.minute > 0 ? 1 : 0)) * 60, // Adjust height
                              left: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () => _showTaskDialog(task: task),
                                child: Card(
                                  margin: EdgeInsets.all(4),
                                  color: task.color.withOpacity(0.8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 4,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          task.name,
                                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete, color: Colors.red),
                                          onPressed: () {
                                            deleteTask(task);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: TimeBlockingScreen()));
}