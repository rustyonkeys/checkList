import 'package:flutter/material.dart';

class CustomNavbar extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;
  final Function(int) onNavigate;
  final int currentIndex;

  const CustomNavbar({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
    required this.onNavigate,
    this.currentIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isDarkMode ? const Color(0xFF1A1A1A) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final subtleTextColor = isDarkMode ? Colors.grey[400] : Colors.grey[600];
    final selectedColor = isDarkMode ? Colors.white : Colors.black;
    final selectedBgColor = isDarkMode
        ? Colors.white.withOpacity(0.1)
        : Colors.black.withOpacity(0.05);

    return Drawer(
      backgroundColor: backgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDarkMode
                                ? [Colors.deepPurple.shade700, Colors.deepPurple.shade500]
                                : [Colors.orange.shade800, Colors.orange.shade600],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'checkList',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            Text(
                              'Stay organized',
                              style: TextStyle(
                                fontSize: 12,
                                color: subtleTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Divider(
              color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
              thickness: 1,
              height: 1,
            ),

            // Navigation Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildNavItem(
                    icon: Icons.home_outlined,
                    selectedIcon: Icons.home,
                    title: 'Home',
                    isSelected: currentIndex == 0,
                    onTap: () => onNavigate(0),
                    textColor: textColor,
                    selectedColor: selectedColor,
                    selectedBgColor: selectedBgColor,
                  ),
                  _buildNavItem(
                    icon: Icons.analytics_outlined,
                    selectedIcon: Icons.analytics,
                    title: 'Analytics',
                    isSelected: currentIndex == 1,
                    onTap: () => onNavigate(1),
                    textColor: textColor,
                    selectedColor: selectedColor,
                    selectedBgColor: selectedBgColor,
                  ),
                  _buildNavItem(
                    icon: Icons.calendar_today_outlined,
                    selectedIcon: Icons.calendar_today,
                    title: 'Calendar',
                    isSelected: currentIndex == 2,
                    onTap: () => onNavigate(2),
                    textColor: textColor,
                    selectedColor: selectedColor,
                    selectedBgColor: selectedBgColor,
                  ),
                  _buildNavItem(
                    icon: Icons.category_outlined,
                    selectedIcon: Icons.category,
                    title: 'Categories',
                    isSelected: currentIndex == 3,
                    onTap: () => onNavigate(3),
                    textColor: textColor,
                    selectedColor: selectedColor,
                    selectedBgColor: selectedBgColor,
                  ),

                  const SizedBox(height: 16),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'SETTINGS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: subtleTextColor,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),

                  _buildNavItem(
                    icon: Icons.settings_outlined,
                    selectedIcon: Icons.settings,
                    title: 'Settings',
                    isSelected: currentIndex == 4,
                    onTap: () => onNavigate(4),
                    textColor: textColor,
                    selectedColor: selectedColor,
                    selectedBgColor: selectedBgColor,
                  ),
                ],
              ),
            ),

            // Footer
            Divider(
              color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
              thickness: 1,
              height: 1,
            ),

            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Theme Toggle
                  InkWell(
                    onTap: onThemeToggle,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: selectedBgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isDarkMode ? Icons.light_mode : Icons.dark_mode,
                            color: textColor,
                            size: 22,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            isDarkMode ? 'Light Mode' : 'Dark Mode',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: textColor,
                            ),
                          ),
                          const Spacer(),
                          Switch(
                            value: isDarkMode,
                            onChanged: (_) => onThemeToggle(),
                            activeColor: Colors.white,
                            activeTrackColor: Colors.grey[700],
                            inactiveThumbColor: Colors.black,
                            inactiveTrackColor: Colors.grey[300],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: subtleTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData selectedIcon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required Color textColor,
    required Color selectedColor,
    required Color selectedBgColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? selectedBgColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? selectedIcon : icon,
                color: isSelected ? selectedColor : textColor.withOpacity(0.7),
                size: 24,
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? selectedColor : textColor.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}