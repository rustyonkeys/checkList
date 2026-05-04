import 'package:checklist/pages/calendar_page.dart';
import 'package:checklist/pages/categories.dart';
import 'package:checklist/pages/inbox_page.dart';
import 'package:checklist/pages/settings.dart';
import 'package:checklist/services/local_storage.dart';
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

class _HomePageState extends State<HomePage> {
  List<Task> _tasks = [];
  List<InboxBlock> _inboxBlocks = [];
  List<CategoryItem> _categories = [];
  AppPreferences _preferences = AppPreferences.defaults();
  bool _isDarkMode = false;
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadLocalData();
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
  }

  Future<void> _saveTasks() async {
    await LocalStorage.saveTasks(_tasks);
  }

  Future<void> _saveInboxBlocks() async {
    await LocalStorage.saveInboxBlocks(_inboxBlocks);
  }

  Future<void> _saveCategories() async {
    await LocalStorage.saveCategories(_categories);
  }

  Future<void> _savePreferences() async {
    await LocalStorage.savePreferences(_preferences);
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
    final todayTasks = sortedTasks.where((t) => t.dueDate == _today).toList();
    final tomorrowTasks =
        sortedTasks.where((t) => t.dueDate == _tomorrow).toList();
    final futureTasks =
        sortedTasks.where((t) => t.dueDate.isAfter(_tomorrow)).toList();

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

  Widget _sectionTitle(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _taskTile(Task task, Color? cardColor, Color textColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Checkbox(
            value: task.isDone,
            activeColor: _isDarkMode ? Colors.white : Colors.black,
            checkColor: _isDarkMode ? Colors.black : Colors.white,
            side: BorderSide(
              color: _isDarkMode ? Colors.grey[600]! : Colors.grey[400]!,
              width: 2,
            ),
            onChanged: (v) async {
              setState(() {
                task.isDone = v!;
                task.completedAt = task.isDone ? DateTime.now() : null;
              });
              await _saveTasks();
            },
          ),
          Expanded(
            child: Text(
              task.title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: textColor,
                decoration: task.isDone ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit, color: textColor, size: 20),
            onPressed: () => _editTask(task),
            tooltip: 'Edit task',
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
            onPressed: () => _showTaskDeleteDialog(task),
            tooltip: 'Delete task',
          ),
        ],
      ),
    );
  }
}
