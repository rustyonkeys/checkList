import 'dart:convert';

import 'package:checklist/pages/categories.dart';
import 'package:checklist/util/inbox_block.dart';
import 'package:checklist/util/task.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  final bool isDarkMode;
  final bool notificationsEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final String defaultPriority;
  final String taskSortBy;
  final bool autoDeleteCompleted;
  final int autoDeleteDays;

  const AppPreferences({
    required this.isDarkMode,
    required this.notificationsEnabled,
    required this.soundEnabled,
    required this.vibrationEnabled,
    required this.defaultPriority,
    required this.taskSortBy,
    required this.autoDeleteCompleted,
    required this.autoDeleteDays,
  });

  factory AppPreferences.defaults() => const AppPreferences(
    isDarkMode: false,
    notificationsEnabled: true,
    soundEnabled: true,
    vibrationEnabled: true,
    defaultPriority: 'Medium',
    taskSortBy: 'Due Date',
    autoDeleteCompleted: false,
    autoDeleteDays: 7,
  );

  factory AppPreferences.fromJson(Map<String, dynamic> json) {
    return AppPreferences(
      isDarkMode: json['isDarkMode'] as bool? ?? false,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
      defaultPriority: json['defaultPriority'] as String? ?? 'Medium',
      taskSortBy: json['taskSortBy'] as String? ?? 'Due Date',
      autoDeleteCompleted: json['autoDeleteCompleted'] as bool? ?? false,
      autoDeleteDays: json['autoDeleteDays'] as int? ?? 7,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isDarkMode': isDarkMode,
      'notificationsEnabled': notificationsEnabled,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'defaultPriority': defaultPriority,
      'taskSortBy': taskSortBy,
      'autoDeleteCompleted': autoDeleteCompleted,
      'autoDeleteDays': autoDeleteDays,
    };
  }

  AppPreferences copyWith({
    bool? isDarkMode,
    bool? notificationsEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    String? defaultPriority,
    String? taskSortBy,
    bool? autoDeleteCompleted,
    int? autoDeleteDays,
  }) {
    return AppPreferences(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      defaultPriority: defaultPriority ?? this.defaultPriority,
      taskSortBy: taskSortBy ?? this.taskSortBy,
      autoDeleteCompleted: autoDeleteCompleted ?? this.autoDeleteCompleted,
      autoDeleteDays: autoDeleteDays ?? this.autoDeleteDays,
    );
  }
}

class LocalStorage {
  static const _tasksKey = 'tasks';
  static const _categoriesKey = 'categories';
  static const _preferencesKey = 'app_preferences';
  static const _inboxBlocksKey = 'inbox_blocks';

  static Future<AppPreferences> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_preferencesKey);
    if (jsonString == null || jsonString.isEmpty) {
      return AppPreferences.defaults();
    }

    final Map<String, dynamic> raw =
        json.decode(jsonString) as Map<String, dynamic>;
    return AppPreferences.fromJson(raw);
  }

  static Future<void> savePreferences(AppPreferences preferences) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(preferences.toJson());
    await prefs.setString(_preferencesKey, jsonString);
  }

  static Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_tasksKey);
    if (jsonString == null || jsonString.isEmpty) return [];

    final List<dynamic> raw = json.decode(jsonString) as List<dynamic>;
    return raw
        .map((item) => Task.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(tasks.map((t) => t.toJson()).toList());
    await prefs.setString(_tasksKey, jsonString);
  }

  static Future<List<InboxBlock>> loadInboxBlocks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_inboxBlocksKey);
    if (jsonString == null || jsonString.isEmpty) return [];

    final List<dynamic> raw = json.decode(jsonString) as List<dynamic>;
    return raw
        .map((item) => InboxBlock.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<void> saveInboxBlocks(List<InboxBlock> blocks) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(blocks.map((b) => b.toJson()).toList());
    await prefs.setString(_inboxBlocksKey, jsonString);
  }

  static Future<List<CategoryItem>> loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_categoriesKey);
    if (jsonString == null || jsonString.isEmpty) {
      return _defaultCategories();
    }

    final List<dynamic> raw = json.decode(jsonString) as List<dynamic>;
    return raw
        .map((item) => CategoryItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<void> saveCategories(List<CategoryItem> categories) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(categories.map((c) => c.toJson()).toList());
    await prefs.setString(_categoriesKey, jsonString);
  }

  static List<CategoryItem> _defaultCategories() {
    return [
      CategoryItem(
        name: 'Work',
        icon: Icons.work_outline,
        color: Colors.blue,
        taskCount: 0,
        completedCount: 0,
      ),
      CategoryItem(
        name: 'Personal',
        icon: Icons.person_outline,
        color: Colors.purple,
        taskCount: 0,
        completedCount: 0,
      ),
      CategoryItem(
        name: 'Study',
        icon: Icons.school_outlined,
        color: Colors.green,
        taskCount: 0,
        completedCount: 0,
      ),
    ];
  }
}
