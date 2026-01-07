import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';
import '../models/transaction.dart';
import '../widgets/expense_chart.dart';
import '../widgets/transaction_item.dart';
import '../widgets/type_toggle.dart';
import '../models/category.dart'; // Added import for category filtering
import '../config/theme.dart';
import '../l10n/app_strings.dart';
import 'add_transaction_screen.dart';

enum TimePeriod { day, month, year }

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => TransactionsScreenState();
}

class TransactionsScreenState extends State<TransactionsScreen> with AutomaticKeepAliveClientMixin {
  final _db = DatabaseService();
  bool _showExpenses = true;
  TimePeriod _selectedPeriod = TimePeriod.month;
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategoryId; // Added for category filter
  
  List<TransactionModel> _transactions = [];
  Map<int, double> _chartData = {};
  double _totalAmount = 0;

  @override
  bool get wantKeepAlive => true;

  /// Public method to refresh data from outside
  void refreshData() {
    _loadData();
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  DateTime get _startDate {
    switch (_selectedPeriod) {
      case TimePeriod.day:
        return DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
      case TimePeriod.month:
        return DateTime(_selectedDate.year, _selectedDate.month, 1);
      case TimePeriod.year:
        return DateTime(_selectedDate.year, 1, 1);
    }
  }

  DateTime get _endDate {
    switch (_selectedPeriod) {
      case TimePeriod.day:
        return DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 23, 59, 59);
      case TimePeriod.month:
        return DateTime(_selectedDate.year, _selectedDate.month + 1, 0, 23, 59, 59);
      case TimePeriod.year:
        return DateTime(_selectedDate.year, 12, 31, 23, 59, 59);
    }
  }

  String get _periodDisplayText {
    switch (_selectedPeriod) {
      case TimePeriod.day:
        return DateFormat('dd MMM yyyy').format(_selectedDate);
      case TimePeriod.month:
        return DateFormat('MMMM yyyy').format(_selectedDate);
      case TimePeriod.year:
        return DateFormat('yyyy').format(_selectedDate);
    }
  }

  // Chart date range depends on mode:
  // Day -> show all days of month
  // Month -> show all months of year  
  // Year -> show multiple years
  DateTime get _chartStartDate {
    switch (_selectedPeriod) {
      case TimePeriod.day:
        return DateTime(_selectedDate.year, _selectedDate.month, 1);
      case TimePeriod.month:
        return DateTime(_selectedDate.year, 1, 1);
      case TimePeriod.year:
        return DateTime(_selectedDate.year - 4, 1, 1);
    }
  }

  DateTime get _chartEndDate {
    switch (_selectedPeriod) {
      case TimePeriod.day:
        return DateTime(_selectedDate.year, _selectedDate.month + 1, 0, 23, 59, 59);
      case TimePeriod.month:
        return DateTime(_selectedDate.year, 12, 31, 23, 59, 59);
      case TimePeriod.year:
        return DateTime(_selectedDate.year, 12, 31, 23, 59, 59);
    }
  }

  void _loadData() {
    // Get transactions for the selected period (for list)
    final allTransactions = _db.getTransactionsByDateRange(_startDate, _endDate);
    var filteredTransactions = allTransactions
        .where((t) => t.isExpense == _showExpenses)
        .toList();

    // Apply category filter if selected
    if (_selectedCategoryId != null) {
      filteredTransactions = filteredTransactions
          .where((t) => t.categoryId == _selectedCategoryId)
          .toList();
    }
    
    final totalAmount = filteredTransactions.fold(0.0, (sum, t) => sum + t.amount);
    
    // Get transactions for chart (wider range based on period type)
    var chartTransactions = _db.getTransactionsByDateRange(_chartStartDate, _chartEndDate)
        .where((t) => t.isExpense == _showExpenses)
        .toList();

    // Ideally chart should also reflect filter, but usually charts show overall breakdown.
    // Let's filter chart too for consistency if user drills down.
    if (_selectedCategoryId != null) {
      chartTransactions = chartTransactions
          .where((t) => t.categoryId == _selectedCategoryId)
          .toList();
    }
    
    Map<int, double> chartData = {};
    
    switch (_selectedPeriod) {
      case TimePeriod.day:
        // Show all days of the month
        final daysInMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;
        for (int i = 1; i <= daysInMonth; i++) {
          chartData[i] = 0;
        }
        for (var t in chartTransactions) {
          final day = t.date.day;
          chartData[day] = (chartData[day] ?? 0) + t.amount;
        }
        break;
        
      case TimePeriod.month:
        // Show all months of the year
        for (int i = 1; i <= 12; i++) {
          chartData[i] = 0;
        }
        for (var t in chartTransactions) {
          final month = t.date.month;
          chartData[month] = (chartData[month] ?? 0) + t.amount;
        }
        break;
        
      case TimePeriod.year:
        // Show last 5 years
        final currentYear = _selectedDate.year;
        for (int i = currentYear - 4; i <= currentYear; i++) {
          chartData[i] = 0;
        }
        for (var t in chartTransactions) {
          final year = t.date.year;
          if (chartData.containsKey(year)) {
            chartData[year] = (chartData[year] ?? 0) + t.amount;
          }
        }
        break;
    }
    
    setState(() {
      _transactions = filteredTransactions;
      _totalAmount = totalAmount;
      _chartData = chartData;
    });
  }

  void _goToPreviousPeriod() {
    setState(() {
      switch (_selectedPeriod) {
        case TimePeriod.day:
          _selectedDate = _selectedDate.subtract(const Duration(days: 1));
          break;
        case TimePeriod.month:
          _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
          break;
        case TimePeriod.year:
          _selectedDate = DateTime(_selectedDate.year - 1, 1, 1);
          break;
      }
    });
    _loadData();
  }

  void _goToNextPeriod() {
    final now = DateTime.now();
    DateTime nextDate;
    
    switch (_selectedPeriod) {
      case TimePeriod.day:
        nextDate = _selectedDate.add(const Duration(days: 1));
        break;
      case TimePeriod.month:
        nextDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
        break;
      case TimePeriod.year:
        nextDate = DateTime(_selectedDate.year + 1, 1, 1);
        break;
    }
    
    // Don't go beyond current date
    if (nextDate.isBefore(now) || nextDate.isAtSameMomentAs(now)) {
      setState(() => _selectedDate = nextDate);
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final currencyFormatter = NumberFormat('#,##0.00', 'en_US');
    final maxValue = _chartData.values.isEmpty 
        ? 5000.0 
        : _chartData.values.reduce((a, b) => a > b ? a : b);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          AppStrings.transactions,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          // Period Selector
          _buildPeriodSelector(isDark),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Toggle Tabs
              Container(
                margin: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 10),
                child: TypeToggle(
                  isExpense: _showExpenses,
                  onChanged: (value) {
                    setState(() {
                      _showExpenses = value;
                      _selectedCategoryId = null; // Reset filter
                    });
                    _loadData();
                  },
                ),
              ),
              
              // Category Filter
              _buildCategoryFilterList(),
              
              // Period Navigation
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.chevron_left, color: AppTheme.primaryOrange),
                      onPressed: _goToPreviousPeriod,
                    ),
                    GestureDetector(
                      onTap: _showDatePicker,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryOrange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _periodDisplayText,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryOrange,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.chevron_right, color: AppTheme.primaryOrange),
                      onPressed: _goToNextPeriod,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Total Amount
              Center(
                child: Text(
                  '฿${currencyFormatter.format(_totalAmount)}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              // Chart - always show
              if (_chartData.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: ExpenseChart(
                    chartData: _chartData,
                    maxY: maxValue,
                    periodType: _selectedPeriod,
                  ),
                ),
              
              // Divider
              Container(
                height: 8,
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
              ),
              
              // Transaction Count Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  '${_transactions.length} ${_showExpenses ? AppStrings.expense : AppStrings.income}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              
              // Transactions List
              if (_transactions.isEmpty)
                _buildEmptyState()
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: _transactions.map((transaction) => TransactionItem(
                      transaction: transaction,
                      onEdit: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            fullscreenDialog: true,
                            builder: (context) => AddTransactionScreen(
                              transactionToEdit: transaction,
                              onTransactionAdded: _loadData,
                            ),
                          ),
                        );
                      },
                      onDelete: () {
                        _db.deleteTransaction(transaction.id);
                        _loadData();
                      },
                    )).toList(),
                  ),
                ),
              
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodSelector(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPeriodTab(AppStrings.day, TimePeriod.day, isDark),
          _buildPeriodTab(AppStrings.month, TimePeriod.month, isDark),
          _buildPeriodTab(AppStrings.year, TimePeriod.year, isDark),
        ],
      ),
    );
  }

  Widget _buildPeriodTab(String label, TimePeriod period, bool isDark) {
    final isSelected = _selectedPeriod == period;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = period;
          _selectedDate = DateTime.now(); // Reset to current date when switching period
        });
        _loadData();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryOrange : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.receipt_long,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              _showExpenses ? AppStrings.noTransactions : AppStrings.noIncomeYet,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryOrange,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
      _loadData();
    }
  }

  Widget _buildCategoryFilterList() {
    // Get categories based on current type
    final categories = _showExpenses 
        ? CategoryModel.expenseCategories 
        : CategoryModel.incomeCategories;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 0).copyWith(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.2),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: _selectedCategoryId,
          hint: Row(
            children: [
              const Icon(Icons.filter_list, size: 20, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                AppStrings.all,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
          onChanged: (String? newValue) {
            setState(() => _selectedCategoryId = newValue);
            _loadData();
          },
          items: [
            // "All" Option
            DropdownMenuItem<String?>(
              value: null,
              child: Row(
                children: [
                  const Icon(Icons.list, size: 20, color: Colors.grey),
                  const SizedBox(width: 12),
                  Text(
                    AppStrings.all,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            ),
            // Category Options
            ...categories.map((CategoryModel category) {
              return DropdownMenuItem<String?>(
                value: category.id,
                child: Row(
                  children: [
                    Icon(
                      category.icon,
                      size: 20,
                      color: category.color,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        category.displayName,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

