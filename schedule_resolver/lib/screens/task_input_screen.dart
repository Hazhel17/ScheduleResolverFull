import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/schedule_provider.dart';

class TaskInputScreen extends StatefulWidget {
  const TaskInputScreen({super.key});
  @override
  State<TaskInputScreen> createState() => _TaskInputScreenState();
}

class _TaskInputScreenState extends State<TaskInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  String _title = '';

  String _category = 'Class';
  DateTime _date = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now().replacing(
    hour: (TimeOfDay.now().hour + 1) % 24,
  );
  double _urgency = 3, _importance = 3, _effort = 1.0;
  String _energy = 'Medium';

  final List<String> _cats = ['Class', 'Org Work', 'Study', 'Rest', 'Other'];
  final List<String> _energies = ['Low', 'Medium', 'High'];

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();
    try {
      Provider.of<ScheduleProvider>(context, listen: false).addTask(
        title: _title,
        category: _category,
        date: _date,
        startTime: _startTime,
        endTime: _endTime,
        urgency: _urgency.toInt(),
        importance: _importance.toInt(),
        estimatedEffortHours: _effort,
        energyLevel: _energy,
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not add task: $e')));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Task')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create a new task',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Fill in the details below',
                      style: TextStyle(
                        color: Colors.blue.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Task Title',
                  filled: true,
                  fillColor: Colors.blue.shade50,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.blue.shade600,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a task title';
                  }
                  return null;
                },
                onSaved: (value) => _title = value?.trim() ?? '',
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: InputDecoration(
                  labelText: 'Category',
                  filled: true,
                  fillColor: Colors.blue.shade50,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: _cats
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) => setState(() => _category = val!),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickTime(true),
                      icon: const Icon(Icons.access_time),
                      label: Text('Start: ${_startTime.format(context)}'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue.shade700,
                        side: BorderSide(color: Colors.blue.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickTime(false),
                      icon: const Icon(Icons.access_time),
                      label: Text('End: ${_endTime.format(context)}'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue.shade700,
                        side: BorderSide(color: Colors.blue.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Urgency',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade900,
                ),
              ),
              SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: Colors.blue.shade500,
                  thumbColor: Colors.blue.shade600,
                  overlayColor: Colors.blue.withAlpha(32),
                ),
                child: Slider(
                  value: _urgency,
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: _urgency.round().toString(),
                  onChanged: (val) => setState(() => _urgency = val),
                ),
              ),
              Text(
                'Importance',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade900,
                ),
              ),
              SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: Colors.blue.shade500,
                  thumbColor: Colors.blue.shade600,
                  overlayColor: Colors.blue.withAlpha(32),
                ),
                child: Slider(
                  value: _importance,
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: _importance.round().toString(),
                  onChanged: (val) => setState(() => _importance = val),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _energy,
                decoration: InputDecoration(
                  labelText: 'Energy Level',
                  filled: true,
                  fillColor: Colors.blue.shade50,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: _energies
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => _energy = val!),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Add Task to Timeline'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
