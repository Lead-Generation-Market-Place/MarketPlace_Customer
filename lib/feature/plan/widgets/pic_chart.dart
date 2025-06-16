import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

class PlanPieChart extends StatelessWidget {
  final int started;
  final int inProgress;
  final int done;

  const PlanPieChart({
    Key? key,
    required this.started,
    required this.inProgress,
    required this.done,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final total = started + inProgress + done;
    final dataMap = {
      "Started": started.toDouble(),
      "In Progress": inProgress.toDouble(),
      "Done": done.toDouble(),
    };

    final colorList = [
      const Color(0xFFFF9800), // Orange
      const Color(0xFF2196F3), // Blue
      const Color(0xFF43A047), // Green
    ];

    final gradientList = <List<Color>>[
      [Colors.orangeAccent, Colors.deepOrange],
      [Colors.blueAccent, Colors.indigo],
      [Colors.greenAccent, Colors.green.shade700],
    ];

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PieChart(
              dataMap: dataMap,
              animationDuration: const Duration(milliseconds: 1200),
              chartLegendSpacing: 40,
              chartRadius: MediaQuery.of(context).size.width / 2.2,
              colorList: colorList,
              gradientList: gradientList,
              initialAngleInDegree: 0,
              chartType: ChartType.ring,
              ringStrokeWidth: 36,
              centerText: total == 0 ? "No Plan" : "$total\nTasks",
              centerTextStyle: const TextStyle(
                backgroundColor: Colors.transparent,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                height: 1.2,
              ),
              legendOptions: const LegendOptions(showLegends: false),
              chartValuesOptions: const ChartValuesOptions(
                showChartValueBackground: true,
                showChartValues: true,
                showChartValuesInPercentage: true,
                showChartValuesOutside: true,
                decimalPlaces: 1,
                chartValueStyle: TextStyle(
                  backgroundColor: Colors.white,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              emptyColor: Colors.grey[300]!,
              emptyColorGradient: [Colors.grey[300]!, Colors.grey[100]!],
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _LegendItem(
                  color: colorList[0],
                  label: 'Started',
                  value: started,
                ),
                _LegendItem(
                  color: colorList[1],
                  label: 'In Progress',
                  value: inProgress,
                ),
                _LegendItem(color: colorList[2], label: 'Done', value: done),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final int value;

  const _LegendItem({
    Key? key,
    required this.color,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [color.withOpacity(0.7), color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$label ($value)',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }
}
