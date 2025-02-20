class EisenhowerTask {
  int? id;
  String title;
  String? notes;
  DateTime? deadline;
  bool isCompleted;
  String category;

  EisenhowerTask({
    this.id,
    required this.title,
    this.notes,
    this.deadline,
    this.isCompleted = false,
    required this.category,
  });

  // Convert an EisenhowerTask into a Map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'notes': notes,
      'deadline': deadline?.millisecondsSinceEpoch,
      'isCompleted': isCompleted ? 1 : 0,
      'category': category,
    };
  }

  // Create an EisenhowerTask from a Map.
  factory EisenhowerTask.fromMap(Map<String, dynamic> map) {
    return EisenhowerTask(
      id: map['id'],
      title: map['title'],
      notes: map['notes'],
      deadline: map['deadline'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['deadline'])
          : null,
      isCompleted: map['isCompleted'] == 1,
      category: map['category'],
    );
  }
}