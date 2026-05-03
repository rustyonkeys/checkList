import 'package:flutter/material.dart';
import 'package:checklist/util/task.dart';

class CalendarPage extends StatefulWidget {
  final bool isDarkMode;
  final List<Task> tasks;

  const CalendarPage({
    super.key,
    required this.isDarkMode,
    required this.tasks,
  });

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _selectedDate = DateTime.now();

  DateTime get _today => DateTime.now();

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  List<Task> get _selectedDayTasks {
    final selected = _dateOnly(_selectedDate);
    return widget.tasks
        .where((task) => _dateOnly(task.dueDate) == selected)
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  List<DateTime> get _weekDays {
    final start = _dateOnly(_selectedDate).subtract(const Duration(days: 3));
    return List<DateTime>.generate(
      7,
      (index) => start.add(Duration(days: index)),
    );
  }

  void _changeSelectedDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(_today.year - 2),
      lastDate: DateTime(_today.year + 2),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme:
                widget.isDarkMode
                    ? const ColorScheme.dark()
                    : const ColorScheme.light(),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      _changeSelectedDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        widget.isDarkMode ? const Color(0xFF121212) : Colors.white;
    final cardColor =
        widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey[100];
    final textColor = widget.isDarkMode ? Colors.white : Colors.black;
    final accentColor = widget.isDarkMode ? Colors.tealAccent : Colors.blue;
    final subtitleColor =
        widget.isDarkMode ? Colors.grey[400] : Colors.grey[700];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        title: Text(
          'Calendar',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_month, color: textColor),
            onPressed: _pickDate,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${_selectedDate.month}/${_selectedDate.day}/${_selectedDate.year}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor:
                          widget.isDarkMode ? Colors.black : Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.today),
                    label: const Text('Today'),
                    onPressed: () => _changeSelectedDate(_today),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 96,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final day = _weekDays[index];
                  final isSelected = _dateOnly(day) == _dateOnly(_selectedDate);
                  return GestureDetector(
                    onTap: () => _changeSelectedDate(day),
                    child: Container(
                      width: 72,
                      decoration: BoxDecoration(
                        color: isSelected ? accentColor : cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? accentColor : Colors.transparent,
                        ),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            [
                              'Sun',
                              'Mon',
                              'Tue',
                              'Wed',
                              'Thu',
                              'Fri',
                              'Sat',
                            ][day.weekday % 7],
                            style: TextStyle(
                              color: isSelected ? Colors.black : textColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            day.day.toString(),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.black : textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemCount: _weekDays.length,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child:
                      _selectedDayTasks.isEmpty
                          ? Center(
                            child: Text(
                              'No tasks due on this day.',
                              style: TextStyle(
                                color: subtitleColor,
                                fontSize: 16,
                              ),
                            ),
                          )
                          : ListView.separated(
                            itemCount: _selectedDayTasks.length,
                            separatorBuilder:
                                (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final task = _selectedDayTasks[index];
                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color:
                                      widget.isDarkMode
                                          ? const Color(0xFF262626)
                                          : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color:
                                        widget.isDarkMode
                                            ? Colors.grey[800]!
                                            : Colors.grey[200]!,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      task.title,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      task.description.isNotEmpty
                                          ? task.description
                                          : 'No description',
                                      style: TextStyle(color: subtitleColor),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: accentColor.withAlpha(40),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            task.priority.name.toUpperCase(),
                                            style: TextStyle(
                                              color:
                                                  widget.isDarkMode
                                                      ? Colors.black
                                                      : Colors.white,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        Icon(
                                          task.isDone
                                              ? Icons.check_circle
                                              : Icons.circle_outlined,
                                          color:
                                              task.isDone
                                                  ? Colors.green
                                                  : subtitleColor,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
