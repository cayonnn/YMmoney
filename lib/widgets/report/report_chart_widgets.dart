import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../l10n/app_strings.dart';

/// Mini chart card for income/expense summary with line chart
class MiniChartCard extends StatelessWidget {
  final String title;
  final double amount;
  final String currency;
  final NumberFormat formatter;
  final Map<int, double> dailyData;
  final List<int> chartDays;
  final Color color;
  final IconData icon;
  final bool isIncome;
  final bool isDark;

  const MiniChartCard({
    super.key,
    required this.title,
    required this.amount,
    required this.currency,
    required this.formatter,
    required this.dailyData,
    required this.chartDays,
    required this.color,
    required this.icon,
    required this.isIncome,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final subtitleColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    
    // Normalize data for this chart
    final maxValue = dailyData.values.isEmpty ? 1.0 : dailyData.values.reduce((a, b) => a > b ? a : b);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark ? null : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 14),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: subtitleColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Amount
          Text(
            '$currency${formatter.format(amount)}',
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          // Mini Line Chart
          SizedBox(
            height: 50,
            child: chartDays.isEmpty || dailyData.isEmpty
                ? Center(
                    child: Text(
                      '-',
                      style: TextStyle(color: Colors.grey.shade400),
                    ),
                  )
                : chartDays.length == 1
                    // Single data point - show horizontal line
                    ? _buildSinglePointIndicator(color)
                    : LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: false),
                          titlesData: const FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          minX: chartDays.first.toDouble() - 0.5,
                          maxX: chartDays.last.toDouble() + 0.5,
                          minY: 0,
                          maxY: maxValue * 1.2,
                          lineTouchData: const LineTouchData(enabled: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: chartDays.map((day) => FlSpot(
                                day.toDouble(),
                                dailyData[day] ?? 0,
                              )).toList(),
                              isCurved: true,
                              curveSmoothness: 0.35,
                              color: color,
                              barWidth: 2,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    color.withValues(alpha: 0.3),
                                    color.withValues(alpha: 0.05),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSinglePointIndicator(Color color) {
    // Show a flat line to match the line chart style when there's only 1 data point
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // Gradient fill area
        Container(
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color.withValues(alpha: 0.25),
                color.withValues(alpha: 0.05),
              ],
            ),
          ),
        ),
        // Line at the top
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 2,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// Combined income/expense chart cards row
class CombinedChartCards extends StatelessWidget {
  final List<dynamic> transactions;
  final double totalIncome;
  final double totalExpense;
  final String currency;
  final NumberFormat formatter;
  final bool isDark;

  const CombinedChartCards({
    super.key,
    required this.transactions,
    required this.totalIncome,
    required this.totalExpense,
    required this.currency,
    required this.formatter,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // Group data by date index (sequential) for proper chart display
    Map<int, double> dailyIncome = {};
    Map<int, double> dailyExpense = {};
    
    // Sort transactions by date first
    final sortedTransactions = List.from(transactions)
      ..sort((a, b) => a.date.compareTo(b.date));
    
    // Create date-to-index mapping for X axis
    final uniqueDates = sortedTransactions
        .map((t) => DateTime(t.date.year, t.date.month, t.date.day))
        .toSet()
        .toList()
      ..sort();
    
    final dateToIndex = <DateTime, int>{};
    for (int i = 0; i < uniqueDates.length; i++) {
      dateToIndex[uniqueDates[i]] = i;
    }
    
    // Aggregate by date index
    for (var t in sortedTransactions) {
      final dateKey = DateTime(t.date.year, t.date.month, t.date.day);
      final index = dateToIndex[dateKey] ?? 0;
      if (t.isExpense) {
        dailyExpense[index] = (dailyExpense[index] ?? 0) + t.amount;
      } else {
        dailyIncome[index] = (dailyIncome[index] ?? 0) + t.amount;
      }
    }
    
    // Get indices that have data
    final incomeDays = dailyIncome.keys.toList()..sort();
    final expenseDays = dailyExpense.keys.toList()..sort();
    
    return Row(
      children: [
        // Income Card
        Expanded(
          child: MiniChartCard(
            title: AppStrings.income,
            amount: totalIncome,
            currency: currency,
            formatter: formatter,
            dailyData: dailyIncome,
            chartDays: incomeDays,
            color: AppTheme.incomeColor,
            icon: Icons.arrow_upward,
            isIncome: true,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        // Expense Card
        Expanded(
          child: MiniChartCard(
            title: AppStrings.expense,
            amount: totalExpense,
            currency: currency,
            formatter: formatter,
            dailyData: dailyExpense,
            chartDays: expenseDays,
            color: AppTheme.expenseColor,
            icon: Icons.arrow_downward,
            isIncome: false,
            isDark: isDark,
          ),
        ),
      ],
    );
  }
}

/// Period selector tabs widget
class PeriodSelector extends StatelessWidget {
  final String selectedPeriod;
  final Function(String) onPeriodChanged;
  final bool isDark;

  const PeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTab('Day', AppStrings.today.substring(0, 1)),
          _buildTab('Month', 'M'),
          _buildTab('Year', 'Y'),
        ],
      ),
    );
  }

  Widget _buildTab(String periodKey, String displayLabel) {
    final isSelected = selectedPeriod == periodKey;
    return GestureDetector(
      onTap: () => onPeriodChanged(periodKey),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppTheme.primaryOrange.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          displayLabel,
          style: TextStyle(
            color: isSelected ? AppTheme.primaryOrange : Colors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
