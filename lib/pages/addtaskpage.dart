import 'package:flutter/material.dart';

enum Priority { high, medium, low }

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  Priority _priority = Priority.medium;

  final List<String> _lists = [
    "Work",
    "Personal",
    "Health",
    "Shopping",
    "Study",
    "Finance",
    "Travel",
  ];

  String? _selectedList;
  final TextEditingController _listController = TextEditingController();

  static const double pillWidth = 120;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "What needs to be done?",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Add details, notes, or subtasks...",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),

            TextField(
              maxLines: 2,
              decoration: InputDecoration(
                hintText: "Enter task...",
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Description...",
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const Spacer(),

            Row(
              children: [
                _pill(Icons.calendar_today, "Today"),
                const SizedBox(width: 10),
                _listDropdown(),
                const SizedBox(width: 10),
                _priorityDropdown(),
              ],
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
                child: const Text("Create Task"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(IconData icon, String text) {
    return SizedBox(
      width: pillWidth,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 6),
            Text(text),
          ],
        ),
      ),
    );
  }

  /// LIST DROPDOWN
  Widget _listDropdown() {
    return SizedBox(
      width: pillWidth,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(30),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            hint: const Text("No List"),
            value: _selectedList,
            isExpanded: true,
            items: [
              ..._lists.map(
                    (list) => DropdownMenuItem(
                  value: list,
                  child: Text(list),
                ),
              ),
              const DropdownMenuItem(
                value: "__add__",
                child: Text("+ Add New"),
              ),
            ],
            onChanged: (value) {
              if (value == "__add__") {
                _showAddListDialog();
              } else {
                setState(() => _selectedList = value);
              }
            },
          ),
        ),
      ),
    );
  }

  void _showAddListDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add New List"),
          content: TextField(
            controller: _listController,
            decoration: const InputDecoration(hintText: "List name"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _listController.clear();
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final name = _listController.text.trim();
                if (name.isNotEmpty) {
                  setState(() {
                    _lists.add(name);
                    _selectedList = name;
                  });
                }
                _listController.clear();
                Navigator.pop(context);
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  /// PRIORITY DROPDOWN
  Widget _priorityDropdown() {
    return SizedBox(
      width: pillWidth,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        decoration: BoxDecoration(
          color: _priorityColor().withOpacity(0.15),
          borderRadius: BorderRadius.circular(30),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<Priority>(
            value: _priority,
            isExpanded: true,
            items: const [
              DropdownMenuItem(
                value: Priority.high,
                child: Text("High"),
              ),
              DropdownMenuItem(
                value: Priority.medium,
                child: Text("Medium"),
              ),
              DropdownMenuItem(
                value: Priority.low,
                child: Text("Low"),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _priority = value);
              }
            },
            style: TextStyle(
              color: _priorityColor(),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Color _priorityColor() {
    switch (_priority) {
      case Priority.high:
        return Colors.red;
      case Priority.medium:
        return Colors.orange;
      case Priority.low:
        return Colors.teal;
    }
  }
}
