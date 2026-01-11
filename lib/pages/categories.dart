import 'package:flutter/material.dart';

class CategoriesPage extends StatefulWidget {
  final bool isDarkMode;

  const CategoriesPage({super.key, required this.isDarkMode});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  // Sample categories with task counts
  final List<CategoryItem> _categories = [
    CategoryItem(
      name: 'Work',
      icon: Icons.work_outline,
      color: Colors.blue,
      taskCount: 12,
      completedCount: 8,
    ),
    CategoryItem(
      name: 'Personal',
      icon: Icons.person_outline,
      color: Colors.purple,
      taskCount: 8,
      completedCount: 5,
    ),
    CategoryItem(
      name: 'Health',
      icon: Icons.favorite_outline,
      color: Colors.teal,
      taskCount: 6,
      completedCount: 4,
    ),
    CategoryItem(
      name: 'Shopping',
      icon: Icons.shopping_cart_outlined,
      color: Colors.orange,
      taskCount: 4,
      completedCount: 2,
    ),
    CategoryItem(
      name: 'Study',
      icon: Icons.school_outlined,
      color: Colors.green,
      taskCount: 10,
      completedCount: 7,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Theme colors
    final backgroundColor = widget.isDarkMode ? const Color(0xFF1A1A1A) : Colors.grey[50];
    final cardColor = widget.isDarkMode ? const Color(0xFF2A2A2A) : Colors.white;
    final textColor = widget.isDarkMode ? Colors.white : Colors.black;
    final subtleTextColor = widget.isDarkMode ? Colors.grey[400] : Colors.grey[600];
    final borderColor = widget.isDarkMode ? Colors.grey[700]! : Colors.grey.shade200;

    // Calculate total stats
    final totalTasks = _categories.fold(0, (sum, cat) => sum + cat.taskCount);
    final totalCompleted = _categories.fold(0, (sum, cat) => sum + cat.completedCount);

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
            onPressed: () => _showAddCategoryDialog(cardColor, textColor, subtleTextColor),
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
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  return _buildCategoryCard(
                    _categories[index],
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
    final completionRate = totalTasks > 0
        ? ((totalCompleted / totalTasks) * 100).toInt()
        : 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.isDarkMode
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
                        color: Colors.white.withOpacity(0.8),
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
                        color: Colors.white.withOpacity(0.8),
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
                  color: Colors.white.withOpacity(0.2),
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
    final completionRate = category.taskCount > 0
        ? (category.completedCount / category.taskCount)
        : 0.0;

    return InkWell(
      onTap: () => _showCategoryDetails(category, cardColor, textColor, subtleTextColor),
      onLongPress: () => _showCategoryOptions(category, cardColor, textColor, subtleTextColor),
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
                    color: category.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    category.icon,
                    color: category.color,
                    size: 24,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.more_vert, color: subtleTextColor, size: 20),
                  onPressed: () => _showCategoryOptions(category, cardColor, textColor, subtleTextColor),
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
              '${category.taskCount} tasks',
              style: TextStyle(
                fontSize: 12,
                color: subtleTextColor,
              ),
            ),
            const SizedBox(height: 8),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: completionRate,
                backgroundColor: widget.isDarkMode
                    ? Colors.grey[700]
                    : Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(category.color),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${category.completedCount}/${category.taskCount} completed',
              style: TextStyle(
                fontSize: 11,
                color: subtleTextColor,
              ),
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
                      color: category.color.withOpacity(0.1),
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
                          '${category.taskCount} total tasks',
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
                category.taskCount.toString(),
                Icons.list_alt,
                textColor,
                subtleTextColor,
              ),
              const SizedBox(height: 16),
              _buildDetailRow(
                'Completed',
                category.completedCount.toString(),
                Icons.check_circle,
                textColor,
                subtleTextColor,
              ),
              const SizedBox(height: 16),
              _buildDetailRow(
                'Pending',
                (category.taskCount - category.completedCount).toString(),
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Viewing ${category.name} tasks'),
                      ),
                    );
                  },
                  child: const Text(
                    'View Tasks',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
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
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            color: subtleTextColor,
          ),
        ),
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
                _showEditCategoryDialog(category, cardColor, textColor, subtleTextColor);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Category', style: TextStyle(color: Colors.red)),
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

  void _showAddCategoryDialog(Color cardColor, Color textColor, Color? subtleTextColor) {
    final nameController = TextEditingController();
    Color selectedColor = Colors.blue;
    IconData selectedIcon = Icons.category;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: cardColor,
          title: Text('Add Category', style: TextStyle(color: textColor)),
          content: TextField(
            controller: nameController,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              hintText: 'Category name',
              hintStyle: TextStyle(color: subtleTextColor),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: textColor)),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  setState(() {
                    _categories.add(CategoryItem(
                      name: nameController.text,
                      icon: selectedIcon,
                      color: selectedColor,
                      taskCount: 0,
                      completedCount: 0,
                    ));
                  });
                  Navigator.pop(context);
                }
              },
              child: Text('Add', style: TextStyle(color: textColor)),
            ),
          ],
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

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: cardColor,
          title: Text('Edit Category', style: TextStyle(color: textColor)),
          content: TextField(
            controller: nameController,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              hintText: 'Category name',
              hintStyle: TextStyle(color: subtleTextColor),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: textColor)),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  setState(() {
                    category.name = nameController.text;
                  });
                  Navigator.pop(context);
                }
              },
              child: Text('Save', style: TextStyle(color: textColor)),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(CategoryItem category) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: widget.isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
          title: Text(
            'Delete Category',
            style: TextStyle(
              color: widget.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          content: Text(
            'Are you sure you want to delete "${category.name}"? This will not delete the tasks.',
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
              onPressed: () {
                setState(() {
                  _categories.remove(category);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${category.name} deleted')),
                );
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}

class CategoryItem {
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
}