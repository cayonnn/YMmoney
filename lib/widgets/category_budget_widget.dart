import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../models/category.dart';
import '../models/category_budget.dart';
import '../services/database_service.dart';
import '../l10n/app_strings.dart';

/// Widget to display and manage category-specific budget progress
class CategoryBudgetWidget extends StatefulWidget {
  final VoidCallback? onTap;
  final VoidCallback? onBudgetChanged;

  const CategoryBudgetWidget({
    super.key,
    this.onTap,
    this.onBudgetChanged,
  });

  @override
  State<CategoryBudgetWidget> createState() => _CategoryBudgetWidgetState();
}

class _CategoryBudgetWidgetState extends State<CategoryBudgetWidget> {
  final _db = DatabaseService();
  final _limitController = TextEditingController();
  List<Map<String, dynamic>> _budgetSummary = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  void _loadData() {
    setState(() {
      _budgetSummary = _db.getCategoryBudgetSummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = _db.getUserProfile();
    final currency = profile.currency;
    final formatter = NumberFormat('#,##0.00', 'en_US');

    if (_budgetSummary.isEmpty) {
      return _buildEmptyState(context, isDark);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardBackgroundDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
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
                      color: AppTheme.primaryOrange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.pie_chart_outline,
                      color: AppTheme.primaryOrange,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    AppStrings.categoryBudget,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => _showAddCategoryBudget(context, isDark),
                icon: Icon(
                  Icons.add_circle_outline,
                  color: AppTheme.primaryOrange,
                ),
                tooltip: 'Add Category Budget',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Category Budget List
          ...(_budgetSummary.take(5).map((item) {
            final budget = item['budget'] as CategoryBudget;
            final spent = item['spent'] as double;
            final progress = (item['progress'] as double).clamp(0.0, 1.0);
            final isOver = item['isOver'] as bool;
            final category = CategoryModel.getById(budget.categoryId);

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GestureDetector(
                onTap: () => _showEditCategoryBudget(context, isDark, budget),
                onLongPress: () => _showDeleteConfirmation(context, budget),
                child: _buildCategoryBudgetItem(
                  category: category,
                  spent: spent,
                  limit: budget.limit,
                  progress: progress,
                  isOver: isOver,
                  currency: currency,
                  formatter: formatter,
                  isDark: isDark,
                ),
              ),
            );
          }).toList()),

          // View All if more than 5
          if (_budgetSummary.length > 5)
            Center(
              child: TextButton(
                onPressed: () => _showAllCategoryBudgets(context, isDark),
                child: Text(
                  'View All (${_budgetSummary.length})',
                  style: TextStyle(
                    color: AppTheme.primaryOrange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () => _showAddCategoryBudget(context, isDark),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cardBackgroundDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.primaryOrange.withValues(alpha: 0.3),
            width: 1.5,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryOrange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.pie_chart_outline,
                color: AppTheme.primaryOrange,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.setCategoryBudget,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppStrings.setCategoryBudgetDesc,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.add_circle,
              color: AppTheme.primaryOrange,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBudgetItem({
    required CategoryModel? category,
    required double spent,
    required double limit,
    required double progress,
    required bool isOver,
    required String currency,
    required NumberFormat formatter,
    required bool isDark,
  }) {
    final progressColor = isOver 
        ? Colors.red 
        : progress > 0.8 
            ? Colors.orange 
            : AppTheme.primaryOrange;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Info Row
        Row(
          children: [
            // Category Icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: (category?.color ?? Colors.grey).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                category?.icon ?? Icons.category,
                color: category?.color ?? Colors.grey,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            // Category Name
            Expanded(
              child: Text(
                category?.displayName ?? 'Unknown',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            // Amount Info
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$currency${formatter.format(spent)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isOver ? Colors.red : (isDark ? Colors.white : Colors.black87),
                  ),
                ),
                Text(
                  'of $currency${formatter.format(limit)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Progress Bar
        Stack(
          children: [
            // Background
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            // Progress
            FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      progressColor.withValues(alpha: 0.7),
                      progressColor,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ],
        ),
        // Over Budget Warning
        if (isOver)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.red, size: 14),
                const SizedBox(width: 4),
                Text(
                  'Over by $currency${formatter.format(spent - limit)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _showAddCategoryBudget(BuildContext context, bool isDark) {
    String? selectedCategoryId;
    _limitController.clear();
    
    // Get expense categories that don't have a budget yet
    final existingBudgetIds = _budgetSummary
        .map((b) => (b['budget'] as CategoryBudget).categoryId)
        .toSet();
    
    final availableCategories = CategoryModel.expenseCategories
        .where((c) => !existingBudgetIds.contains(c.id)).toList();

    if (availableCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('All categories already have budgets'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppTheme.cardBackgroundDark : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Title
                    Text(
                      AppStrings.addCategoryBudget,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Category Selector
                    Text(
                      AppStrings.selectCategory,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: availableCategories.length,
                        itemBuilder: (context, index) {
                          final cat = availableCategories[index];
                          final isSelected = selectedCategoryId == cat.id;
                          return GestureDetector(
                            onTap: () {
                              setDialogState(() {
                                selectedCategoryId = cat.id;
                              });
                            },
                            child: Container(
                              width: 70,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? cat.color.withValues(alpha: 0.2)
                                    : (isDark ? Colors.grey.shade800 : Colors.grey.shade100),
                                borderRadius: BorderRadius.circular(12),
                                border: isSelected
                                    ? Border.all(color: cat.color, width: 2)
                                    : null,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    cat.icon,
                                    color: cat.color,
                                    size: 24,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    cat.displayName,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isDark ? Colors.white70 : Colors.black54,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Limit Input
                    Text(
                      AppStrings.monthlyLimit,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _limitController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      decoration: InputDecoration(
                        prefixText: '${_db.getUserProfile().currency} ',
                        prefixStyle: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                        hintText: '0',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                        ),
                        filled: true,
                        fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: selectedCategoryId == null
                            ? null
                            : () async {
                                final limit = double.tryParse(_limitController.text) ?? 0;
                                if (limit > 0 && selectedCategoryId != null) {
                                  await _db.setCategoryBudget(selectedCategoryId!, limit);
                                  if (mounted) Navigator.pop(context);
                                  _loadData();
                                  widget.onBudgetChanged?.call();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryOrange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          disabledBackgroundColor: Colors.grey.shade400,
                        ),
                        child: Text(
                          AppStrings.save,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showEditCategoryBudget(BuildContext context, bool isDark, CategoryBudget budget) {
    _limitController.text = budget.limit.toStringAsFixed(0);
    final category = CategoryModel.getById(budget.categoryId);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.cardBackgroundDark : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Title & Category
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: (category?.color ?? Colors.grey).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          category?.icon ?? Icons.category,
                          color: category?.color ?? Colors.grey,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.editCategoryBudget,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            Text(
                              category?.displayName ?? 'Unknown',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Limit Input
                  TextField(
                    controller: _limitController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      prefixText: '${_db.getUserProfile().currency} ',
                      prefixStyle: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                      filled: true,
                      fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Buttons Row
                  Row(
                    children: [
                      // Delete Button
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _showDeleteConfirmation(context, budget);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(AppStrings.delete),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Save Button
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () async {
                            final limit = double.tryParse(_limitController.text) ?? 0;
                            if (limit > 0) {
                              await _db.setCategoryBudget(budget.categoryId, limit);
                              Navigator.pop(context);
                              _loadData();
                              widget.onBudgetChanged?.call();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryOrange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(AppStrings.save),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, CategoryBudget budget) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final category = CategoryModel.getById(budget.categoryId);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.cardBackgroundDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          AppStrings.deleteBudget,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
        content: Text(
          'Remove budget limit for ${category?.displayName ?? "this category"}?',
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppStrings.cancel,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          TextButton(
            onPressed: () async {
              await _db.deleteCategoryBudget(budget.categoryId);
              Navigator.pop(context);
              _loadData();
              widget.onBudgetChanged?.call();
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showAllCategoryBudgets(BuildContext context, bool isDark) {
    final profile = _db.getUserProfile();
    final currency = profile.currency;
    final formatter = NumberFormat('#,##0.00', 'en_US');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.cardBackgroundDark : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.allCategoryBudgets,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showAddCategoryBudget(context, isDark);
                      },
                      icon: Icon(
                        Icons.add_circle,
                        color: AppTheme.primaryOrange,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // List
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  itemCount: _budgetSummary.length,
                  itemBuilder: (context, index) {
                    final item = _budgetSummary[index];
                    final budget = item['budget'] as CategoryBudget;
                    final spent = item['spent'] as double;
                    final progress = (item['progress'] as double).clamp(0.0, 1.0);
                    final isOver = item['isOver'] as bool;
                    final category = CategoryModel.getById(budget.categoryId);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          _showEditCategoryBudget(context, isDark, budget);
                        },
                        child: _buildCategoryBudgetItem(
                          category: category,
                          spent: spent,
                          limit: budget.limit,
                          progress: progress,
                          isOver: isOver,
                          currency: currency,
                          formatter: formatter,
                          isDark: isDark,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
