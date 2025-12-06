import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../data/wellness_model.dart';
import '../data/mock_data.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wellnessData = Provider.of<WellnessData>(context);
    final metrics = wellnessData.metrics;

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddDataDialog(context, wellnessData);
            },
          ),
        ],
      ),
      body: metrics.isEmpty
          ? const Center(child: Text('No data yet. Add some!'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: metrics.length,
              itemBuilder: (context, index) {
                final metric = metrics[index];
                return _buildMetricCard(metric, context, wellnessData);
              },
            ),
    );
  }

  Widget _buildMetricCard(
      WellnessMetric metric, BuildContext context, WellnessData wellnessData) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final today = DateTime.now();
    final isToday = metric.date.year == today.year &&
        metric.date.month == today.month &&
        metric.date.day == today.day;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isToday ? Colors.blue : Colors.grey[300],
          child: Icon(
            isToday ? Icons.today : Icons.calendar_today,
            color: isToday ? Colors.white : Colors.grey[600],
          ),
        ),
        title: Text(dateFormat.format(metric.date)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Steps: ${metric.steps} • Sleep: ${metric.sleepHours}h'),
            Text(
                'Water: ${metric.waterIntake}ml • Heart: ${metric.heartRate}bpm'),
            if (metric.notes != null && metric.notes!.isNotEmpty)
              Text('Notes: ${metric.notes!}',
                  style: TextStyle(color: Colors.grey[600])),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          _showEditDialog(context, wellnessData, metric);
        },
      ),
    );
  }

  void _showAddDataDialog(BuildContext context, WellnessData wellnessData) {
    final dateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );
    final stepsController = TextEditingController();
    final sleepController = TextEditingController();
    final waterController = TextEditingController();
    final heartController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Health Data'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(
                    labelText: 'Date (YYYY-MM-DD)',
                    hintText: '2024-01-20',
                  ),
                ),
                TextField(
                  controller: stepsController,
                  decoration: const InputDecoration(labelText: 'Steps'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: sleepController,
                  decoration: const InputDecoration(labelText: 'Sleep Hours'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: waterController,
                  decoration: const InputDecoration(labelText: 'Water (ml)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: heartController,
                  decoration: const InputDecoration(labelText: 'Heart Rate'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: notesController,
                  decoration:
                      const InputDecoration(labelText: 'Notes (optional)'),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                DateTime date;
                try {
                  date = DateFormat('yyyy-MM-dd').parse(dateController.text);
                } catch (e) {
                  date = DateTime.now();
                }

                final metric = WellnessMetric(
                  date: date,
                  steps: int.tryParse(stepsController.text) ?? 0,
                  sleepHours: double.tryParse(sleepController.text) ?? 0,
                  waterIntake: int.tryParse(waterController.text) ?? 0,
                  heartRate: int.tryParse(heartController.text) ?? 0,
                  notes: notesController.text.isNotEmpty
                      ? notesController.text
                      : null,
                );

                wellnessData.updateMetric(metric);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(
      BuildContext context, WellnessData wellnessData, WellnessMetric metric) {
    final stepsController =
        TextEditingController(text: metric.steps.toString());
    final sleepController =
        TextEditingController(text: metric.sleepHours.toString());
    final waterController =
        TextEditingController(text: metric.waterIntake.toString());
    final heartController =
        TextEditingController(text: metric.heartRate.toString());
    final notesController = TextEditingController(text: metric.notes ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Data'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Date: ${DateFormat('MMM dd, yyyy').format(metric.date)}'),
                const SizedBox(height: 16),
                TextField(
                  controller: stepsController,
                  decoration: const InputDecoration(labelText: 'Steps'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: sleepController,
                  decoration: const InputDecoration(labelText: 'Sleep Hours'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: waterController,
                  decoration: const InputDecoration(labelText: 'Water (ml)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: heartController,
                  decoration: const InputDecoration(labelText: 'Heart Rate'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: 'Notes'),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final updatedMetric = WellnessMetric(
                  date: metric.date,
                  steps: int.tryParse(stepsController.text) ?? 0,
                  sleepHours: double.tryParse(sleepController.text) ?? 0,
                  waterIntake: int.tryParse(waterController.text) ?? 0,
                  heartRate: int.tryParse(heartController.text) ?? 0,
                  notes: notesController.text.isNotEmpty
                      ? notesController.text
                      : null,
                );

                wellnessData.updateMetric(updatedMetric);
                Navigator.pop(context);
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }
}
