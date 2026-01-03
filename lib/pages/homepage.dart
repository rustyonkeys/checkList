import 'package:checklist/pages/addtaskpage.dart';
import 'package:checklist/util/navbar.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

// Todo Model
class TodoItem {
  int id;
  String title;
  String category;
  String time;
  String? description;
  bool completed;
  bool isToday;
  bool isTomorrow;
  bool isPriority;

  TodoItem({
    required this.id,
    required this.title,
    required this.category,
    required this.time,
    this.description,
    this.completed = false,
    this.isToday = false,
    this.isTomorrow = false,
    this.isPriority = false,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Sample todos - Start with empty list or add tasks
  List<TodoItem> _todos = [
    TodoItem(
      id: 1,
      title: 'Meeting with Dev Team',
      category: 'work',
      time: '10:00 AM',
      isToday: true,
    ),
    TodoItem(
      id: 2,
      title: 'Buy Groceries',
      category: 'personal',
      time: '5:00 PM',
      isToday: true,
    ),
    TodoItem(
      id: 3,
      title: 'Finalize Project Proposal',
      category: 'priority',
      time: '1:00 PM',
      isToday: true,
      isPriority: true,
    ),
    TodoItem(
      id: 4,
      title: 'Morning Gym Session',
      category: 'health',
      time: '7:00 AM',
      isTomorrow: true,
    ),
  ];

  void _onTabSelected(int index) {
    if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AddTaskPage(),
        ),
      );
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  void _toggleTodo(int id) {
    setState(() {
      final index = _todos.indexWhere((todo) => todo.id == id);
      if (index != -1) {
        _todos[index].completed = !_todos[index].completed;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check if there are any tasks
    final hasAnyTasks = _todos.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: hasAnyTasks ? _buildHomeWithTasks() : _buildEmptyState(),
      bottomNavigationBar: LiquidGlassNavbar(
        selectedIndex: _selectedIndex,
        onTabSelected: _onTabSelected,
      ),
    );
  }

  // Empty State UI (like image 2)
  Widget _buildEmptyState() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0F172A)],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Icon(Icons.menu, color: Colors.white, size: 24),
                  Text(
                    'My Day',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 24),
                ],
              ),
            ),

            // Empty State Content
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Glass Diamond Animation
                      SizedBox(
                        width: 280,
                        height: 280,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer glow
                            Container(
                              width: 220,
                              height: 220,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF22D3EE).withOpacity(0.2),
                                    const Color(0xFF3B82F6).withOpacity(0.2),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(32),
                              ),
                            ),
                            // Rotated diamond
                            Transform.rotate(
                              angle: 0.785398, // 45 degrees
                              child: Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [Color(0xFF22D3EE), Color(0xFF3B82F6)],
                                  ),
                                  borderRadius: BorderRadius.circular(28),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF22D3EE).withOpacity(0.5),
                                      blurRadius: 30,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Inner glow
                            Transform.rotate(
                              angle: -0.349066, // -20 degrees
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF3B82F6).withOpacity(0.6),
                                      const Color(0xFF22D3EE).withOpacity(0.6),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      const Text(
                        'All Caught Up',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Your list is empty. Take a break or start something new. Enjoy your free time!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade400,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Home with Tasks UI (like image 1)
  Widget _buildHomeWithTasks() {
    final todayTodos = _todos.where((t) => t.isToday).toList();
    final tomorrowTodos = _todos.where((t) => t.isTomorrow).toList();
    final completedCount = todayTodos.where((t) => t.completed).length;
    final progress = todayTodos.isEmpty ? 0.0 : completedCount / todayTodos.length;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0F172A)],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              _buildHeader(),
              const SizedBox(height: 24),
              _buildProgressCard(completedCount, todayTodos.length, progress),
              const SizedBox(height: 24),
              _buildFilterTabs(),
              const SizedBox(height: 24),
              _buildSectionHeader('Today', todayTodos.length),
              const SizedBox(height: 16),
              ...todayTodos.map((todo) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildTodoCard(todo),
              )),
              if (tomorrowTodos.isNotEmpty) ...[
                const SizedBox(height: 32),
                _buildSectionHeader('Tomorrow', tomorrowTodos.length),
                const SizedBox(height: 16),
                ...tomorrowTodos.map((todo) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildTodoCard(todo),
                )),
              ],
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF22D3EE), Color(0xFF3B82F6)],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
          ),
          child: Stack(
            children: [
              const Center(
                child: Text(
                  'A',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF10B981),
                    border: Border.all(color: const Color(0xFF1E293B), width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'GOOD MORNING',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF22D3EE),
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Alex',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const Spacer(),
        _buildGlassButton(const Icon(Icons.search, color: Colors.white70, size: 20)),
      ],
    );
  }

  Widget _buildGlassButton(Widget child) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B).withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildProgressCard(int completed, int total, double progress) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B).withOpacity(0.4),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily Goals',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$completed',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '/$total',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF22D3EE), Color(0xFF3B82F6)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF22D3EE).withOpacity(0.3),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.emoji_events, color: Colors.white, size: 32),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF22D3EE),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Stack(
                children: [
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF22D3EE), Color(0xFF3B82F6)],
                        ),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF22D3EE).withOpacity(0.5),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _selectedFilter = 'all';

  Widget _buildFilterTabs() {
    return Row(
      children: [
        _buildFilterChip('all', 'All'),
        const SizedBox(width: 12),
        _buildFilterChip('priority', 'Priority'),
        const SizedBox(width: 12),
        _buildFilterChip('done', 'Done'),
      ],
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(colors: [Color(0xFF22D3EE), Color(0xFF3B82F6)])
              : null,
          color: isSelected ? null : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(isSelected ? 0 : 0.1)),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: const Color(0xFF22D3EE).withOpacity(0.5),
              blurRadius: 16,
            )
          ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey.shade300,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTodoCard(TodoItem todo) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B).withOpacity(0.4),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => _toggleTodo(todo.id),
                child: Container(
                  width: 28,
                  height: 28,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: todo.completed
                        ? const LinearGradient(
                        colors: [Color(0xFF22D3EE), Color(0xFF3B82F6)])
                        : null,
                    border: Border.all(
                      color: todo.completed ? Colors.transparent : Colors.grey.shade600,
                      width: 2,
                    ),
                    boxShadow: todo.completed
                        ? [
                      BoxShadow(
                        color: const Color(0xFF3B82F6).withOpacity(0.5),
                        blurRadius: 8,
                      )
                    ]
                        : null,
                  ),
                  child: todo.completed
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      todo.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        decoration:
                        todo.completed ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(todo.category)
                                .withOpacity(todo.isPriority ? 0.2 : 0.25),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            todo.isPriority
                                ? 'HIGH PRIORITY'
                                : todo.category.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: todo.isPriority
                                  ? const Color(0xFFEF4444)
                                  : _getCategoryColor(todo.category),
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.access_time,
                            size: 16, color: Colors.grey.shade400),
                        const SizedBox(width: 4),
                        Text(
                          todo.time,
                          style: TextStyle(
                              fontSize: 14, color: Colors.grey.shade400),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (todo.isPriority)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 8),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFEF4444),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'work':
        return const Color(0xFF8B5CF6);
      case 'personal':
        return const Color(0xFF10B981);
      case 'health':
        return const Color(0xFF3B82F6);
      case 'priority':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }
}