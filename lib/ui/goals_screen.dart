import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/wellness_model.dart';
import '../data/mock_data.dart';

class GoalsScreen extends StatelessWidget {
  GoalsScreen({super.key});

  final TextEditingController stepsController = TextEditingController();
  final TextEditingController sleepController = TextEditingController();
  final TextEditingController waterController = TextEditingController();
  final TextEditingController heartController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final wellnessData = Provider.of<WellnessData>(context);
    final goals = wellnessData.goals;
    final weeklyAverages = wellnessData.getWeeklyAverages();

    stepsController.text = goals.dailySteps.toString();
    sleepController.text = goals.dailySleep.toString();
    waterController.text = goals.dailyWater.toString();
    heartController.text = goals.maxHeartRate.toString();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Goals & Progress'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Weekly Averages',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (weeklyAverages.isNotEmpty)
                      Column(
                        children: [
                          _buildAverageRow('Steps',
                              weeklyAverages['steps']!.toInt(), 'steps'),
                          _buildAverageRow(
                              'Sleep', weeklyAverages['sleep']!, 'hours'),
                          _buildAverageRow(
                              'Water', weeklyAverages['water']!.toInt(), 'ml'),
                          _buildAverageRow('Heart Rate',
                              weeklyAverages['heart']!.toInt(), 'bpm'),
                        ],
                      )
                    else
                      const Text('No data yet'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Set Daily Goals',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: stepsController,
                      decoration: const InputDecoration(
                        labelText: 'Daily Steps',
                        suffixText: 'steps',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: sleepController,
                      decoration: const InputDecoration(
                        labelText: 'Sleep Hours',
                        suffixText: 'hours',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: waterController,
                      decoration: const InputDecoration(
                        labelText: 'Water Intake',
                        suffixText: 'ml',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: heartController,
                      decoration: const InputDecoration(
                        labelText: 'Max Heart Rate',
                        suffixText: 'bpm',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final newGoals = UserGoals(
                            dailySteps:
                                int.tryParse(stepsController.text) ?? 8000,
                            dailySleep:
                                double.tryParse(sleepController.text) ?? 8.0,
                            dailyWater:
                                int.tryParse(waterController.text) ?? 2500,
                            maxHeartRate:
                                int.tryParse(heartController.text) ?? 75,
                          );
                          wellnessData.updateGoals(newGoals);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Goals updated!')),
                          );
                        },
                        child: const Text('Save Goals'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ActionChip(
                          label: const Text('Add Sample Data'),
                          onPressed: () {
                            wellnessData.addSampleData();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Sample data added!')),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAverageRow(String label, dynamic value, String unit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text('$value $unit',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.blue,
              )),
        ],
      ),
    );
  }
}
