import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kiro/models/pomodoro_model.dart';
import 'package:kiro/widgets/task_card.dart';
import 'package:kiro/widgets/timer_display.dart';
import '../database_helper.dart'; // Import the database helper

class PomodoroApp extends StatefulWidget {
  const PomodoroApp({super.key}); // Added key parameter

  @override
  _PomodoroAppState createState() => _PomodoroAppState();
}

class _PomodoroAppState extends State<PomodoroApp> {
  late Timer _timer;
  int _secondsRemaining = 1500; // 25 minutes
  bool _isRunning = false;
  bool _isWorkTime = true;
  PomodoroTask? _currentTask; // Selected task
  bool _showSessions = false; // To toggle completed sessions visibility

  final int focusDuration = 1500; // 25 minutes
  final int shortBreakDuration = 300; // 5 minutes
  final int longBreakDuration = 600; // 10 minutes
  final int sessionsBeforeLongBreak = 4;

  List<PomodoroTask> tasks = [];
  List<Map<String, dynamic>> sessionHistory = []; // To store completed sessions
  final DatabaseHelper _dbHelper = DatabaseHelper(); // Database helper instance

  @override
  void initState() {
    super.initState();
    _loadTasks(); // Load tasks from the database
  }

  Future<void> _loadTasks() async {
    final tasksMap = await _dbHelper.getPomodoroTasks();
    tasks = tasksMap.map((taskMap) => PomodoroTask.fromMap(taskMap as Map<String, dynamic>)).toList();
    setState(() {});
  }

  void _startPauseTimer() {
    if (_currentTask == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a task to start the timer.')),
      );
      return;
    }

    if (_isRunning) {
      _timer.cancel();
    } else {
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          if (_secondsRemaining > 0) {
            _secondsRemaining--;
          } else {
            _completePomodoro();
          }
        });
      });
    }

    setState(() {
      _isRunning = !_isRunning;
    });
  }

  void _completePomodoro() {
    if (_isWorkTime) {
      setState(() {
        _currentTask?.completedPomodoros++;

        if (_currentTask!.completedPomodoros >= _currentTask!.estimatedPomodoros) {
          _addToSessionHistory(_currentTask!);
          tasks.remove(_currentTask);
          _currentTask = null; // Clear the current task
        } else {
          _showBreakDialog(); // Show break dialog
        }
      });

      _dbHelper.updatePomodoroTask(_currentTask!); // Update task in the database
    } else {
      setState(() {
        _isWorkTime = true;
        _secondsRemaining = focusDuration; // Reset to focus duration
      });
    }

    // Stop the timer
    if (_isRunning) {
      _timer.cancel();
      setState(() {
        _isRunning = false; // Update the running state
      });
    }
  }

  void _showBreakDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Break Time!', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF202124))),
          content: Text('How long would you like to take a break?', style: TextStyle(color: Color(0xFF202124))),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _isWorkTime = false;
                  _secondsRemaining = shortBreakDuration; // Set to short break duration
                });
                Navigator.of(context).pop();
                _startBreakTimer();
              },
              child: Text('5 Minutes', style: TextStyle(color: Color(0xFF00A676))), // Vibrant Emerald Green
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isWorkTime = false;
                  _secondsRemaining = longBreakDuration; // Set to long break duration
                });
                Navigator.of(context).pop();
                _startBreakTimer();
              },
              child: Text('10 Minutes', style: TextStyle(color: Color(0xFF00A676))), // Vibrant Emerald Green
            ),
          ],
        );
      },
    );
  }

  void _startBreakTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _endBreak();
        }
      });
    });
  }

  void _endBreak() {
    _timer.cancel();
    setState(() {
      _isWorkTime = true; // Set back to work time
      _secondsRemaining = focusDuration; // Reset to focus duration
      _isRunning = false; // Reset running state
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Break is over! Time to get back to work!', style: TextStyle(color: Color(0xFF202124)))),
    );
  }

  void _addToSessionHistory(PomodoroTask task) {
    sessionHistory.add({
      'title': task.title,
      'pomodoros': task.estimatedPomodoros,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Task "${task.title}" completed!', style: TextStyle(color: Color(0xFF202124)))),
    );
  }

  void _addTaskDialog() {
    String title = '';
    int estimatedPomodoros = 1;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Task', style: TextStyle(fontWeight: FontWeight.bold, color: Color(
              0xFF5F5F65))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  title = value;
                },
                decoration: InputDecoration(labelText: 'Task Title'),
              ),
              TextField(
                onChanged: (value) {
                  estimatedPomodoros = int.tryParse(value) ?? 1;
                },
                decoration: InputDecoration(labelText: 'Pomodoros'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (title.isNotEmpty && estimatedPomodoros > 0) {
                  final newTask = PomodoroTask(
                    title: title,
                    estimatedPomodoros: estimatedPomodoros,
                  );
                  setState(() {
                    tasks.add(newTask);
                  });
                  _dbHelper.insertPomodoroTask(newTask); // Insert new task into the database
                  Navigator.of(context).pop();
                }
              },
              child: Text('Add', style: TextStyle(color: Color(0xFF00A676))), // Vibrant Emerald Green
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    if (_isRunning) _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xFFD3CBCB), // Soft Warm Gray background
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(vertical: 20),
              color: Color(0xFF1A1E3B), // Deep Navy Blue for header
              child: Center(
                child: Text(
                  'Pomodoro Timer',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),

            // Timer Display
            Expanded(
              child: Center(
                child: TimerDisplay(
                  secondsRemaining: _secondsRemaining,
                  isWorkTime: _isWorkTime,
                  focusDuration: focusDuration,
                  shortBreakDuration: shortBreakDuration,
                ),
              ),
            ),

            // Current Task
            if (_currentTask != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  color: Color(0xFFFFFFFF).withOpacity(0.8), // White with transparency
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      'Task: ${_currentTask!.title} (${_currentTask!.completedPomodoros}/${_currentTask!.estimatedPomodoros})',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF202124)), // Dark Charcoal Black
                    ),
                  ),
                ),
              ),

            // Task List
            Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  PomodoroTask task = tasks[index];
                  return TaskCard(
                    task: task,
                    onTap: () {
                      if (_isRunning) {
                        // Prompt user to confirm switching tasks while timer is running
                        _showSwitchTaskDialog(task);
                      } else {
                        setState(() {
                          _currentTask = task;
                          _isWorkTime = true;
                          _secondsRemaining = focusDuration; // Reset timer to focus duration
                        });
                      }
                    },
                  );
                },
              ),
            ),

            // Controls
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _startPauseTimer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF00A676), // Vibrant Emerald Green
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          _isRunning ? 'Pause' : 'Start',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          // Reset the timer and stop it when "Next" is pressed
                          if (_isRunning) {
                            _timer.cancel();
                            setState(() {
                              _isRunning = false; // Stop the timer
                            });
                          }
                          // Move to the next Pomodoro session
                          if (_currentTask != null) {
                            setState(() {
                              _currentTask!.completedPomodoros++;
                              if (_currentTask!.completedPomodoros >= _currentTask!.estimatedPomodoros) {
                                _addToSessionHistory(_currentTask!);
                                tasks.remove(_currentTask);
                                _currentTask = null; // Clear the current task
                              } else {
                                _secondsRemaining = focusDuration; // Reset timer to focus duration
                                _isWorkTime = true; // Set to work time
                              }
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF1E40AF), // Bold Cobalt Blue
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('Next', style: TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Show/Hide Completed Sessions
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _showSessions = !_showSessions;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF00A676), // Vibrant Emerald Green
              ),
              child: Text(_showSessions ? 'Hide Sessions' : 'Show Sessions', style: TextStyle(color: Colors.white)),
            ),

            // Completed Sessions List
            if (_showSessions)
              Expanded(
                child: ListView.builder(
                  itemCount: sessionHistory.length,
                  itemBuilder: (context, index) {
                    var session = sessionHistory[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      child: ListTile(
                        title: Text(session['title'], style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF202124))), // Dark Charcoal Black
                        subtitle: Text('${session['pomodoros']} Pomodoros completed', style: TextStyle(color: Color(0xFFB0B0B0))), // Light Gray
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _showDeleteSessionDialog(index);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTaskDialog,
        backgroundColor: Color(0xFF00A676), // Vibrant Emerald Green
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showSwitchTaskDialog(PomodoroTask newTask) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Switch Task', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF202124))),
          content: Text('Are you sure you want to switch to "${newTask.title}"?', style: TextStyle(color: Color(0xFF202124))),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _currentTask = newTask;
                  _isWorkTime = true;
                  _secondsRemaining = focusDuration; // Reset timer to focus duration
                });
                Navigator.of(context).pop();
              },
              child: Text('Yes', style: TextStyle(color: Color(0xFF00A676))), // Vibrant Emerald Green
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No', style: TextStyle(color: Color(0xFF00A676))), // Vibrant Emerald Green
            ),
          ],
        );
      },
    );
  }

  void _showDeleteSessionDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Session', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF202124))),
          content: Text('Are you sure you want to delete this session?', style: TextStyle(color: Color(0xFF202124))),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  sessionHistory.removeAt(index); // Remove the session from history
                });
                Navigator.of(context).pop();
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(color: Color(0xFF00A676))), // Vibrant Emerald Green
            ),
          ],
        );
      },
    );
  }
}