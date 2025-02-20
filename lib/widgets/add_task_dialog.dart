import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/eisenhower_task_model.dart';
import '../models/categories.dart'; // Import the Categories class

class AddTaskDialog extends StatefulWidget {
  final Function(EisenhowerTask) onAddTask;
  final String category; // Add category parameter

  const AddTaskDialog({Key? key, required this.onAddTask, required this.category}) : super(key: key);

  @override
  _AddTaskDialogState createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  DateTime? _deadline;

  // Set the category based on the passed parameter
  late String _category;

  @override
  void initState() {
    super.initState();
    _category = widget.category; // Initialize with the passed category
  }

  /// Helper function to display user-friendly names for each category.
  String getCategoryDisplayName(String category) {
    switch (category) {
      case Categories.urgentImportant:
        return 'Urgent & Important';
      case Categories.notUrgentImportant:
        return 'Not Urgent & Important';
      case Categories.urgentNotImportant:
        return 'Urgent & Not Important';
      case Categories.notUrgentNotImportant:
        return 'Not Urgent & Not Important';
      default:
        return category; // Fallback, in case of an unexpected string
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Color(0xFFF8F8F8), // Soft Warm Gray background
      title: const Text('Add Task', style: TextStyle(color: Color(0xFF202124))), // Dark Charcoal Black title
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Task title
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Task Title',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white, // White background for text field
                ),
                style: TextStyle(color: Color(0xFF202124)), // Dark Charcoal Black text
              ),
              const SizedBox(height: 10),
              // Task notes
              TextField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white, // White background for text field
                ),
                maxLines: 3,
                style: TextStyle(color: Color(0xFF202124)), // Dark Charcoal Black text
              ),
              // Deadline selection
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _deadline == null
                        ? 'No Deadline'
                        : 'Deadline: ${DateFormat.yMMMd().format(_deadline!)}',
                    style: TextStyle(color: Color(0xFF202124)), // Dark Charcoal Black
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (selectedDate != null && selectedDate.isAfter(DateTime.now())) {
                        setState(() {
                          _deadline = selectedDate;
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select a valid date.')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF00A676), // Vibrant Emerald Green
                    ),
                    child: const Text('Set Deadline', style: TextStyle(color: Colors.white)), // White text for button
                  ),
                ],
              ),
              // Category dropdown
              DropdownButton<String>(
                value: _category,
                onChanged: (String? newValue) {
                  setState(() {
                    _category = newValue!;
                  });
                },
                items: <String>[
                  Categories.urgentImportant,
                  Categories.notUrgentImportant,
                  Categories.urgentNotImportant,
                  Categories.notUrgentNotImportant,
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    // Display the user-friendly name in the dropdown
                    child: Text(getCategoryDisplayName(value), style: TextStyle(color: Color(0xFF202124))), // Dark Charcoal Black
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Validate that the task has a title
            if (_titleController.text.isNotEmpty) {
              // Create the EisenhowerTask using the internal category constant
              final task = EisenhowerTask(
                title: _titleController.text,
                notes: _notesController.text,
                deadline: _deadline,
                isCompleted: false,
                category: _category,
              );
              widget.onAddTask(task);
              Navigator.of(context).pop();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Task title cannot be empty!')),
              );
            }
          },
          child: const Text('Add', style: TextStyle(color: Colors.white)), // White text for button
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: Color(0xFF202124))), // Dark Charcoal Black
        ),
      ],
    );
  }
}