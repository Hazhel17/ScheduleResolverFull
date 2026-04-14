import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/schedule_analysis.dart';
import '../models/task_model.dart';

class AiScheduleService extends ChangeNotifier {
  ScheduleAnalysis? _currentAnalysis;
  bool _isLoading = false;
  String? _errorMessage;

  // Expose these values to the UI. DashboardScreen uses
  // aiService.currentAnalysis and aiService.isLoading.
  ScheduleAnalysis? get currentAnalysis => _currentAnalysis;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final String _apiKey = 'AIzaSyAve9dxKuSV-Iz7SxNQ28qn8u6J4SknA2o';

  Future<void> analyzeSchedule(List<TaskModel> tasks) async {
    if (_apiKey.isEmpty || tasks.isEmpty) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: _apiKey);
      final tasksJson = jsonEncode(tasks.map((t) => t.toJson()).toList());

      final prompt =
          '''
          You are an expert student scheduling assistant. The user has provided the following tasks for their day in JSON format:
          $tasksJson
          
          Please analyze these tasks and provide exactly 4 sections of markdown text:
      
          1. ### Detected Conflicts
          CRITICAL: Identify ALL scheduling conflicts by comparing the date and times of each task.
          Two tasks conflict if they have the SAME date and their time ranges overlap or are identical.
          - If Task A is 6:00 PM - 7:00 PM and Task B is 6:00 PM - 7:00 PM: CONFLICT
          - If Task A is 6:00 PM - 7:00 PM and Task B is 6:30 PM - 7:30 PM: CONFLICT (overlap)
          - If Task A is 6:00 PM - 7:00 PM and Task B is 7:00 PM - 8:00 PM: NO CONFLICT
          
          List EVERY conflict found. Include the task titles, their times, and why they conflict.
          If there are no conflicts, state that clearly.
          
          2. ### Ranked Tasks
          Provide a numbered list of tasks sorted by highest priority first (combine urgency + importance scores), with 1 as the most urgent/important task. Include task details.
          
          3. ### Recommended Schedule
          Provide a revised daily timeline for the tasks, resolving any conflicts by rescheduling. Show specific dates (from the task data) and times.
          
          4. ### Explanation
          Explain the conflicts found and why your recommended schedule resolves them.
    ''';

      final content = [Content.text(prompt)];

      final response = await model.generateContent(content);

      _currentAnalysis = _parseResponse(response.text ?? "");
    } catch (e) {
      _errorMessage = "Failed $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  ScheduleAnalysis _parseResponse(String fullText) {
    String conflicts = "",
        rankedTasks = "",
        recommendedSchedule = "",
        explanation = "";

    final sections = fullText.split('### ');

    for (var section in sections) {
      if (section.startsWith('Detected Conflicts')) {
        conflicts = _normalizeSection(
          'Detected Conflicts',
          section.replaceFirst('Detected Conflicts', '').trim(),
        );
      } else if (section.startsWith('Ranked Tasks')) {
        rankedTasks = _normalizeSection(
          'Ranked Tasks',
          section.replaceFirst('Ranked Tasks', '').trim(),
        );
      } else if (section.startsWith('Recommended Schedule')) {
        recommendedSchedule = _normalizeSection(
          'Recommended Schedule',
          section.replaceFirst('Recommended Schedule', '').trim(),
        );
      } else if (section.startsWith('Explanation')) {
        explanation = _normalizeSection(
          'Explanation',
          section.replaceFirst('Explanation', '').trim(),
        );
      }
    }

    return ScheduleAnalysis(
      conflicts: conflicts,
      rankedTasks: rankedTasks,
      recommendedSchedule: recommendedSchedule,
      explanation: explanation,
    );
  }

  String _normalizeSection(String sectionName, String text) {
    switch (sectionName) {
      case 'Ranked Tasks':
        return _cleanNumberedList(text);
      case 'Recommended Schedule':
        return _cleanBulletedList(text);
      case 'Explanation':
        return _cleanParagraph(text);
      default:
        return _cleanPlainText(text);
    }
  }

  String _cleanPlainText(String text) {
    var cleaned = text.replaceAll(RegExp(r'^#{1,6}\s*', multiLine: true), '');
    cleaned = cleaned.replaceAll(RegExp(r'^[-*+]\s*', multiLine: true), '');
    cleaned = _stripMarkdownDecorators(cleaned);
    return cleaned.trim();
  }

  String _stripMarkdownDecorators(String text) {
    return text
        .replaceAll(RegExp(r'(```[\s\S]*?```)|(`[^`]*`)|([*_]{1,3})|(~~)'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String _cleanNumberedList(String text) {
    final lines = text
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    if (lines.isEmpty) return '';

    final cleanedLines = <String>[];
    for (var i = 0; i < lines.length; i++) {
      var line = lines[i];
      line = line.replaceFirst(RegExp(r'^[-*+\s]*'), '');
      line = _stripMarkdownDecorators(line);
      if (RegExp(r'^\d+\.\s*').hasMatch(line)) {
        cleanedLines.add(line);
      } else {
        cleanedLines.add('${i + 1}. $line');
      }
    }

    return cleanedLines.join('\n');
  }

  String _cleanBulletedList(String text) {
    final lines = text
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    if (lines.isEmpty) return '';

    final cleanedLines = lines.map((line) {
      var cleanLine = line.replaceFirst(RegExp(r'^([*+-]|\d+\.|•)\s*'), '');
      cleanLine = _stripMarkdownDecorators(cleanLine);
      return '• $cleanLine';
    }).toList();

    return cleanedLines.join('\n');
  }

  String _cleanParagraph(String text) {
    final lines = text
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    final cleaned = lines
        .map((line) => line.replaceAll(RegExp(r'^([*+-]|\d+\.|•)\s*'), ''))
        .map(_stripMarkdownDecorators)
        .join(' ');

    return cleaned.trim();
  }
}
