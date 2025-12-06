import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ui/dashboard.dart';
import 'data/mock_data.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => WellnessData(),
      child: const WellnessApp(),
    ),
  );
}

class WellnessApp extends StatelessWidget {
  const WellnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    final wellnessData = Provider.of<WellnessData>(context);

    return MaterialApp(
      title: 'Wellness AI Assistant',
      theme: wellnessData.darkMode
          ? ThemeData.dark()
          : ThemeData(
              primarySwatch: Colors.blue,
              useMaterial3: true,
            ),
      home: const DashboardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
