enum Priority { high, medium, low }

class Task {
  final String title;
  final String description;
  final String? list;
  final Priority priority;
  final DateTime dueDate;
  bool isDone;

  Task({
    required this.title,
    required this.description,
    this.list,
    required this.priority,
    required this.dueDate,
    this.isDone = false,
  });
}
