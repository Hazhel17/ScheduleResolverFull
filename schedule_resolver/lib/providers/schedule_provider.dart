import 'package:flutter/material.dart';
import '../models/task_model.dart';
import 'package:uuid/uuid.dart';

class ScheduleProvider extends ChangeNotifier {
  final List<TaskModel> _tasks = [];
  final Uuid _uuid = const Uuid();

  List<TaskModel> get tasks => _tasks;

  // Fixed error: TaskInputScreen calls addTask, so provider method name must match.
  void addTask({
    required String title,
    required String category,
    required DateTime date,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required int urgency,
    required int importance,
    required double estimatedEffortHours,
    required String energyLevel,
  }) {
    final newTasks = TaskModel(
      id: _uuid.v4(),
      title: title,
      category: category,
      date: date,
      startTime: startTime,
      endTime: endTime,
      urgency: urgency,
      importance: importance,
      estimatedEffortHours: estimatedEffortHours,
      energyLevel: energyLevel,
    );
    _tasks.add(newTasks);
    notifyListeners();
  }

  void removeTask(String id) {
    _tasks.removeWhere((tasks) => tasks.id == id);
    notifyListeners();
  }
}
