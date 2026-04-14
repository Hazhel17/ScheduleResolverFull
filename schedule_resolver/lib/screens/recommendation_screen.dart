import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ai_schedule_service.dart';

class RecommendationScreen extends StatelessWidget {
  const RecommendationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final aiService = Provider.of<AiScheduleService>(context);
    final analysis = aiService.currentAnalysis;

    if (analysis == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('AI Schedule Recommendation')),
        body: const Center(child: Text('No recommendation available.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('AI Schedule Recommendation')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSection(
              context,
              'Detected Conflicts',
              analysis.conflicts,
              Colors.red.shade50,
              Icons.warning_amber_rounded,
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              'Ranked Tasks',
              analysis.rankedTasks,
              Colors.blue.shade50,
              Icons.format_list_numbered,
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              'Recommended Schedule',
              analysis.recommendedSchedule,
              Colors.green.shade50,
              Icons.calendar_today,
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              'Explanation',
              analysis.explanation,
              Colors.orange.shade50,
              Icons.lightbulb_outline,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    String content,
    Color bgColor,
    IconData icon,
  ) {
    return Card(
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 24, color: Colors.blue.shade700),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ],
              ),
              const Divider(height: 16),
              Text(
                content,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.blue.shade800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
