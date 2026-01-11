import 'package:checklist/pages/categories.dart';
import 'package:checklist/pages/settings.dart';
import 'package:flutter/material.dart';
import 'package:checklist/pages/addtaskpage.dart';
// import 'package:checklist/pages/analyticspage.dart';
// import 'package:checklist/widgets/navbar.dart';
import 'package:checklist/util/task.dart';

import '../util/navbar.dart';
import 'analytic page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Task> _tasks = [];
  bool _isDarkMode = false;
  int _currentNavIndex = 0;

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
      // Navigate to Analytics
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AnalyticsPage(isDarkMode: _isDarkMode),
          ),
        ).then((_) => setState(() => _currentNavIndex = 0));
        break;
      case 2:
      // TODO: Navigate to Calendar page
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Calendar page coming soon!')),
        );
        break;
      case 3:
      // TODO: Navigate to Categories page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CategoriesPage(isDarkMode: _isDarkMode),
          ),
        ).then((_) => setState(() => _currentNavIndex = 3));
        break;
      case 4:
      // TODO: Navigate to Settings page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SettingsPage(isDarkMode: _isDarkMode, onThemeToggle: () {  },),
          ),
        ).then((_) => setState(() => _currentNavIndex = 4));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final todayTasks = _tasks.where((t) => t.dueDate == _today).toList();
    final tomorrowTasks = _tasks.where((t) => t.dueDate == _tomorrow).toList();
    final futureTasks = _tasks.where((t) => t.dueDate.isAfter(_tomorrow)).toList();

    // Define colors based on theme
    final backgroundColor = _isDarkMode ? const Color(0xFF1A1A1A) : Colors.white;
    final textColor = _isDarkMode ? Colors.white : Colors.black;
    final cardColor = _isDarkMode ? const Color(0xFF2A2A2A) : Colors.grey[100];
    final subtleTextColor = _isDarkMode ? Colors.grey[400] : Colors.grey[600];

    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        title: Text(
          "checkList",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
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
                  builder: (_) => AnalyticsPage(isDarkMode: _isDarkMode),
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
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
                child: Icon(
                  _isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  key: ValueKey(_isDarkMode),
                  color: textColor,
                ),
              ),
              onPressed: () {
                setState(() {
                  _isDarkMode = !_isDarkMode;
                });
              },
            ),
          ),
        ],
      ),

      drawer: CustomNavbar(
        isDarkMode: _isDarkMode,
        onThemeToggle: () {
          setState(() {
            _isDarkMode = !_isDarkMode;
          });
        },
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
            ...tomorrowTasks.map((task) => _taskTile(task, cardColor, textColor)),
          ],

          if (futureTasks.isEmpty && todayTasks.isEmpty && tomorrowTasks.isEmpty)
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
                      style: TextStyle(
                        color: subtleTextColor,
                        fontSize: 18,
                      ),
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
              builder: (_) => AddTaskPage(isDarkMode: _isDarkMode),
            ),
          );

          if (task != null) setState(() => _tasks.add(task));
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
        children: [
          Checkbox(
            value: task.isDone,
            activeColor: _isDarkMode ? Colors.white : Colors.black,
            checkColor: _isDarkMode ? Colors.black : Colors.white,
            side: BorderSide(
              color: _isDarkMode ? Colors.grey[600]! : Colors.grey[400]!,
              width: 2,
            ),
            onChanged: (v) => setState(() => task.isDone = v!),
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
        ],
      ),
    );
  }
}