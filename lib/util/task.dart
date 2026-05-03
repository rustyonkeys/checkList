enum Priority { high, medium, low }

class Task {
  final String id;
  final String title;
  final String description;
  String? list;
  final Priority priority;
  final DateTime dueDate;
  final DateTime createdAt;
  bool isDone;
  DateTime? completedAt;

  Task({
    required this.id,
    required this.title,
    required this.description,
    this.list,
    required this.priority,
    required this.dueDate,
    required this.createdAt,
    this.isDone = false,
    this.completedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'list': list,
      'priority': priority.name,
      'dueDate': dueDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'isDone': isDone,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id:
          json['id'] as String? ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      title: json['title'] as String,
      description: json['description'] as String,
      list: json['list'] as String?,
      priority: Priority.values.firstWhere(
        (p) => p.name == json['priority'],
        orElse: () => Priority.medium,
      ),
      dueDate: DateTime.parse(json['dueDate'] as String),
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.now(),
      isDone: json['isDone'] as bool? ?? false,
      completedAt:
          json['completedAt'] != null
              ? DateTime.parse(json['completedAt'] as String)
              : null,
    );
  }
}
