import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const SettingsPage({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  String _defaultPriority = 'Medium';
  String _taskSortBy = 'Due Date';
  bool _autoDeleteCompleted = false;
  int _autoDeleteDays = 7;

  @override
  Widget build(BuildContext context) {
    // Theme colors
    final backgroundColor = widget.isDarkMode ? const Color(0xFF1A1A1A) : Colors.grey[50];
    final cardColor = widget.isDarkMode ? const Color(0xFF2A2A2A) : Colors.white;
    final textColor = widget.isDarkMode ? Colors.white : Colors.black;
    final subtleTextColor = widget.isDarkMode ? Colors.grey[400] : Colors.grey[600];
    final borderColor = widget.isDarkMode ? Colors.grey[700]! : Colors.grey.shade200;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: cardColor,
        title: Text(
          'Settings',
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
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Appearance Section
          _buildSectionHeader('Appearance', textColor),
          _buildSettingsCard(
            cardColor: cardColor,
            borderColor: borderColor,
            children: [
              _buildSwitchTile(
                title: 'Dark Mode',
                subtitle: 'Switch between light and dark theme',
                icon: widget.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                value: widget.isDarkMode,
                onChanged: (_) => widget.onThemeToggle(),
                textColor: textColor,
                subtleTextColor: subtleTextColor,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Notifications Section
          _buildSectionHeader('Notifications', textColor),
          _buildSettingsCard(
            cardColor: cardColor,
            borderColor: borderColor,
            children: [
              _buildSwitchTile(
                title: 'Enable Notifications',
                subtitle: 'Receive task reminders',
                icon: Icons.notifications_outlined,
                value: _notificationsEnabled,
                onChanged: (v) => setState(() => _notificationsEnabled = v),
                textColor: textColor,
                subtleTextColor: subtleTextColor,
              ),
              _buildDivider(borderColor),
              _buildSwitchTile(
                title: 'Sound',
                subtitle: 'Play sound for notifications',
                icon: Icons.volume_up_outlined,
                value: _soundEnabled,
                onChanged: (v) => setState(() => _soundEnabled = v),
                enabled: _notificationsEnabled,
                textColor: textColor,
                subtleTextColor: subtleTextColor,
              ),
              _buildDivider(borderColor),
              _buildSwitchTile(
                title: 'Vibration',
                subtitle: 'Vibrate for notifications',
                icon: Icons.vibration_outlined,
                value: _vibrationEnabled,
                onChanged: (v) => setState(() => _vibrationEnabled = v),
                enabled: _notificationsEnabled,
                textColor: textColor,
                subtleTextColor: subtleTextColor,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Task Preferences Section
          _buildSectionHeader('Task Preferences', textColor),
          _buildSettingsCard(
            cardColor: cardColor,
            borderColor: borderColor,
            children: [
              _buildDropdownTile(
                title: 'Default Priority',
                subtitle: 'Set default task priority',
                icon: Icons.flag_outlined,
                value: _defaultPriority,
                items: ['High', 'Medium', 'Low'],
                onChanged: (v) => setState(() => _defaultPriority = v!),
                textColor: textColor,
                subtleTextColor: subtleTextColor,
              ),
              _buildDivider(borderColor),
              _buildDropdownTile(
                title: 'Sort Tasks By',
                subtitle: 'Default task sorting',
                icon: Icons.sort_outlined,
                value: _taskSortBy,
                items: ['Due Date', 'Priority', 'Created Date', 'Alphabetical'],
                onChanged: (v) => setState(() => _taskSortBy = v!),
                textColor: textColor,
                subtleTextColor: subtleTextColor,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Data Management Section
          _buildSectionHeader('Data Management', textColor),
          _buildSettingsCard(
            cardColor: cardColor,
            borderColor: borderColor,
            children: [
              _buildSwitchTile(
                title: 'Auto-delete Completed',
                subtitle: 'Automatically delete old completed tasks',
                icon: Icons.delete_sweep_outlined,
                value: _autoDeleteCompleted,
                onChanged: (v) => setState(() => _autoDeleteCompleted = v),
                textColor: textColor,
                subtleTextColor: subtleTextColor,
              ),
              if (_autoDeleteCompleted) ...[
                _buildDivider(borderColor),
                _buildSliderTile(
                  title: 'Delete After',
                  subtitle: '$_autoDeleteDays days',
                  icon: Icons.calendar_today_outlined,
                  value: _autoDeleteDays.toDouble(),
                  min: 1,
                  max: 30,
                  divisions: 29,
                  onChanged: (v) => setState(() => _autoDeleteDays = v.toInt()),
                  textColor: textColor,
                  subtleTextColor: subtleTextColor,
                ),
              ],
            ],
          ),

          const SizedBox(height: 24),

          // Actions Section
          _buildSectionHeader('Actions', textColor),
          _buildSettingsCard(
            cardColor: cardColor,
            borderColor: borderColor,
            children: [
              _buildActionTile(
                title: 'Export Data',
                subtitle: 'Export all tasks as JSON',
                icon: Icons.upload_outlined,
                onTap: () => _showSnackbar('Export feature coming soon'),
                textColor: textColor,
                subtleTextColor: subtleTextColor,
              ),
              _buildDivider(borderColor),
              _buildActionTile(
                title: 'Import Data',
                subtitle: 'Import tasks from file',
                icon: Icons.download_outlined,
                onTap: () => _showSnackbar('Import feature coming soon'),
                textColor: textColor,
                subtleTextColor: subtleTextColor,
              ),
              _buildDivider(borderColor),
              _buildActionTile(
                title: 'Clear All Completed',
                subtitle: 'Remove all completed tasks',
                icon: Icons.clear_all_outlined,
                iconColor: Colors.orange,
                onTap: () => _showDeleteDialog(
                  'Clear Completed Tasks',
                  'Are you sure you want to delete all completed tasks?',
                ),
                textColor: textColor,
                subtleTextColor: subtleTextColor,
              ),
              _buildDivider(borderColor),
              _buildActionTile(
                title: 'Delete All Tasks',
                subtitle: 'Permanently delete all tasks',
                icon: Icons.delete_forever_outlined,
                iconColor: Colors.red,
                onTap: () => _showDeleteDialog(
                  'Delete All Tasks',
                  'This will permanently delete ALL tasks. This action cannot be undone.',
                ),
                textColor: textColor,
                subtleTextColor: subtleTextColor,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // About Section
          _buildSectionHeader('About', textColor),
          _buildSettingsCard(
            cardColor: cardColor,
            borderColor: borderColor,
            children: [
              _buildActionTile(
                title: 'Version',
                subtitle: '1.0.0',
                icon: Icons.info_outlined,
                showArrow: false,
                onTap: () {},
                textColor: textColor,
                subtleTextColor: subtleTextColor,
              ),
              _buildDivider(borderColor),
              _buildActionTile(
                title: 'Privacy Policy',
                subtitle: 'View our privacy policy',
                icon: Icons.privacy_tip_outlined,
                onTap: () => _showSnackbar('Privacy policy page coming soon'),
                textColor: textColor,
                subtleTextColor: subtleTextColor,
              ),
              _buildDivider(borderColor),
              _buildActionTile(
                title: 'Terms of Service',
                subtitle: 'View terms of service',
                icon: Icons.description_outlined,
                onTap: () => _showSnackbar('Terms of service page coming soon'),
                textColor: textColor,
                subtleTextColor: subtleTextColor,
              ),
            ],
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textColor.withOpacity(0.7),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required Color cardColor,
    required Color borderColor,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required Function(bool) onChanged,
    required Color textColor,
    required Color? subtleTextColor,
    bool enabled = true,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Icon(icon, color: enabled ? textColor : subtleTextColor),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: enabled ? textColor : subtleTextColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 13, color: subtleTextColor),
      ),
      trailing: Switch(
        value: value,
        onChanged: enabled ? onChanged : null,
        activeColor: widget.isDarkMode ? Colors.white : Colors.black,
        activeTrackColor: widget.isDarkMode ? Colors.grey[700] : Colors.grey[300],
      ),
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    required Color textColor,
    required Color? subtleTextColor,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Icon(icon, color: textColor),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 13, color: subtleTextColor),
      ),
      trailing: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        dropdownColor: widget.isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSliderTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required Function(double) onChanged,
    required Color textColor,
    required Color? subtleTextColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: textColor, size: 22),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 13, color: subtleTextColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            activeColor: widget.isDarkMode ? Colors.white : Colors.black,
            inactiveColor: widget.isDarkMode ? Colors.grey[700] : Colors.grey[300],
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required Color textColor,
    required Color? subtleTextColor,
    Color? iconColor,
    bool showArrow = true,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Icon(icon, color: iconColor ?? textColor),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 13, color: subtleTextColor),
      ),
      trailing: showArrow
          ? Icon(Icons.arrow_forward_ios, size: 16, color: subtleTextColor)
          : null,
      onTap: onTap,
    );
  }

  Widget _buildDivider(Color borderColor) {
    return Divider(height: 1, thickness: 1, color: borderColor);
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showDeleteDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: widget.isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
        title: Text(
          title,
          style: TextStyle(
            color: widget.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        content: Text(
          message,
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
              Navigator.pop(context);
              _showSnackbar('Action confirmed');
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
}