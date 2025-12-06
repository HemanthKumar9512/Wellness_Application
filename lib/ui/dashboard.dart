import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'metric_card.dart';
import 'simple_charts.dart';
import 'history_screen.dart';
import 'goals_screen.dart';
import 'settings_screen.dart';
import '../data/wellness_model.dart';
import '../data/mock_data.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wellness AI Assistant'),
        centerTitle: true,
      ),
      body: _getScreen(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: Colors.blue,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flag),
            label: 'Goals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _getScreen(int index) {
    switch (index) {
      case 0:
        return const HomeScreen();
      case 1:
        return const HistoryScreen();
      case 2:
        return GoalsScreen();
      case 3:
        return const SettingsScreen();
      default:
        return const HomeScreen();
    }
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wellnessData = Provider.of<WellnessData>(context);
    final today = wellnessData.todayMetric;
    final insights = wellnessData.insights;
    final goals = wellnessData.goals;

    if (wellnessData.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue[100],
                    child: const Icon(Icons.person, color: Colors.blue),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          'Track your wellness journey',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (insights != null)
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Today\'s Score',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              'Productivity',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Chip(
                          backgroundColor:
                              _getScoreColor(insights.productivityScore),
                          label: Text(
                            '${insights.productivityScore.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: insights.productivityScore / 100,
                      backgroundColor: Colors.grey[300],
                      color: _getScoreColor(insights.productivityScore),
                      minHeight: 12,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 20),
          const Text(
            "Today's Metrics",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              MetricCard(
                title: 'Steps',
                value: '${today.steps}',
                unit: '/${goals.dailySteps}',
                icon: Icons.directions_walk,
                color: today.steps >= goals.dailySteps
                    ? Colors.green
                    : Colors.blue,
                onTap: () =>
                    _showDetails(context, 'Steps', wellnessData.metrics),
              ),
              MetricCard(
                title: 'Sleep',
                value: today.sleepHours.toStringAsFixed(1),
                unit: '/${goals.dailySleep}h',
                icon: Icons.bedtime,
                color: today.sleepHours >= goals.dailySleep
                    ? Colors.green
                    : Colors.purple,
                onTap: () =>
                    _showDetails(context, 'Sleep', wellnessData.metrics),
              ),
              MetricCard(
                title: 'Water',
                value: '${today.waterIntake ~/ 1000}',
                unit: '/${goals.dailyWater ~/ 1000}L',
                icon: Icons.water_drop,
                color: today.waterIntake >= goals.dailyWater
                    ? Colors.green
                    : Colors.lightBlue,
                onTap: () =>
                    _showDetails(context, 'Water', wellnessData.metrics),
              ),
              MetricCard(
                title: 'Heart Rate',
                value: '${today.heartRate}',
                unit: 'bpm',
                icon: Icons.favorite,
                color: today.heartRate <= goals.maxHeartRate
                    ? Colors.green
                    : Colors.red,
                onTap: () =>
                    _showDetails(context, 'Heart', wellnessData.metrics),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'AI Insights',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (insights != null)
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.psychology, color: Colors.deepPurple),
                        SizedBox(width: 8),
                        Text(
                          'Smart Analysis',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInsightChip(
                            'Stress',
                            insights.stressLevel,
                            insights.stressLevel == 'High'
                                ? Colors.red
                                : insights.stressLevel == 'Medium'
                                    ? Colors.orange
                                    : Colors.green,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildInsightChip(
                            'Sleep',
                            insights.sleepQuality,
                            insights.sleepQuality == 'Excellent'
                                ? Colors.green
                                : insights.sleepQuality == 'Good'
                                    ? Colors.blue
                                    : insights.sleepQuality == 'Fair'
                                        ? Colors.orange
                                        : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInsightChip(
                            'Activity',
                            insights.activityLevel,
                            insights.activityLevel == 'High'
                                ? Colors.green
                                : insights.activityLevel == 'Moderate'
                                    ? Colors.blue
                                    : Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildInsightChip(
                            'Hydration',
                            '${insights.hydrationScore.toInt()}%',
                            insights.hydrationScore >= 80
                                ? Colors.green
                                : insights.hydrationScore >= 60
                                    ? Colors.blue
                                    : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.lightbulb, color: Colors.amber),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              insights.topSuggestion,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (today.notes != null && today.notes!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.note, color: Colors.grey),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Your Note',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(today.notes!),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () =>
                      _showEditDialog(context, wellnessData, today),
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Today'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HistoryScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Past Day'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  Widget _buildInsightChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showDetails(
      BuildContext context, String metric, List<WellnessMetric> data) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 400,
          child: Column(
            children: [
              Text(
                '$metric Trend',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SimpleLineChart(
                  data: data.length > 7 ? data.sublist(data.length - 7) : data,
                  metricType: metric.toLowerCase(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditDialog(
      BuildContext context, WellnessData wellnessData, WellnessMetric today) {
    final stepsController = TextEditingController(text: today.steps.toString());
    final sleepController =
        TextEditingController(text: today.sleepHours.toString());
    final waterController =
        TextEditingController(text: today.waterIntake.toString());
    final heartController =
        TextEditingController(text: today.heartRate.toString());
    final notesController = TextEditingController(text: today.notes ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Today\'s Data'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: stepsController,
                  decoration: const InputDecoration(
                    labelText: 'Steps',
                    prefixIcon: Icon(Icons.directions_walk),
                  ),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: sleepController,
                  decoration: const InputDecoration(
                    labelText: 'Sleep Hours',
                    prefixIcon: Icon(Icons.bedtime),
                  ),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: waterController,
                  decoration: const InputDecoration(
                    labelText: 'Water (ml)',
                    prefixIcon: Icon(Icons.water_drop),
                  ),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: heartController,
                  decoration: const InputDecoration(
                    labelText: 'Heart Rate',
                    prefixIcon: Icon(Icons.favorite),
                  ),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    prefixIcon: Icon(Icons.note),
                  ),
                  maxLines: 3,
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
                wellnessData.updateTodayMetric(
                  steps: int.tryParse(stepsController.text),
                  sleep: double.tryParse(sleepController.text),
                  water: int.tryParse(waterController.text),
                  heartRate: int.tryParse(heartController.text),
                  notes: notesController.text.isNotEmpty
                      ? notesController.text
                      : null,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data updated!')),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
