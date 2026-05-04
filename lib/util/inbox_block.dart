enum InboxBlockType { todo, bullet, text, heading1, heading2 }

class InboxBlock {
  final String id;
  InboxBlockType type;
  String text;
  bool isChecked;
  final DateTime createdAt;

  InboxBlock({
    required this.id,
    required this.type,
    required this.text,
    this.isChecked = false,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'text': text,
      'isChecked': isChecked,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory InboxBlock.fromJson(Map<String, dynamic> json) {
    return InboxBlock(
      id:
          json['id'] as String? ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      type: InboxBlockType.values.firstWhere(
        (value) => value.name == json['type'],
        orElse: () => InboxBlockType.todo,
      ),
      text: json['text'] as String? ?? '',
      isChecked: json['isChecked'] as bool? ?? false,
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.now(),
    );
  }
}
