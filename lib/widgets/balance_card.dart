import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../l10n/app_strings.dart';

class BalanceCard extends StatelessWidget {
  final double totalBalance;
  final double income;
  final double expense;

  const BalanceCard({
    super.key,
    required this.totalBalance,
    required this.income,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2D2D2D),
            Color(0xFF1A1A1A),
            Color(0xFF0D0D0D),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.totalBalance,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '฿ ${formatter.format(totalBalance)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildIndicator(
                icon: Icons.arrow_downward,
                label: AppStrings.income,
                amount: income,
                formatter: formatter,
                iconColor: Colors.greenAccent,
              ),
              _buildIndicator(
                icon: Icons.arrow_upward,
                label: AppStrings.expense,
                amount: expense,
                formatter: formatter,
                iconColor: Colors.redAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator({
    required IconData icon,
    required String label,
    required double amount,
    required NumberFormat formatter,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12,
              ),
            ),
            Text(
              formatter.format(amount),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
