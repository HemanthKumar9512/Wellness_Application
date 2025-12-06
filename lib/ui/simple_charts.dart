import 'package:flutter/material.dart';
import '../data/wellness_model.dart';

class SimpleLineChart extends StatelessWidget {
  final List<WellnessMetric> data;
  final String metricType;

  const SimpleLineChart({
    super.key,
    required this.data,
    required this.metricType,
  });

  double _getMetricValue(WellnessMetric metric) {
    switch (metricType) {
      case 'steps':
        return metric.steps.toDouble();
      case 'sleep':
        return metric.sleepHours;
      case 'water':
        return metric.waterIntake.toDouble();
      case 'heart':
        return metric.heartRate.toDouble();
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      child: CustomPaint(
        painter: _ChartPainter(data, metricType, _getMetricValue),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<WellnessMetric> data;
  final String metricType;
  final double Function(WellnessMetric) getValue;

  _ChartPainter(this.data, this.metricType, this.getValue);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final values = data.map(getValue).toList();
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final valueRange = maxValue - minValue;

    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final path = Path();
    final widthStep = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final value = values[i];
      final x = i * widthStep;
      final y = size.height -
          ((value - minValue) / (valueRange > 0 ? valueRange : 1)) *
              size.height *
              0.8;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      canvas.drawCircle(Offset(x, y), 4, dotPaint);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
