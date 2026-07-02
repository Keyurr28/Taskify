import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

enum TaskFilter { all, pending, completed }
enum TaskSort { newest, dueDate, priority }

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  TaskFilter _currentFilter = TaskFilter.all;
  TaskSort _currentSort = TaskSort.newest;
  
  static const String _prefsKey = 'taskify_tasks';

  TaskProvider() {
    _loadTasks();
  }

  List<Task> get tasks {
    List<Task> filteredTasks;
    switch (_currentFilter) {
      case TaskFilter.pending:
        filteredTasks = _tasks.where((t) => t.status == TaskStatus.pending).toList();
        break;
      case TaskFilter.completed:
        filteredTasks = _tasks.where((t) => t.status == TaskStatus.completed).toList();
        break;
      case TaskFilter.all:
      default:
        filteredTasks = List.from(_tasks);
    }
    
    // Apply sorting
    switch (_currentSort) {
      case TaskSort.priority:
        filteredTasks.sort((a, b) => b.priority.index.compareTo(a.priority.index));
        break;
      case TaskSort.dueDate:
        filteredTasks.sort((a, b) {
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1; // Put tasks without due dates at the end
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        });
        break;
      case TaskSort.newest:
      default:
        filteredTasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }
    
    return filteredTasks;
  }

  TaskFilter get currentFilter => _currentFilter;
  TaskSort get currentSort => _currentSort;
  
  int get allTasksCount => _tasks.length;
  int get completedTasksCount => _tasks.where((t) => t.status == TaskStatus.completed).length;

  void setFilter(TaskFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  void setSort(TaskSort sort) {
    _currentSort = sort;
    notifyListeners();
  }

  Future<void> addTask(String title, String description, TaskPriority priority, DateTime? dueDate, TaskCategory category) async {
    _tasks.add(Task(
      title: title,
      description: description,
      priority: priority,
      dueDate: dueDate,
      category: category,
    ));
    await _saveTasks();
    notifyListeners();
  }

  Future<void> updateTask(String id, String title, String description, TaskPriority priority, DateTime? dueDate, TaskCategory category) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index >= 0) {
      _tasks[index] = _tasks[index].copyWith(
        title: title, 
        description: description, 
        priority: priority,
        dueDate: dueDate,
        category: category,
      );
      await _saveTasks();
      notifyListeners();
    }
  }

  Future<void> toggleTaskStatus(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index >= 0) {
      final currentStatus = _tasks[index].status;
      _tasks[index] = _tasks[index].copyWith(
        status: currentStatus == TaskStatus.pending ? TaskStatus.completed : TaskStatus.pending,
      );
      await _saveTasks();
      notifyListeners();
    }
  }

  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    await _saveTasks();
    notifyListeners();
  }

  Future<void> clearAllTasks() async {
    _tasks.clear();
    await _saveTasks();
    notifyListeners();
  }
  
  Future<void> _loadTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? tasksJson = prefs.getString(_prefsKey);
      if (tasksJson != null) {
        final List<dynamic> decoded = jsonDecode(tasksJson);
        _tasks = decoded.map((item) => Task.fromJson(item)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading tasks: $e');
    }
  }

  Future<void> _saveTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(_tasks.map((t) => t.toJson()).toList());
      await prefs.setString(_prefsKey, encoded);
    } catch (e) {
      debugPrint('Error saving tasks: $e');
    }
  }
}
