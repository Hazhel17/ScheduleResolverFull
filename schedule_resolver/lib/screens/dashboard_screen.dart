import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/schedule_provider.dart';
import '../services/ai_schedule_service.dart';
import '../models/task_model.dart';
import 'task_input_screen.dart';
import 'recommendation_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheduleProvider = Provider.of<ScheduleProvider>(context);
    final aiService = Provider.of<AiScheduleService>(context);

    final sortedTasks = List<TaskModel>.from(scheduleProvider.tasks);
    sortedTasks.sort((a, b) => a.startTime.hour.compareTo(b.startTime.hour));

    return Scaffold(
      appBar: AppBar(title: const Text('Schedule Resolver'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (aiService.currentAnalysis != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade300, width: 1.5),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.blue.shade700,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Recommendation available',
                        style: TextStyle(
                          color: Colors.blue.shade900,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RecommendationScreen(),
                        ),
                      ),
                      child: Text(
                        'View',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Expanded(
              child: sortedTasks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assignment,
                            size: 48,
                            color: Colors.blue.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No tasks yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.blue.shade900,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap the + button to add your first task',
                            style: TextStyle(color: Colors.blue.shade600),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: sortedTasks.length,
                      itemBuilder: (context, index) {
                        final task = sortedTasks[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: Container(
                              width: 4,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.blue.shade500,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            title: Text(
                              task.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              '${task.category} · ${task.startTime.format(context)} - ${task.endTime.format(context)}',
                              style: TextStyle(color: Colors.blue.shade600),
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: Colors.red.shade500,
                              ),
                              onPressed: () =>
                                  scheduleProvider.removeTask(task.id),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            if (sortedTasks.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: aiService.isLoading
                      ? null
                      : () => aiService.analyzeSchedule(scheduleProvider.tasks),
                  child: aiService.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text('Resolve Conflicts With AI'),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue.shade600,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TaskInputScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
