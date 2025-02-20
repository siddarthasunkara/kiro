class PomodoroTask {
  int? id; // Make sure this is defined
  String title;
  int estimatedPomodoros;
  int completedPomodoros;

  PomodoroTask({
    this.id, // Ensure this is included
    required this.title,
    this.estimatedPomodoros = 0,
    this.completedPomodoros = 0,
  });

  // Convert a task into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id, // Ensure this is included
      'title': title,
      'estimatedPomodoros': estimatedPomodoros,
      'completedPomodoros': completedPomodoros,
    };
  }

  // Create a task from a Map
  factory PomodoroTask.fromMap(Map<String, dynamic> map) {
    return PomodoroTask(
      id: map['id'], // Ensure this is included
      title: map['title'],
      estimatedPomodoros: map['estimatedPomodoros'],
      completedPomodoros: map['completedPomodoros'],
    );
  }
}