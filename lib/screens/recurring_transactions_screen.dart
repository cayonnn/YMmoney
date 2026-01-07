import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/recurring_transaction.dart';
import '../models/category.dart';
import '../services/database_service.dart';
import '../config/theme.dart';
import '../l10n/app_strings.dart';
import 'add_recurring_screen.dart';

class RecurringTransactionsScreen extends StatefulWidget {
  const RecurringTransactionsScreen({super.key});

  @override
  State<RecurringTransactionsScreen> createState() => _RecurringTransactionsScreenState();
}

class _RecurringTransactionsScreenState extends State<RecurringTransactionsScreen> {
  final _db = DatabaseService();
  List<RecurringTransaction> _recurringList = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _recurringList = _db.getAllRecurringTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppStrings.recurringTransactions,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: AppTheme.primaryOrange),
            onPressed: _addRecurring,
          ),
        ],
      ),
      body: _recurringList.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _recurringList.length,
              itemBuilder: (context, index) {
                return _buildRecurringItem(_recurringList[index], isDark);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addRecurring,
        backgroundColor: AppTheme.primaryOrange,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(AppStrings.addRecurring, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.repeat,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.noRecurringTransactions,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.addRecurringDesc,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecurringItem(RecurringTransaction recurring, bool isDark) {
    final category = CategoryModel.getById(recurring.categoryId);
    final formatter = NumberFormat('#,##0.00', 'en_US');
    final dateFormatter = DateFormat('dd MMM');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? (isDark ? AppTheme.cardBackgroundDark : Colors.white),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _editRecurring(recurring),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Category Icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: (category?.color ?? Colors.grey).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    category?.icon ?? Icons.repeat,
                    color: category?.color ?? Colors.grey,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              recurring.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (!recurring.isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                AppStrings.paused,
                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${recurring.frequencyText} • Next: ${dateFormatter.format(recurring.getNextDueDate())}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${recurring.isExpense ? '-' : '+'}${recurring.currency}${formatter.format(recurring.amount)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: recurring.isExpense
                            ? Colors.red.shade400
                            : Colors.green.shade400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Toggle
                    Switch.adaptive(
                      value: recurring.isActive,
                      activeTrackColor: AppTheme.primaryOrange,
                      onChanged: (value) async {
                        await _db.toggleRecurringTransaction(recurring.id, value);
                        _loadData();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _addRecurring() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => const AddRecurringScreen(),
      ),
    );
    if (result == true) {
      _loadData();
    }
  }

  void _editRecurring(RecurringTransaction recurring) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => AddRecurringScreen(editRecurring: recurring),
      ),
    );
    if (result == true) {
      _loadData();
    }
  }
}
