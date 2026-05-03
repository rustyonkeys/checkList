import 'package:flutter/material.dart';
import 'package:checklist/services/local_storage.dart';
import 'package:checklist/util/task.dart';

class CategoriesPage extends StatefulWidget {
  final bool isDarkMode;
  final List<CategoryItem> categories;
  final List<Task> tasks;
  final ValueChanged<List<CategoryItem>> onCategoriesChanged;
  final ValueChanged<List<Task>> onTasksChanged;

  const CategoriesPage({
    super.key,
    required this.isDarkMode,
    required this.categories,
    required this.tasks,
    required this.onCategoriesChanged,
    required this.onTasksChanged,
  });

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  void _notifyCategoriesChanged() {
    widget.onCategoriesChanged(List<CategoryItem>.from(widget.categories));
  }

  void _notifyTasksChanged() {
    widget.onTasksChanged(List<Task>.from(widget.tasks));
  }

  bool _categoryNameExists(String name, {CategoryItem? except}) {
    final normalized = name.trim().toLowerCase();
    return widget.categories.any(
      (category) =>
          category != except && category.name.trim().toLowerCase() == normalized,
    );
  }

  int _countTasks(CategoryItem category) {
    return widget.tasks.where((task) => task.list == category.name).length;
  }

  int _countCompleted(CategoryItem category) {
    return widget.tasks
        .where((task) => task.list == category.name && task.isDone)
        .length;
  }

  int _totalTasks() {
    return widget.tasks
        .where(
          (task) =>
              widget.categories.any((category) => category.name == task.list),
        )
        .length;
  }

  int _totalCompleted() {
    return widget.tasks
        .where(
          (task) =>
              task.isDone &&
              widget.categories.any((category) => category.name == task.list),
        )
        .length;
  }

  @override
  Widget build(BuildContext context) {
    // Theme colors
    final backgroundColor =
        widget.isDarkMode ? const Color(0xFF1A1A1A) : Colors.grey[50];
    final cardColor =
        widget.isDarkMode ? const Color(0xFF2A2A2A) : Colors.white;
    final textColor = widget.isDarkMode ? Colors.white : Colors.black;
    final subtleTextColor =
        widget.isDarkMode ? Colors.grey[400] : Colors.grey[600];
    final borderColor =
        widget.isDarkMode ? Colors.grey[700]! : Colors.grey.shade200;

    // Calculate total stats
    final totalTasks = _totalTasks();
    final totalCompleted = _totalCompleted();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: cardColor,
        title: Text(
          'Categories',
          style: TextStyle(
            color: textColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: textColor),
            onPressed:
                () => _showAddCategoryDialog(
                  cardColor,
                  textColor,
                  subtleTextColor,
                ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Overview Card
            _buildOverviewCard(
              totalTasks,
              totalCompleted,
              cardColor,
              borderColor,
              textColor,
              subtleTextColor,
            ),

            const SizedBox(height: 24),

            // Categories Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child:
                  widget.categories.isEmpty
                      ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 48,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: borderColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.category_outlined,
                              size: 40,
                              color: subtleTextColor,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No categories yet',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap + to add your own categories',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: subtleTextColor,
                              ),
                            ),
                          ],
                        ),
                      )
                      : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1.1,
                            ),
                        itemCount: widget.categories.length,
                        itemBuilder: (context, index) {
                          return _buildCategoryCard(
                            widget.categories[index],
                            cardColor,
                            borderColor,
                            textColor,
                            subtleTextColor,
                          );
                        },
                      ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard(
    int totalTasks,
    int totalCompleted,
    Color cardColor,
    Color borderColor,
    Color textColor,
    Color? subtleTextColor,
  ) {
    final completionRate =
        totalTasks > 0 ? ((totalCompleted / totalTasks) * 100).toInt() : 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:
              widget.isDarkMode
                  ? [Colors.deepPurple.shade700, Colors.deepPurple.shade500]
                  : [Colors.orange.shade800, Colors.orange.shade600],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Overview',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$totalTasks',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total Tasks',
                      style: TextStyle(
                        color: const Color.fromRGBO(255, 255, 255, 0.8),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$totalCompleted',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Completed',
                      style: TextStyle(
                        color: const Color.fromRGBO(255, 255, 255, 0.8),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(255, 255, 255, 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$completionRate%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    CategoryItem category,
    Color cardColor,
    Color borderColor,
    Color textColor,
    Color? subtleTextColor,
  ) {
    final categoryTaskCount = _countTasks(category);
    final categoryCompletedCount = _countCompleted(category);
    final completionRate =
        categoryTaskCount > 0
            ? (categoryCompletedCount / categoryTaskCount)
            : 0.0;

    return InkWell(
      onTap:
          () => _showCategoryDetails(
            category,
            cardColor,
            textColor,
            subtleTextColor,
          ),
      onLongPress:
          () => _showCategoryOptions(
            category,
            cardColor,
            textColor,
            subtleTextColor,
          ),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: category.color.withAlpha(26),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(category.icon, color: category.color, size: 24),
                ),
                IconButton(
                  icon: Icon(Icons.more_vert, color: subtleTextColor, size: 20),
                  onPressed:
                      () => _showCategoryOptions(
                        category,
                        cardColor,
                        textColor,
                        subtleTextColor,
                      ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const Spacer(),
            Text(
              category.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$categoryTaskCount tasks',
              style: TextStyle(fontSize: 12, color: subtleTextColor),
            ),
            const SizedBox(height: 8),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: completionRate,
                backgroundColor:
                    widget.isDarkMode ? Colors.grey[700] : Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(category.color),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$categoryCompletedCount/$categoryTaskCount completed',
              style: TextStyle(fontSize: 11, color: subtleTextColor),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryDetails(
    CategoryItem category,
    Color cardColor,
    Color textColor,
    Color? subtleTextColor,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: category.color.withAlpha(26),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(category.icon, color: category.color, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        Text(
                          '${_countTasks(category)} total tasks',
                          style: TextStyle(
                            fontSize: 14,
                            color: subtleTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildDetailRow(
                'Total Tasks',
                _countTasks(category).toString(),
                Icons.list_alt,
                textColor,
                subtleTextColor,
              ),
              const SizedBox(height: 16),
              _buildDetailRow(
                'Completed',
                _countCompleted(category).toString(),
                Icons.check_circle,
                textColor,
                subtleTextColor,
              ),
              const SizedBox(height: 16),
              _buildDetailRow(
                'Pending',
                (_countTasks(category) - _countCompleted(category)).toString(),
                Icons.pending,
                textColor,
                subtleTextColor,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: category.color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => CategoryTasksPage(
                              isDarkMode: widget.isDarkMode,
                              category: category,
                              tasks:
                                  widget.tasks
                                      .where(
                                        (task) => task.list == category.name,
                                      )
                                      .toList(),
                            ),
                      ),
                    );
                  },
                  child: const Text(
                    'View Tasks',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon,
    Color textColor,
    Color? subtleTextColor,
  ) {
    return Row(
      children: [
        Icon(icon, color: subtleTextColor, size: 20),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(fontSize: 15, color: subtleTextColor)),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }

  void _showCategoryOptions(
    CategoryItem category,
    Color cardColor,
    Color textColor,
    Color? subtleTextColor,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit, color: textColor),
              title: Text('Edit Category', style: TextStyle(color: textColor)),
              onTap: () {
                Navigator.pop(context);
                _showEditCategoryDialog(
                  category,
                  cardColor,
                  textColor,
                  subtleTextColor,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Delete Category',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(category);
              },
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  void _showAddCategoryDialog(
    Color cardColor,
    Color textColor,
    Color? subtleTextColor,
  ) {
    final nameController = TextEditingController();
    Color selectedColor = Colors.blue;
    IconData selectedIcon = Icons.category;
    String? errorText;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
        return AlertDialog(
          backgroundColor: cardColor,
          title: Text('Add Category', style: TextStyle(color: textColor)),
          content: TextField(
            controller: nameController,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              hintText: 'Category name',
              hintStyle: TextStyle(color: subtleTextColor),
              errorText: errorText,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: textColor)),
            ),
            TextButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) {
                  setDialogState(() => errorText = 'Enter a category name');
                  return;
                }
                if (_categoryNameExists(name)) {
                  setDialogState(() => errorText = 'Category already exists');
                  return;
                }

                  setState(() {
                    widget.categories.add(
                      CategoryItem(
                        name: name,
                        icon: selectedIcon,
                        color: selectedColor,
                        taskCount: 0,
                        completedCount: 0,
                      ),
                    );
                  });
                  Navigator.pop(context);
                  await LocalStorage.saveCategories(widget.categories);
                  _notifyCategoriesChanged();
              },
              child: Text('Add', style: TextStyle(color: textColor)),
            ),
          ],
        );
          },
        );
      },
    );
  }

  void _showEditCategoryDialog(
    CategoryItem category,
    Color cardColor,
    Color textColor,
    Color? subtleTextColor,
  ) {
    final nameController = TextEditingController(text: category.name);
    String? errorText;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: cardColor,
              title: Text('Edit Category', style: TextStyle(color: textColor)),
              content: TextField(
                controller: nameController,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: 'Category name',
                  hintStyle: TextStyle(color: subtleTextColor),
                  errorText: errorText,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: TextStyle(color: textColor)),
                ),
                TextButton(
                  onPressed: () async {
                    final newName = nameController.text.trim();
                    if (newName.isEmpty) {
                      setDialogState(
                        () => errorText = 'Enter a category name',
                      );
                      return;
                    }
                    if (_categoryNameExists(newName, except: category)) {
                      setDialogState(
                        () => errorText = 'Category already exists',
                      );
                      return;
                    }

                    final oldName = category.name;
                    setState(() {
                      category.name = newName;
                      for (final task in widget.tasks) {
                        if (task.list == oldName) {
                          task.list = newName;
                        }
                      }
                    });
                    Navigator.pop(context);
                    await LocalStorage.saveCategories(widget.categories);
                    await LocalStorage.saveTasks(widget.tasks);
                    _notifyCategoriesChanged();
                    _notifyTasksChanged();
                  },
                  child: Text('Save', style: TextStyle(color: textColor)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmation(CategoryItem category) {
    final affectedTasks = _countTasks(category);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor:
              widget.isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
          title: Text(
            'Delete Category',
            style: TextStyle(
              color: widget.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          content: Text(
            affectedTasks == 0
                ? 'Delete "${category.name}"? This cannot be undone.'
                : 'Delete "${category.name}"? $affectedTasks tasks will be kept and moved to No List.',
            style: TextStyle(
              color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: widget.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                final navigator = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);
                final categoryName = category.name;
                setState(() {
                  for (final task in widget.tasks) {
                    if (task.list == categoryName) {
                      task.list = null;
                    }
                  }
                  widget.categories.remove(category);
                });
                await LocalStorage.saveCategories(widget.categories);
                await LocalStorage.saveTasks(widget.tasks);
                navigator.pop();
                _notifyCategoriesChanged();
                _notifyTasksChanged();
                messenger.showSnackBar(
                  SnackBar(content: Text('$categoryName deleted')),
                );
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

class CategoryTasksPage extends StatelessWidget {
  final bool isDarkMode;
  final CategoryItem category;
  final List<Task> tasks;

  const CategoryTasksPage({
    super.key,
    required this.isDarkMode,
    required this.category,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isDarkMode ? const Color(0xFF1A1A1A) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final cardColor = isDarkMode ? const Color(0xFF2A2A2A) : Colors.grey[100];
    final subtleTextColor = isDarkMode ? Colors.grey[400] : Colors.grey[600];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${category.name} Tasks',
          style: TextStyle(color: textColor),
        ),
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        elevation: 0,
      ),
      backgroundColor: backgroundColor,
      body:
          tasks.isEmpty
              ? Center(
                child: Text(
                  'No tasks found for ${category.name}',
                  style: TextStyle(color: subtleTextColor, fontSize: 16),
                ),
              )
              : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: tasks.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          task.description.isNotEmpty
                              ? task.description
                              : 'No description',
                          style: TextStyle(color: subtleTextColor),
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
                                color: category.color.withAlpha(41),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                task.priority.name.toUpperCase(),
                                style: TextStyle(
                                  color: category.color,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${task.dueDate.month}/${task.dueDate.day}/${task.dueDate.year}',
                              style: TextStyle(color: subtleTextColor),
                            ),
                            const Spacer(),
                            Icon(
                              task.isDone
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                              color:
                                  task.isDone
                                      ? category.color
                                      : subtleTextColor,
                              size: 20,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }
}

class CategoryItem {
  static const Map<String, IconData> _iconRegistry = {
    'category': Icons.category,
    'work_outline': Icons.work_outline,
    'person_outline': Icons.person_outline,
    'school_outlined': Icons.school_outlined,
    'favorite_outline': Icons.favorite_outline,
    'shopping_cart_outlined': Icons.shopping_cart_outlined,
  };

  String name;
  IconData icon;
  Color color;
  int taskCount;
  int completedCount;

  CategoryItem({
    required this.name,
    required this.icon,
    required this.color,
    required this.taskCount,
    required this.completedCount,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'iconKey': _iconKeyFor(icon),
      'colorValue': color.toARGB32(),
      'taskCount': taskCount,
      'completedCount': completedCount,
    };
  }

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    return CategoryItem(
      name: json['name'] as String,
      icon: _iconFromJson(json),
      color: Color(json['colorValue'] as int),
      taskCount: json['taskCount'] as int? ?? 0,
      completedCount: json['completedCount'] as int? ?? 0,
    );
  }

  static String _iconKeyFor(IconData icon) {
    for (final entry in _iconRegistry.entries) {
      if (entry.value.codePoint == icon.codePoint) {
        return entry.key;
      }
    }
    return 'category';
  }

  static IconData _iconFromJson(Map<String, dynamic> json) {
    final iconKey = json['iconKey'] as String?;
    if (iconKey != null) {
      return _iconRegistry[iconKey] ?? Icons.category;
    }

    // Legacy compatibility for categories saved before icon keys were added.
    final legacyCodePoint = json['iconCodePoint'] as int?;
    for (final entry in _iconRegistry.entries) {
      if (entry.value.codePoint == legacyCodePoint) {
        return entry.value;
      }
    }
    return Icons.category;
  }
}
