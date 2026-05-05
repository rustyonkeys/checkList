import 'package:checklist/pages/calendar_page.dart';
import 'package:checklist/pages/categories.dart';
import 'package:checklist/pages/inbox_page.dart';
import 'package:checklist/pages/settings.dart';
import 'package:checklist/services/local_storage.dart';
import 'package:checklist/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:checklist/pages/addtaskpage.dart';
import 'package:checklist/util/inbox_block.dart';
import 'package:checklist/util/task.dart';

import '../util/navbar.dart';
import 'analytic_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  List<Task> _tasks = [];
  List<InboxBlock> _inboxBlocks = [];
  List<CategoryItem> _categories = [];
  AppPreferences _preferences = AppPreferences.defaults();
  bool _isDarkMode = false;
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadLocalData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshReminderState();
    }
  }

  Future<void> _loadLocalData() async {
    final tasks = await LocalStorage.loadTasks();
    final inboxBlocks = await LocalStorage.loadInboxBlocks();
    final categories = await LocalStorage.loadCategories();
    final preferences = await LocalStorage.loadPreferences();
    final filteredTasks =
        preferences.autoDeleteCompleted
            ? _removeOldCompletedTasks(tasks, preferences.autoDeleteDays)
            : tasks;

    if (preferences.autoDeleteCompleted &&
        filteredTasks.length != tasks.length) {
      await LocalStorage.saveTasks(filteredTasks);
    }

    setState(() {
      _tasks = filteredTasks;
      _inboxBlocks = inboxBlocks;
      _categories = categories;
      _preferences = preferences;
      _isDarkMode = preferences.isDarkMode;
    });

    await _refreshReminderState();
  }

  Future<void> _saveTasks() async {
    await LocalStorage.saveTasks(_tasks);
    await NotificationService.scheduleTaskNudges(_tasks, _preferences);
  }

  Future<void> _saveInboxBlocks() async {
    await LocalStorage.saveInboxBlocks(_inboxBlocks);
  }

  Future<void> _saveCategories() async {
    await LocalStorage.saveCategories(_categories);
  }

  Future<void> _savePreferences() async {
    await LocalStorage.savePreferences(_preferences);
    await NotificationService.scheduleTaskNudges(_tasks, _preferences);
  }

  List<Task> _removeOldCompletedTasks(List<Task> tasks, int days) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return tasks.where((task) {
      return !(task.isDone &&
          task.completedAt != null &&
          task.completedAt!.isBefore(cutoff));
    }).toList();
  }

  List<Task> _sortedTasks(List<Task> tasks) {
    final sorted = List<Task>.from(tasks);
    switch (_preferences.taskSortBy) {
      case 'Priority':
        sorted.sort((a, b) => a.priority.index.compareTo(b.priority.index));
        break;
      case 'Created Date':
        sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'Alphabetical':
        sorted.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
        break;
      case 'Due Date':
      default:
        sorted.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    }
    return sorted;
  }

  DateTime get _today =>
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  DateTime get _tomorrow => _today.add(const Duration(days: 1));

  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  Future<void> _refreshReminderState() async {
    await NotificationService.scheduleTaskNudges(_tasks, _preferences);
    await _maybeShowYesterdayPrompt();
    await NotificationService.markAppOpened();
  }

  Future<void> _maybeShowYesterdayPrompt() async {
    if (!mounted) return;

    final lastOpenedAt = await NotificationService.getLastOpenedAt();
    final now = DateTime.now();
    final yesterday = _today.subtract(const Duration(days: 1));
    final unfinishedFromYesterday =
        _tasks
            .where(
              (task) => !task.isDone && _dateOnly(task.dueDate) == yesterday,
            )
            .toList();

    final reopenedAfterBreak =
        lastOpenedAt == null ||
        now.difference(lastOpenedAt).inHours >= 4;

    if (!reopenedAfterBreak || unfinishedFromYesterday.isEmpty) {
      return;
    }

    if (!mounted) return;
    final count = unfinishedFromYesterday.length;
    final shouldMove = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Missed a few?'),
            content: Text(
              'You have $count unfinished ${count == 1 ? 'task' : 'tasks'} from yesterday. Move ${count == 1 ? 'it' : 'them'} to today?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Keep date'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Move to today'),
              ),
            ],
          ),
    );

    if (shouldMove != true) return;

    setState(() {
      for (final task in unfinishedFromYesterday) {
        task.dueDate = _today;
      }
    });
    await _saveTasks();
  }

  void _handleNavigation(int index) {
    setState(() {
      _currentNavIndex = index;
    });
    Navigator.pop(context); // Close drawer

    // Navigate to different pages based on index
    switch (index) {
      case 0:
        // Already on home, do nothing
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => InboxPage(
                  isDarkMode: _isDarkMode,
                  blocks: _inboxBlocks,
                  onBlocksChanged: (updatedBlocks) async {
                    setState(() => _inboxBlocks = List.from(updatedBlocks));
                    await _saveInboxBlocks();
                  },
                ),
          ),
        ).then((_) => setState(() => _currentNavIndex = 0));
        break;
      case 2:
        // Navigate to Analytics
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => AnalyticsPage(isDarkMode: _isDarkMode, tasks: _tasks),
          ),
        ).then((_) => setState(() => _currentNavIndex = 0));
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => CalendarPage(isDarkMode: _isDarkMode, tasks: _tasks),
          ),
        ).then((_) => setState(() => _currentNavIndex = 3));
        break;
      case 4:
        // Navigate to Categories page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => CategoriesPage(
                  isDarkMode: _isDarkMode,
                  categories: _categories,
                  tasks: _tasks,
                  onCategoriesChanged: (updatedCategories) {
                    setState(() => _categories = List.from(updatedCategories));
                    _saveCategories();
                  },
                  onTasksChanged: (updatedTasks) {
                    setState(() => _tasks = List.from(updatedTasks));
                    _saveTasks();
                  },
                ),
          ),
        ).then((_) async {
          setState(() => _currentNavIndex = 4);
          await _saveCategories();
        });
        break;
      case 5:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => SettingsPage(
                  isDarkMode: _isDarkMode,
                  preferences: _preferences,
                  onThemeToggle: _toggleTheme,
                  onPreferencesChanged: (preferences) {
                    setState(() {
                      _preferences = preferences;
                      _isDarkMode = preferences.isDarkMode;
                    });
                    _savePreferences();
                  },
                  categories: _categories,
                  onCategoriesChanged: (updatedCategories) {
                    setState(() => _categories = List.from(updatedCategories));
                    _saveCategories();
                  },
                  inboxBlocks: _inboxBlocks,
                  onInboxBlocksChanged: (updatedBlocks) {
                    setState(() => _inboxBlocks = List.from(updatedBlocks));
                    _saveInboxBlocks();
                  },
                  tasks: _tasks,
                  onTasksChanged: (updatedTasks) {
                    setState(() => _tasks = List.from(updatedTasks));
                    _saveTasks();
                  },
                ),
          ),
        ).then((_) => setState(() => _currentNavIndex = 5));
        break;
    }
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
      _preferences = _preferences.copyWith(isDarkMode: _isDarkMode);
    });
    _savePreferences();
  }

  Future<void> _editTask(Task task) async {
    final updatedTask = await Navigator.push<Task>(
      context,
      MaterialPageRoute(
        builder:
            (_) => AddTaskPage(
              isDarkMode: _isDarkMode,
              categories: _categories.map((c) => c.name).toList(),
              defaultPriority:
                  _preferences.defaultPriority == 'High'
                      ? Priority.high
                      : _preferences.defaultPriority == 'Low'
                      ? Priority.low
                      : Priority.medium,
              existingTask: task,
            ),
      ),
    );

    if (updatedTask != null) {
      setState(() {
        final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
        if (index != -1) {
          _tasks[index] = updatedTask;
        } else {
          _tasks.add(updatedTask);
        }
      });
      await _saveTasks();
    }
  }

  Future<void> _deleteTask(Task task) async {
    setState(() => _tasks.removeWhere((t) => t.id == task.id));
    await _saveTasks();
  }

  Future<void> _toggleTaskDone(Task task, bool value) async {
    setState(() {
      task.isDone = value;
      task.completedAt = value ? DateTime.now() : null;
    });
    await _saveTasks();
  }

  void _showTaskDeleteDialog(Task task) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Task'),
            content: Text('Delete "${task.title}"? This cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _deleteTask(task);
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sortedTasks = _sortedTasks(_tasks);
    final overdueTasks =
        sortedTasks
            .where((t) => !t.isDone && _dateOnly(t.dueDate).isBefore(_today))
            .toList();
    final todayTasks =
        sortedTasks
            .where((t) => _dateOnly(t.dueDate) == _today)
            .toList();
    final tomorrowTasks =
        sortedTasks.where((t) => _dateOnly(t.dueDate) == _tomorrow).toList();
    final futureTasks =
        sortedTasks
            .where((t) => _dateOnly(t.dueDate).isAfter(_tomorrow))
            .toList();

    // Define colors based on theme
    final backgroundColor =
        _isDarkMode ? const Color(0xFF1A1A1A) : Colors.white;
    final textColor = _isDarkMode ? Colors.white : Colors.black;
    final cardColor = _isDarkMode ? const Color(0xFF2A2A2A) : Colors.grey[100];
    final subtleTextColor = _isDarkMode ? Colors.grey[400] : Colors.grey[600];

    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        title: Text(
          "checkList",
          style: TextStyle(fontWeight: FontWeight.w500, color: textColor),
        ),
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        elevation: 0,
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: Icon(Icons.menu, color: textColor),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        ),
        actions: [
          // Analytics Quick Access
          IconButton(
            icon: Icon(Icons.analytics_outlined, color: textColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) =>
                          AnalyticsPage(isDarkMode: _isDarkMode, tasks: _tasks),
                ),
              );
            },
          ),
          // Dark Mode Toggle
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return RotationTransition(
                    turns: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: Icon(
                  _isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  key: ValueKey(_isDarkMode),
                  color: textColor,
                ),
              ),
              onPressed: _toggleTheme,
            ),
          ),
        ],
      ),

      drawer: CustomNavbar(
        isDarkMode: _isDarkMode,
        onThemeToggle: _toggleTheme,
        onNavigate: _handleNavigation,
        currentIndex: _currentNavIndex,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            "My Todos",
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 25,
              color: textColor,
            ),
          ),
          const SizedBox(height: 10),

          if (overdueTasks.isNotEmpty) ...[
            _sectionTitle("Overdue", textColor, accentColor: Colors.redAccent),
            ...overdueTasks.map(
              (task) => _taskTile(
                task,
                cardColor,
                textColor,
                badgeText: 'Overdue',
                badgeColor: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 24),
          ],

          if (futureTasks.isNotEmpty) ...[
            _sectionTitle("Upcoming Tasks", textColor),
            ...futureTasks.map((task) => _taskTile(task, cardColor, textColor)),
            const SizedBox(height: 24),
          ],

          if (todayTasks.isNotEmpty) ...[
            _sectionTitle("Today", textColor),
            ...todayTasks.map((task) => _taskTile(task, cardColor, textColor)),
            const SizedBox(height: 24),
          ],

          if (tomorrowTasks.isNotEmpty) ...[
            _sectionTitle("Tomorrow", textColor),
            ...tomorrowTasks.map(
              (task) => _taskTile(task, cardColor, textColor),
            ),
          ],

          if (futureTasks.isEmpty &&
              overdueTasks.isEmpty &&
              todayTasks.isEmpty &&
              tomorrowTasks.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 100),
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 80,
                      color: subtleTextColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "No tasks yet\nTap + to add one",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: subtleTextColor, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: _isDarkMode ? Colors.white : Colors.black,
        child: Icon(
          Icons.add,
          color: _isDarkMode ? Colors.black : Colors.white,
        ),
        onPressed: () async {
          final task = await Navigator.push<Task>(
            context,
            MaterialPageRoute(
              builder:
                  (_) => AddTaskPage(
                    isDarkMode: _isDarkMode,
                    categories: _categories.map((c) => c.name).toList(),
                    defaultPriority:
                        _preferences.defaultPriority == 'High'
                            ? Priority.high
                            : _preferences.defaultPriority == 'Low'
                            ? Priority.low
                            : Priority.medium,
                  ),
            ),
          );

          if (task != null) {
            setState(() => _tasks.add(task));
            await _saveTasks();
          }
        },
      ),
    );
  }

  Widget _sectionTitle(
    String title,
    Color textColor, {
    Color? accentColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          if (accentColor != null) ...[
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: accentColor.withAlpha(28),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Needs attention',
                style: TextStyle(
                  color: accentColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _priorityColor(Priority priority) {
    switch (priority) {
      case Priority.high:
        return Colors.redAccent;
      case Priority.medium:
        return Colors.orangeAccent;
      case Priority.low:
        return Colors.green;
    }
  }

  String _priorityLabel(Priority priority) {
    switch (priority) {
      case Priority.high:
        return 'High';
      case Priority.medium:
        return 'Medium';
      case Priority.low:
        return 'Low';
    }
  }

  void _showTaskDetails(Task task, {String? badgeText, Color? badgeColor}) {
    final sheetBackground =
        _isDarkMode ? const Color(0xFF222222) : Colors.white;
    final sheetText = _isDarkMode ? Colors.white : Colors.black;
    final sheetSubtle =
        _isDarkMode ? Colors.grey[400]! : Colors.grey[600]!;
    final dividerColor =
        _isDarkMode ? const Color(0xFF363636) : const Color(0xFFEAEAEA);
    final priorityColor = _priorityColor(task.priority);

    showModalBottomSheet(
      context: context,
      backgroundColor: sheetBackground,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final sheetNavigator = Navigator.of(sheetContext);
        return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: dividerColor,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: task.isDone,
                        activeColor: _isDarkMode ? Colors.white : Colors.black,
                        checkColor: _isDarkMode ? Colors.black : Colors.white,
                        onChanged: (value) async {
                          await _toggleTaskDone(task, value ?? false);
                          if (!mounted) return;
                          sheetNavigator.pop();
                        },
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: sheetText,
                                decoration:
                                    task.isDone
                                        ? TextDecoration.lineThrough
                                        : null,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _detailChip(
                                  label: _dateLabel(task.dueDate),
                                  color: Colors.blueAccent,
                                ),
                                _detailChip(
                                  label: _priorityLabel(task.priority),
                                  color: priorityColor,
                                ),
                                if (task.list != null && task.list!.isNotEmpty)
                                  _detailChip(
                                    label: task.list!,
                                    color: Colors.purple,
                                  ),
                                if (badgeText != null && badgeColor != null)
                                  _detailChip(
                                    label: badgeText,
                                    color: badgeColor,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Description',
                    style: TextStyle(
                      color: sheetSubtle,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    task.description.trim().isEmpty
                        ? 'No description added.'
                        : task.description,
                    style: TextStyle(
                      color: sheetText,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            Navigator.pop(sheetContext);
                            await _editTask(task);
                          },
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Edit'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: sheetText,
                            side: BorderSide(color: dividerColor),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            Navigator.pop(sheetContext);
                            _showTaskDeleteDialog(task);
                          },
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Delete'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
      },
    );
  }

  String _dateLabel(DateTime value) {
    final date = _dateOnly(value);
    if (date == _today) return 'Today';
    if (date == _tomorrow) return 'Tomorrow';
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _detailChip({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(24),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _taskTile(
    Task task,
    Color? cardColor,
    Color textColor, {
    String? badgeText,
    Color? badgeColor,
  }) {
    return InkWell(
      onTap: () => _showTaskDetails(
        task,
        badgeText: badgeText,
        badgeColor: badgeColor,
      ),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Checkbox(
                value: task.isDone,
                activeColor: _isDarkMode ? Colors.white : Colors.black,
                checkColor: _isDarkMode ? Colors.black : Colors.white,
                side: BorderSide(
                  color: _isDarkMode ? Colors.grey[600]! : Colors.grey[400]!,
                  width: 2,
                ),
                onChanged: (v) async {
                  await _toggleTaskDone(task, v ?? false);
                },
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          task.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: textColor,
                            decoration:
                                task.isDone ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),
                      if (badgeText != null && badgeColor != null)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: badgeColor.withAlpha(28),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            badgeText,
                            style: TextStyle(
                              color: badgeColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _dateLabel(task.dueDate),
                    style: TextStyle(
                      color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit, color: textColor, size: 20),
              onPressed: () => _editTask(task),
              tooltip: 'Edit task',
            ),
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: Colors.redAccent,
                size: 20,
              ),
              onPressed: () => _showTaskDeleteDialog(task),
              tooltip: 'Delete task',
            ),
          ],
        ),
      ),
    );
  }
}
