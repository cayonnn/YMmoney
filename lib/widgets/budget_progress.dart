import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';
import '../config/theme.dart';
import '../l10n/app_strings.dart';

class BudgetProgressWidget extends StatelessWidget {
  final VoidCallback? onTap;

  const BudgetProgressWidget({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final db = DatabaseService();
    final budget = db.getCurrentMonthBudget();
    final spent = db.getCurrentMonthExpense();
    final profile = db.getUserProfile();
    final currency = profile.currency;
    final formatter = NumberFormat('#,##0.00', 'en_US');

    // No budget set
    if (budget == null || budget.monthlyLimit <= 0) {
      return _buildNoBudget(context, currency);
    }

    final limit = budget.monthlyLimit;
    final remaining = limit - spent;
    final progress = (spent / limit).clamp(0.0, 1.0);
    final isOverBudget = spent > limit;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color ?? (Theme.of(context).brightness == Brightness.dark ? AppTheme.cardBackgroundDark : Colors.white),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isOverBudget
                            ? Colors.red.withValues(alpha: 0.1)
                            : AppTheme.primaryOrange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.account_balance_wallet,
                        color: isOverBudget ? Colors.red : AppTheme.primaryOrange,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      AppStrings.monthlyBudget,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Progress Bar
            Stack(
              children: [
                // Background
                Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.grey.shade800 
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                // Progress
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isOverBudget
                            ? [Colors.red.shade400, Colors.red.shade600]
                            : [AppTheme.primaryOrange, AppTheme.primaryYellow],
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatColumn(
                  AppStrings.spent,
                  '$currency${formatter.format(spent)}',
                  isOverBudget ? Colors.red : AppTheme.primaryOrange,
                ),
                _buildStatColumn(
                  AppStrings.limit,
                  '$currency${formatter.format(limit)}',
                  Colors.grey.shade600,
                ),
                _buildStatColumn(
                  isOverBudget ? AppStrings.overBudget : AppStrings.remaining,
                  isOverBudget
                      ? '$currency${formatter.format(-remaining)}'
                      : '$currency${formatter.format(remaining)}',
                  isOverBudget ? Colors.red : AppTheme.incomeColor,
                ),
              ],
            ),

            // Warning if over budget
            if (isOverBudget) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.red, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      AppStrings.exceededBudget,
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNoBudget(BuildContext context, String currency) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color ?? (isDark ? AppTheme.cardBackgroundDark : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.primaryOrange.withValues(alpha: 0.3),
            width: 2,
            style: BorderStyle.solid,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryOrange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.add_circle_outline,
                color: AppTheme.primaryOrange,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.setMonthlyBudget,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppStrings.controlSpending,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppTheme.primaryOrange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}
