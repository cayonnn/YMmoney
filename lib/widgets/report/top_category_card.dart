import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/category.dart';
import '../../l10n/app_strings.dart';

/// Top category card with pie chart for expense/income breakdown
class TopCategoryCard extends StatelessWidget {
  final String title;
  final Map<String, double> data;
  final IconData icon;
  final Color iconColor;
  final bool isDark;

  const TopCategoryCard({
    super.key,
    required this.title,
    required this.data,
    required this.icon,
    required this.iconColor,
    required this.isDark,
  });

  List<MapEntry<String, double>> _getTop3(Map<String, double> data) {
    final sorted = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    final top3 = _getTop3(data);
    final total = data.values.isEmpty 
        ? 1.0 
        : data.values.fold(0.0, (sum, v) => sum + v);
    
    // Colors for pie chart
    final colors = [
      Colors.purple.shade400,
      Colors.blue.shade400,
      Colors.teal.shade400,
      Colors.orange.shade400,
      Colors.pink.shade400,
    ];
    
    final cardColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.grey.shade300 : Colors.grey.shade700;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(28),
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
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Content Row
          Row(
            children: [
              // Category List
              Expanded(
                flex: 3,
                child: Column(
                  children: top3.isEmpty
                      ? [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              AppStrings.noDataYet,
                              style: TextStyle(color: Colors.grey.shade500),
                            ),
                          )
                        ]
                      : top3.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          final category = CategoryModel.getById(item.key);
                          final percent = (item.value / total * 100);
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: colors[index % colors.length],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    category?.displayName ?? item.key,
                                    style: TextStyle(
                                      color: subtitleColor,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${percent.toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                ),
              ),
              const SizedBox(width: 20),
              
              // Donut Chart
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 100,
                  child: data.isEmpty
                      ? Center(
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300, width: 8),
                            ),
                          ),
                        )
                      : PieChart(
                          PieChartData(
                            sectionsSpace: 3,
                            centerSpaceRadius: 28,
                            sections: data.entries.toList()
                                .asMap()
                                .entries
                                .take(5)
                                .map((entry) {
                              final index = entry.key;
                              return PieChartSectionData(
                                value: entry.value.value,
                                color: colors[index % colors.length],
                                radius: 20,
                                showTitle: false,
                              );
                            }).toList(),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
