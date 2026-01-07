import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../l10n/app_strings.dart';

/// Reusable Expense/Income toggle widget
/// Used in: AddTransactionScreen, AddRecurringScreen, AddCategoryScreen, TransactionsScreen
class TypeToggle extends StatelessWidget {
  final bool isExpense;
  final ValueChanged<bool> onChanged;
  final String? expenseLabel;
  final String? incomeLabel;

  const TypeToggle({
    super.key,
    required this.isExpense,
    required this.onChanged,
    this.expenseLabel,
    this.incomeLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _buildTab(
            text: expenseLabel ?? AppStrings.expense,
            isSelected: isExpense,
            isExpenseTab: true,
            onTap: () => onChanged(true),
          ),
          _buildTab(
            text: incomeLabel ?? AppStrings.income,
            isSelected: !isExpense,
            isExpenseTab: false,
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required String text,
    required bool isSelected,
    required bool isExpenseTab,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? (isExpenseTab ? AppTheme.primaryOrange : AppTheme.incomeColor)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
