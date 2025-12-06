import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/mock_data.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wellnessData = Provider.of<WellnessData>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('App Settings'),
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Switch between light and dark theme'),
              secondary: const Icon(Icons.dark_mode),
              value: wellnessData.darkMode,
              onChanged: (value) {
                wellnessData.toggleDarkMode(value);
              },
            ),
          ),
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: SwitchListTile(
              title: const Text('Daily Reminders'),
              subtitle: const Text('Get daily wellness reminders'),
              secondary: const Icon(Icons.notifications),
              value: wellnessData.dailyReminders,
              onChanged: (value) {
                wellnessData.toggleReminders(value);
              },
            ),
          ),
          _buildSectionHeader('Data Management'),
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Export Data'),
              subtitle: const Text('Export your wellness data'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                _showExportDialog(context);
              },
            ),
          ),
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Clear All Data'),
              subtitle: const Text('Delete all your wellness data'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                _showClearDialog(context);
              },
            ),
          ),
          _buildSectionHeader('About'),
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Privacy Policy'),
              subtitle: const Text('Read our privacy policy'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ),
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const Icon(Icons.support),
              title: const Text('Contact Support'),
              subtitle: const Text('Get help or send feedback'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ),
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const Icon(Icons.info),
              title: const Text('App Version'),
              subtitle: const Text('Version 1.0.0'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 40),
          Center(
            child: Text(
              'Wellness AI Assistant v1.0.0',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Export Data'),
          content: const Text(
              'Export feature will be available in the next update.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showClearDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear All Data'),
          content: const Text(
              'This will delete all your wellness data. This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data cleared')),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }
}
