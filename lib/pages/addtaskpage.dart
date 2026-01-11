import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:checklist/util/task.dart';

class AddTaskPage extends StatefulWidget {
  final bool isDarkMode;

  const AddTaskPage({super.key, this.isDarkMode = false});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  Priority _priority = Priority.medium;
  DateTime _selectedDate = DateTime.now();

  final List<String> _lists = [
    "Work",
    "Personal",
    "Health",
    "Shopping",
    "Study",
  ];

  String? _selectedList;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Theme colors
    final backgroundColor = widget.isDarkMode ? const Color(0xFF1A1A1A) : Colors.white;
    final textColor = widget.isDarkMode ? Colors.white : Colors.black;
    final cardColor = widget.isDarkMode ? const Color(0xFF2A2A2A) : Colors.grey[50];
    final borderColor = widget.isDarkMode ? Colors.grey[700]! : Colors.grey.shade200;
    final hintColor = widget.isDarkMode ? Colors.grey[500] : Colors.grey[400];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.close, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              Text(
                "What do you want to do?",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                  color: textColor,
                ),
              ),

              const SizedBox(height: 32),

              TextField(
                controller: _titleController,
                maxLines: 2,
                style: TextStyle(fontSize: 16, color: textColor),
                decoration: _inputDecoration(
                  "Enter task...",
                  cardColor,
                  borderColor,
                  hintColor,
                  textColor,
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _descriptionController,
                maxLines: 4,
                style: TextStyle(fontSize: 15, color: textColor),
                decoration: _inputDecoration(
                  "Description...",
                  cardColor,
                  borderColor,
                  hintColor,
                  textColor,
                ),
              ),

              const Spacer(),

              // Pills row with proper spacing
              Row(
                children: [
                  _datePill(textColor, borderColor, cardColor),
                  const SizedBox(width: 12),
                  Expanded(child: _listDropdown(textColor, borderColor, cardColor)),
                  const SizedBox(width: 12),
                  _priorityDropdown(textColor, borderColor, cardColor),
                ],
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.isDarkMode ? Colors.white : Colors.black,
                    foregroundColor: widget.isDarkMode ? Colors.black : Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _createTask,
                  child: const Text(
                    "Create Task",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _createTask() {
    if (_titleController.text.trim().isEmpty) return;

    final task = Task(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      list: _selectedList,
      priority: _priority,
      dueDate: _dateOnly(_selectedDate),
    );

    Navigator.pop(context, task);
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  InputDecoration _inputDecoration(
      String hint,
      Color? fillColor,
      Color borderColor,
      Color? hintColor,
      Color textColor,
      ) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: hintColor),
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: widget.isDarkMode ? Colors.white : Colors.black,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _pill({
    required Widget child,
    VoidCallback? onTap,
    required Color bgColor,
    required Color borderColor,
    double? width,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: width,
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: child,
      ),
    );
  }

  Widget _datePill(Color textColor, Color borderColor, Color? bgColor) {
    return _pill(
      width: 120,
      onTap: _pickDate,
      bgColor: bgColor!,
      borderColor: borderColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today, size: 16, color: textColor),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              _dateLabel(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: widget.isDarkMode ? Colors.white : Colors.black,
              surface: widget.isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
              onSurface: widget.isDarkMode ? Colors.white : Colors.black,
            ),
            dialogBackgroundColor: widget.isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) setState(() => _selectedDate = picked);
  }

  String _dateLabel() {
    final today = _dateOnly(DateTime.now());
    final tomorrow = today.add(const Duration(days: 1));

    if (_selectedDate == today) return "Today";
    if (_selectedDate == tomorrow) return "Tomorrow";

    return DateFormat("MMM d").format(_selectedDate);
  }

  Widget _listDropdown(Color textColor, Color borderColor, Color? bgColor) {
    return _pill(
      bgColor: bgColor!,
      borderColor: borderColor,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedList,
          hint: Text(
            "No List",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
          icon: Icon(Icons.arrow_drop_down, color: textColor),
          isExpanded: true,
          dropdownColor: widget.isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
          items: _lists
              .map((l) => DropdownMenuItem(
            value: l,
            child: Text(l),
          ))
              .toList(),
          onChanged: (v) => setState(() => _selectedList = v),
        ),
      ),
    );
  }

  Widget _priorityDropdown(Color textColor, Color borderColor, Color? bgColor) {
    return _pill(
      width: 110,
      bgColor: bgColor!,
      borderColor: borderColor,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Priority>(
          value: _priority,
          icon: Icon(Icons.arrow_drop_down, color: textColor),
          isExpanded: true,
          dropdownColor: widget.isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
          items: const [
            DropdownMenuItem(value: Priority.high, child: Text("High")),
            DropdownMenuItem(value: Priority.medium, child: Text("Medium")),
            DropdownMenuItem(value: Priority.low, child: Text("Low")),
          ],
          onChanged: (v) => setState(() => _priority = v!),
        ),
      ),
    );
  }
}