import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:checklist/pages/categories.dart';
import 'package:checklist/services/local_storage.dart';
import 'package:checklist/util/task.dart';

class SettingsPage extends StatefulWidget {
  final bool isDarkMode;
  final AppPreferences preferences;
  final VoidCallback onThemeToggle;
  final ValueChanged<AppPreferences> onPreferencesChanged;
  final List<CategoryItem> categories;
  final ValueChanged<List<CategoryItem>> onCategoriesChanged;
  final List<Task> tasks;
  final ValueChanged<List<Task>> onTasksChanged;

  const SettingsPage({
    super.key,
    required this.isDarkMode,
    required this.preferences,
    required this.onThemeToggle,
    required this.onPreferencesChanged,
    required this.categories,
    required this.onCategoriesChanged,
    required this.tasks,
    required this.onTasksChanged,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool _notificationsEnabled;
  late bool _soundEnabled;
  late bool _vibrationEnabled;
  late String _defaultPriority;
  late String _taskSortBy;
  late bool _autoDeleteCompleted;
  late int _autoDeleteDays;

  @override
  void initState() {
    super.initState();
    _notificationsEnabled = widget.preferences.notificationsEnabled;
    _soundEnabled = widget.preferences.soundEnabled;
    _vibrationEnabled = widget.preferences.vibrationEnabled;
    _defaultPriority = widget.preferences.defaultPriority;
    _taskSortBy = widget.preferences.taskSortBy;
    _autoDeleteCompleted = widget.preferences.autoDeleteCompleted;
    _autoDeleteDays = widget.preferences.autoDeleteDays;
  }

  void _updatePreferences() {
    widget.onPreferencesChanged(
      widget.preferences.copyWith(
        notificationsEnabled: _notificationsEnabled,
        soundEnabled: _soundEnabled,
        vibrationEnabled: _vibrationEnabled,
        defaultPriority: _defaultPriority,
        taskSortBy: _taskSortBy,
        autoDeleteCompleted: _autoDeleteCompleted,
        autoDeleteDays: _autoDeleteDays,
      ),
    );
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
                onChanged:
                    (v) => setState(() {
                      _notificationsEnabled = v;
                      _updatePreferences();
                    }),
                textColor: textColor,
                subtleTextColor: subtleTextColor,
              ),
              _buildDivider(borderColor),
              _buildSwitchTile(
                title: 'Sound',
                subtitle: 'Play sound for notifications',
                icon: Icons.volume_up_outlined,
                value: _soundEnabled,
                onChanged:
                    (v) => setState(() {
                      _soundEnabled = v;
                      _updatePreferences();
                    }),
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
                onChanged:
                    (v) => setState(() {
                      _vibrationEnabled = v;
                      _updatePreferences();
                    }),
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
                onChanged:
                    (v) => setState(() {
                      _defaultPriority = v!;
                      _updatePreferences();
                    }),
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
                onChanged:
                    (v) => setState(() {
                      _taskSortBy = v!;
                      _updatePreferences();
                    }),
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
                onChanged:
                    (v) => setState(() {
                      _autoDeleteCompleted = v;
                      _updatePreferences();
                    }),
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
                  onChanged:
                      (v) => setState(() {
                        _autoDeleteDays = v.toInt();
                        _updatePreferences();
                      }),
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
                subtitle: 'Copy tasks, categories, and preferences as JSON',
                icon: Icons.upload_outlined,
                onTap: _exportData,
                textColor: textColor,
                subtleTextColor: subtleTextColor,
              ),
              _buildDivider(borderColor),
              _buildActionTile(
                title: 'Import Data',
                subtitle: 'Replace local data from pasted JSON',
                icon: Icons.download_outlined,
                onTap: _showImportDialog,
                textColor: textColor,
                subtleTextColor: subtleTextColor,
              ),
              _buildDivider(borderColor),
              _buildActionTile(
                title: 'Clear All Completed',
                subtitle: 'Remove all completed tasks',
                icon: Icons.clear_all_outlined,
                iconColor: Colors.orange,
                onTap:
                    () => _showDeleteDialog(
                      'Clear Completed Tasks',
                      'Are you sure you want to delete all completed tasks?',
                      _clearCompletedTasks,
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
                onTap:
                    () => _showDeleteDialog(
                      'Delete All Tasks',
                      'This will permanently delete ALL tasks. This action cannot be undone.',
                      _deleteAllTasks,
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
                onTap:
                    () => _showInfoPage(
                      'Privacy Policy',
                      'This app keeps your data local and private. We store tasks on device only, and do not share your data.',
                    ),
                textColor: textColor,
                subtleTextColor: subtleTextColor,
              ),
              _buildDivider(borderColor),
              _buildActionTile(
                title: 'Terms of Service',
                subtitle: 'View terms of service',
                icon: Icons.description_outlined,
                onTap:
                    () => _showInfoPage(
                      'Terms of Service',
                      'Use of this app is subject to local device storage only. All user data remains on your device.',
                    ),
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
          color: textColor.withAlpha(179),
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
        activeTrackColor:
            widget.isDarkMode ? Colors.grey[700] : Colors.grey[300],
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
        dropdownColor:
            widget.isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        items:
            items.map((item) {
              return DropdownMenuItem(value: item, child: Text(item));
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
            inactiveColor:
                widget.isDarkMode ? Colors.grey[700] : Colors.grey[300],
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
      trailing:
          showArrow
              ? Icon(Icons.arrow_forward_ios, size: 16, color: subtleTextColor)
              : null,
      onTap: onTap,
    );
  }

  Widget _buildDivider(Color borderColor) {
    return Divider(height: 1, thickness: 1, color: borderColor);
  }

  void _showInfoPage(String title, String content) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => Scaffold(
              appBar: AppBar(
                title: Text(title),
                backgroundColor:
                    widget.isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
                foregroundColor:
                    widget.isDarkMode ? Colors.white : Colors.black,
                elevation: 0,
              ),
              backgroundColor:
                  widget.isDarkMode ? const Color(0xFF121212) : Colors.white,
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Text(
                  content,
                  style: TextStyle(
                    color: widget.isDarkMode ? Colors.white : Colors.black,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ),
            ),
      ),
    );
  }

  void _exportData() {
    final jsonData = const JsonEncoder.withIndent('  ').convert({
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'tasks': widget.tasks.map((t) => t.toJson()).toList(),
      'categories': widget.categories.map((c) => c.toJson()).toList(),
      'preferences': widget.preferences.toJson(),
    });
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Export Data'),
            contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'This export includes ${widget.tasks.length} tasks, '
                    '${widget.categories.length} categories, and app preferences.',
                  ),
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 260),
                    child: SingleChildScrollView(
                      child: SelectableText(
                        jsonData,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: jsonData));
                  Navigator.pop(context);
                  _showSnackbar('Exported JSON copied to clipboard');
                },
                child: const Text('COPY'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CLOSE'),
              ),
            ],
          ),
    );
  }

  void _showImportDialog() {
    final inputController = TextEditingController();
    String? errorText;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder:
              (context, setDialogState) => AlertDialog(
                title: const Text('Import Data'),
                content: SizedBox(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Imported data will replace current local tasks, categories, and preferences.',
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: inputController,
                        maxLines: 10,
                        decoration: InputDecoration(
                          hintText: 'Paste JSON here',
                          border: const OutlineInputBorder(),
                          errorText: errorText,
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () async {
                      final clipboard = await Clipboard.getData('text/plain');
                      if (clipboard?.text != null) {
                        inputController.text = clipboard!.text!;
                      }
                    },
                    child: const Text('PASTE'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('CANCEL'),
                  ),
                  TextButton(
                    onPressed: () async {
                      try {
                        final imported = _parseImport(inputController.text);
                        final navigator = Navigator.of(context);
                        final confirmed = await _confirmImport(imported);
                        if (!confirmed || !mounted) return;

                        widget.onTasksChanged(imported.tasks);
                        widget.onCategoriesChanged(imported.categories);
                        widget.onPreferencesChanged(imported.preferences);
                        navigator.pop();
                        await LocalStorage.saveTasks(imported.tasks);
                        await LocalStorage.saveCategories(imported.categories);
                        await LocalStorage.savePreferences(imported.preferences);
                        if (!mounted) return;
                        _showSnackbar(
                          'Imported ${imported.tasks.length} tasks and '
                          '${imported.categories.length} categories',
                        );
                      } catch (_) {
                        setDialogState(() {
                          errorText = 'Invalid checklist export JSON';
                        });
                      }
                    },
                    child: const Text('REVIEW'),
                  ),
                ],
              ),
        );
      },
    );
  }

  _ImportedData _parseImport(String input) {
    final raw = jsonDecode(input);

    if (raw is List<dynamic>) {
      return _ImportedData(
        tasks:
            raw.map((item) => Task.fromJson(item as Map<String, dynamic>)).toList(),
        categories: widget.categories,
        preferences: widget.preferences,
      );
    }

    final data = raw as Map<String, dynamic>;
    final tasksRaw = data['tasks'] as List<dynamic>? ?? [];
    final categoriesRaw = data['categories'] as List<dynamic>? ?? [];
    return _ImportedData(
      tasks:
          tasksRaw
              .map((item) => Task.fromJson(item as Map<String, dynamic>))
              .toList(),
      categories:
          categoriesRaw
              .map((item) => CategoryItem.fromJson(item as Map<String, dynamic>))
              .toList(),
      preferences:
          data['preferences'] is Map<String, dynamic>
              ? AppPreferences.fromJson(
                data['preferences'] as Map<String, dynamic>,
              )
              : widget.preferences,
    );
  }

  Future<bool> _confirmImport(_ImportedData imported) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Replace Local Data?'),
            content: Text(
              'This will replace your current ${widget.tasks.length} tasks and '
              '${widget.categories.length} categories with '
              '${imported.tasks.length} tasks and '
              '${imported.categories.length} categories from the import.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'REPLACE',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
    return confirmed ?? false;
  }

  void _clearCompletedTasks() async {
    final remainingTasks = widget.tasks.where((task) => !task.isDone).toList();
    widget.onTasksChanged(remainingTasks);
    await LocalStorage.saveTasks(remainingTasks);
    _showSnackbar('Completed tasks removed');
  }

  void _deleteAllTasks() async {
    widget.onTasksChanged([]);
    await LocalStorage.saveTasks([]);
    _showSnackbar('All tasks deleted');
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showDeleteDialog(String title, String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor:
                widget.isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
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
                  onConfirm();
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

class _ImportedData {
  final List<Task> tasks;
  final List<CategoryItem> categories;
  final AppPreferences preferences;

  const _ImportedData({
    required this.tasks,
    required this.categories,
    required this.preferences,
  });
}
