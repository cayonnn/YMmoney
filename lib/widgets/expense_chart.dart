import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../config/theme.dart';
import '../screens/transactions_screen.dart';

class ExpenseChart extends StatelessWidget {
  final Map<int, double> chartData;
  final double maxY;
  final TimePeriod periodType;

  const ExpenseChart({
    super.key,
    required this.chartData,
    this.maxY = 5000,
    this.periodType = TimePeriod.month,
  });

  static const List<String> _monthLabels = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  String _getLabel(int key) {
    switch (periodType) {
      case TimePeriod.day:
        return key.toString();
      case TimePeriod.month:
        if (key >= 1 && key <= 12) {
          return _monthLabels[key - 1];
        }
        return key.toString();
      case TimePeriod.year:
        return key.toString().substring(2); // Show last 2 digits (e.g., "24" for 2024)
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortedKeys = chartData.keys.toList()..sort();
    
    // For day mode, show max 15 bars (every other day if more)
    // For month mode, show all 12 months
    // For year mode, show all years
    List<int> keysToShow;
    if (periodType == TimePeriod.day && sortedKeys.length > 15) {
      keysToShow = [];
      for (int i = 0; i < sortedKeys.length; i += 2) {
        keysToShow.add(sortedKeys[i]);
      }
    } else {
      keysToShow = sortedKeys;
    }

    final barWidth = periodType == TimePeriod.year ? 40.0 : (periodType == TimePeriod.month ? 20.0 : 12.0);

    return Container(
      height: 200,
      padding: const EdgeInsets.only(top: 16, right: 16),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY > 0 ? maxY * 1.2 : 5000,
          minY: 0,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => AppTheme.textPrimary,
              tooltipPadding: const EdgeInsets.all(8),
              tooltipMargin: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '฿${rod.toY.toStringAsFixed(0)}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < keysToShow.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _getLabel(keysToShow[index]),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: periodType == TimePeriod.day ? 10 : 11,
                        ),
                      ),
                    );
                  }
                  return const SizedBox();
                },
                reservedSize: 28,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
                interval: maxY > 0 ? maxY / 4 : 1000,
                getTitlesWidget: (value, meta) {
                  String text;
                  if (value >= 1000) {
                    text = '฿${(value / 1000).toStringAsFixed(0)}k';
                  } else {
                    text = '฿${value.toInt()}';
                  }
                  return Text(
                    text,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY > 0 ? maxY / 4 : 1000,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.shade200,
                strokeWidth: 1,
                dashArray: [5, 5],
              );
            },
          ),
          barGroups: List.generate(keysToShow.length, (index) {
            final key = keysToShow[index];
            final value = chartData[key] ?? 0;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: value,
                  width: barWidth,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                  gradient: AppTheme.chartBarGradient,
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

