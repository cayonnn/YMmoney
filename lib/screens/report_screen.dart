import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../models/category_budget.dart';
import '../config/theme.dart';
import '../l10n/app_strings.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => ReportScreenState();
}

class ReportScreenState extends State<ReportScreen> with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  final _db = DatabaseService();
  String _selectedPeriod = 'Month';
  DateTime _selectedDate = DateTime.now();
  
  List<TransactionModel> _transactions = [];
  Map<String, double> _expenseByCategory = {};
  Map<String, double> _incomeByCategory = {};
  double _totalExpense = 0;
  double _totalIncome = 0;
  Map<int, double> _monthlyExpense = {};
  Map<int, double> _monthlyIncome = {};

  @override
  bool get wantKeepAlive => true;

  /// Public method to refresh data from outside (e.g., after adding transaction)
  void refreshData() {
    _loadData();
  }

  // Computed start date based on selected period and date
  DateTime get _startDate {
    switch (_selectedPeriod) {
      case 'Day':
        return DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
      case 'Month':
        return DateTime(_selectedDate.year, _selectedDate.month, 1);
      case 'Year':
        return DateTime(_selectedDate.year, 1, 1);
      default:
        return DateTime(_selectedDate.year, _selectedDate.month, 1);
    }
  }

  // Computed end date based on selected period and date
  DateTime get _endDate {
    switch (_selectedPeriod) {
      case 'Day':
        return DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 23, 59, 59);
      case 'Month':
        return DateTime(_selectedDate.year, _selectedDate.month + 1, 0, 23, 59, 59);
      case 'Year':
        return DateTime(_selectedDate.year, 12, 31, 23, 59, 59);
      default:
        return DateTime(_selectedDate.year, _selectedDate.month + 1, 0, 23, 59, 59);
    }
  }

  // Display text for current period
  String get _periodDisplayText {
    switch (_selectedPeriod) {
      case 'Day':
        return DateFormat('dd MMM yyyy').format(_selectedDate);
      case 'Month':
        return DateFormat('MMMM yyyy').format(_selectedDate);
      case 'Year':
        return DateFormat('yyyy').format(_selectedDate);
      default:
        return DateFormat('MMMM yyyy').format(_selectedDate);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Defer data loading to allow UI to render first
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh data when app returns to foreground
    if (state == AppLifecycleState.resumed) {
      _loadData();
    }
  }

  void _updatePeriod(String period) {
    setState(() {
      _selectedPeriod = period;
      _selectedDate = DateTime.now(); // Reset to current date when switching period
    });
    _loadData();
  }

  void _goToPreviousPeriod() {
    setState(() {
      switch (_selectedPeriod) {
        case 'Day':
          _selectedDate = _selectedDate.subtract(const Duration(days: 1));
          break;
        case 'Month':
          _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
          break;
        case 'Year':
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
      case 'Day':
        nextDate = _selectedDate.add(const Duration(days: 1));
        break;
      case 'Month':
        nextDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
        break;
      case 'Year':
        nextDate = DateTime(_selectedDate.year + 1, 1, 1);
        break;
      default:
        nextDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
    }
    
    // Don't go beyond current date
    if (nextDate.isBefore(now) || nextDate.isAtSameMomentAs(now)) {
      setState(() => _selectedDate = nextDate);
      _loadData();
    }
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

  void _loadData() {
    final transactions = _db.getTransactionsByDateRange(_startDate, _endDate);
    
    Map<String, double> expenseMap = {};
    Map<String, double> incomeMap = {};
    
    // Calculate category totals from current period
    for (var t in transactions) {
      if (t.isExpense) {
        expenseMap[t.categoryId] = (expenseMap[t.categoryId] ?? 0) + t.amount;
      } else {
        incomeMap[t.categoryId] = (incomeMap[t.categoryId] ?? 0) + t.amount;
      }
    }
    
    // Get chart data from wider range based on period
    DateTime chartStart;
    DateTime chartEnd;
    
    switch (_selectedPeriod) {
      case 'Day':
        // Chart shows all days of the selected month
        chartStart = DateTime(_selectedDate.year, _selectedDate.month, 1);
        chartEnd = DateTime(_selectedDate.year, _selectedDate.month + 1, 0, 23, 59, 59);
        break;
      case 'Month':
        // Chart shows all months of the selected year
        chartStart = DateTime(_selectedDate.year, 1, 1);
        chartEnd = DateTime(_selectedDate.year, 12, 31, 23, 59, 59);
        break;
      case 'Year':
        // Chart shows 5 years including selected year
        chartStart = DateTime(_selectedDate.year - 4, 1, 1);
        chartEnd = DateTime(_selectedDate.year, 12, 31, 23, 59, 59);
        break;
      default:
        chartStart = _startDate;
        chartEnd = _endDate;
    }
    
    final chartTransactions = _db.getTransactionsByDateRange(chartStart, chartEnd);
    Map<int, double> periodExpenseMap = {};
    Map<int, double> periodIncomeMap = {};
    
    for (var t in chartTransactions) {
      int key;
      switch (_selectedPeriod) {
        case 'Day':
          key = t.date.day; // Group by day for Day view
          break;
        case 'Month':
          key = t.date.month; // Group by month for Month view
          break;
        case 'Year':
        default:
          key = t.date.year; // Group by year for Year view
          break;
      }
      
      if (t.isExpense) {
        periodExpenseMap[key] = (periodExpenseMap[key] ?? 0) + t.amount;
      } else {
        periodIncomeMap[key] = (periodIncomeMap[key] ?? 0) + t.amount;
      }
    }
    
    // Calculate totals from current period
    double totalExp = transactions.where((t) => t.isExpense).fold(0.0, (sum, t) => sum + t.amount);
    double totalInc = transactions.where((t) => !t.isExpense).fold(0.0, (sum, t) => sum + t.amount);
    
    setState(() {
      _transactions = transactions;
      _expenseByCategory = expenseMap;
      _incomeByCategory = incomeMap;
      _monthlyExpense = periodExpenseMap;
      _monthlyIncome = periodIncomeMap;
      _totalExpense = totalExp;
      _totalIncome = totalInc;
    });
  }

  List<MapEntry<String, double>> _getTop3(Map<String, double> data) {
    final sorted = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(3).toList();
  }

  List<int> _selectEveryNth(List<int> list, int n) {
    List<int> result = [];
    for (int i = 0; i < list.length; i += n) {
      result.add(list[i]);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final formatter = NumberFormat('#,##0.00', 'en_US');
    final currency = _db.getUserProfile().currency;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Balance Card with Bar Chart
              _buildMainCard(currency, formatter, isDark),
              const SizedBox(height: 20),
              
              // Combined Income & Expense Chart Card
              _buildCombinedChartCard(currency, formatter, isDark),
              const SizedBox(height: 20),
              
              // Top Expense Card
              _buildTopCategoryCard(
                title: AppStrings.topExpense,
                data: _expenseByCategory,
                icon: Icons.arrow_downward,
                iconColor: AppTheme.expenseColor,
                isDark: isDark,
              ),
              const SizedBox(height: 20),
              
              // Top Income Card
              _buildTopCategoryCard(
                title: AppStrings.topIncome,
                data: _incomeByCategory,
                icon: Icons.arrow_upward,
                iconColor: AppTheme.incomeColor,
                isDark: isDark,
              ),
              const SizedBox(height: 20),
              
              // Category Budget Progress
              _buildCategoryBudgetSection(currency, formatter, isDark),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainCard(String currency, NumberFormat formatter, bool isDark) {
    // Use shared max value so proportions are accurate
    final allValues = [..._monthlyExpense.values, ..._monthlyIncome.values];
    final maxValue = allValues.isEmpty ? 1.0 : allValues.reduce((a, b) => a > b ? a : b);
    
    final balance = _totalIncome - _totalExpense;
    final cardColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    
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
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${AppStrings.income} / ${AppStrings.expense}',
                        style: TextStyle(
                          color: subtitleColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '$currency ${formatter.format(balance.abs())}',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (balance >= 0 ? AppTheme.incomeColor : AppTheme.expenseColor)
                              .withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          balance >= 0 ? '+' : '-',
                          style: TextStyle(
                            color: balance >= 0 ? AppTheme.incomeColor : AppTheme.expenseColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Period Selector Tabs
              _buildPeriodSelector(isDark),
            ],
          ),
          const SizedBox(height: 16),
          
          // Legend
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppTheme.incomeColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 6),
              Text(AppStrings.income, style: TextStyle(color: subtitleColor, fontSize: 12)),
              const SizedBox(width: 16),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.purple.shade400,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 6),
              Text(AppStrings.expense, style: TextStyle(color: subtitleColor, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 16),
          
          // Period Navigation with arrows
          Row(
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
          const SizedBox(height: 24),
          
          // Dynamic Bar Chart based on selected period
          SizedBox(
            height: 150,
            child: _buildPeriodBarChart(maxValue, isDark, subtitleColor),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodBarChart(double maxValue, bool isDark, Color subtitleColor) {
    // Get sorted keys and limit display items based on period
    final keys = {..._monthlyExpense.keys, ..._monthlyIncome.keys}.toList()..sort();
    
    if (keys.isEmpty) {
      return Center(
        child: Text(
          AppStrings.noData,
          style: TextStyle(color: subtitleColor),
        ),
      );
    }
    
    // Determine how many bars to show and labels
    List<int> displayKeys;
    String Function(int) labelBuilder;
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    switch (_selectedPeriod) {
      case 'Day':
        // Show days (limit to 15 bars)
        displayKeys = keys.length > 15 ? _selectEveryNth(keys, 2) : keys;
        labelBuilder = (key) => '$key';
        break;
      case 'Month':
        // Show all 12 months
        displayKeys = keys;
        labelBuilder = (key) => months[(key - 1) % 12];
        break;
      case 'Year':
      default:
        // Show years (last 2 digits)
        displayKeys = keys;
        labelBuilder = (key) => '\'${key.toString().substring(2)}';
        break;
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: displayKeys.map((key) {
        final expenseValue = _monthlyExpense[key] ?? 0;
        final incomeValue = _monthlyIncome[key] ?? 0;
        
        // Calculate height using shared max for accurate proportions
        double expenseHeight = maxValue > 0 ? (expenseValue / maxValue * 100) : 0;
        double incomeHeight = maxValue > 0 ? (incomeValue / maxValue * 100) : 0;
        if (expenseValue > 0 && expenseHeight < 15) expenseHeight = 15;
        if (incomeValue > 0 && incomeHeight < 15) incomeHeight = 15;
        
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Income Bar (Green)
                Container(
                  width: 14,
                  height: incomeHeight.clamp(8, 100),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.incomeColor.withValues(alpha: 0.7),
                        AppTheme.incomeColor,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
                const SizedBox(width: 4),
                // Expense Bar (Purple)
                Container(
                  width: 14,
                  height: expenseHeight.clamp(8, 100),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.purple.shade300,
                        Colors.purple.shade600,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              labelBuilder(key),
              style: TextStyle(
                color: subtitleColor,
                fontSize: 12,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildCombinedChartCard(String currency, NumberFormat formatter, bool isDark) {
    // Group data by date index (sequential) for proper chart display
    Map<int, double> dailyIncome = {};
    Map<int, double> dailyExpense = {};
    
    // Sort transactions by date first
    final sortedTransactions = List.from(_transactions)
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
          child: _buildMiniChartCard(
            title: AppStrings.income,
            amount: _totalIncome,
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
          child: _buildMiniChartCard(
            title: AppStrings.expense,
            amount: _totalExpense,
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

  Widget _buildMiniChartCard({
    required String title,
    required double amount,
    required String currency,
    required NumberFormat formatter,
    required Map<int, double> dailyData,
    required List<int> chartDays,
    required Color color,
    required IconData icon,
    required bool isIncome,
    required bool isDark,
  }) {
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
                    ? _buildSinglePointIndicator(color, isDark)
                    : LineChart(
                        LineChartData(
                          gridData: FlGridData(show: false),
                          titlesData: FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          minX: chartDays.first.toDouble() - 0.5,
                          maxX: chartDays.last.toDouble() + 0.5,
                          minY: 0,
                          maxY: maxValue * 1.2,
                          lineTouchData: LineTouchData(enabled: false),
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
                          dotData: FlDotData(show: false),
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

  Widget _buildSinglePointIndicator(Color color, bool isDark) {
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

  Widget _buildTopCategoryCard({
    required String title,
    required Map<String, double> data,
    required IconData icon,
    required Color iconColor,
    required bool isDark,
  }) {
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

  Widget _buildCategoryBudgetSection(String currency, NumberFormat formatter, bool isDark) {
    // Get all expense categories with spending, sorted by amount (highest first)
    final sortedExpenses = _expenseByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    if (sortedExpenses.isEmpty) {
      return const SizedBox.shrink();
    }
    
    // Get budget data for categories that have budgets for the selected period
    final budgetSummary = _db.getCategoryBudgetSummary(
      year: _selectedDate.year,
      month: _selectedDate.month,
    );
    final budgetMap = <String, Map<String, dynamic>>{};
    for (var item in budgetSummary) {
      final budget = item['budget'] as CategoryBudget;
      budgetMap[budget.categoryId] = item;
    }
    
    final cardColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryOrange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.pie_chart_outline,
                  color: AppTheme.primaryOrange,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                AppStrings.categoryBudget,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // All expense categories sorted by amount
          ...sortedExpenses.map((entry) {
            final categoryId = entry.key;
            final spent = entry.value;
            final category = CategoryModel.getById(categoryId);
            final hasBudget = budgetMap.containsKey(categoryId);
            
            // Get budget info if available
            double? budgetLimit;
            double? remaining;
            double progress = 0;
            bool isOver = false;
            
            if (hasBudget) {
              final budgetInfo = budgetMap[categoryId]!;
              final budget = budgetInfo['budget'] as CategoryBudget;
              budgetLimit = budget.limit;
              remaining = budgetInfo['remaining'] as double;
              progress = (budgetInfo['progress'] as double).clamp(0.0, 1.0);
              isOver = budgetInfo['isOver'] as bool;
            }
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                children: [
                  // Category header row
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: (category?.color ?? Colors.grey).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          category?.icon ?? Icons.category,
                          color: category?.color ?? Colors.grey,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category?.displayName ?? categoryId,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              hasBudget 
                                  ? '${AppStrings.budget}: $currency${formatter.format(budgetLimit)}'
                                  : AppStrings.noBudgetSet,
                              style: TextStyle(
                                fontSize: 11,
                                color: subtitleColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$currency${formatter.format(spent)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isOver ? Colors.red : textColor,
                            ),
                          ),
                          if (hasBudget)
                            Text(
                              isOver 
                                  ? '${AppStrings.overAmount} $currency${formatter.format(remaining!.abs())}'
                                  : '${AppStrings.leftAmount} $currency${formatter.format(remaining)}',
                              style: TextStyle(
                                fontSize: 11,
                                color: isOver ? Colors.red.shade300 : AppTheme.incomeColor,
                              ),
                            ),
                      ],
                      ),
                    ],
                  ),
                  // Progress bar - only for categories with budget
                  if (hasBudget) ...[
                    const SizedBox(height: 8),
                    Stack(
                      children: [
                        Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: progress,
                          child: Container(
                            height: 6,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isOver 
                                    ? [Colors.red.shade400, Colors.red.shade600]
                                    : progress > 0.8
                                        ? [Colors.orange.shade400, Colors.orange.shade600]
                                        : [AppTheme.incomeColor, AppTheme.incomeColor.withValues(alpha: 0.8)],
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
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
          _buildPeriodTab('Day', AppStrings.day, isDark),
          _buildPeriodTab('Month', AppStrings.month, isDark),
          _buildPeriodTab('Year', AppStrings.year, isDark),
        ],
      ),
    );
  }

  Widget _buildPeriodTab(String periodKey, String displayLabel, bool isDark) {
    final isSelected = _selectedPeriod == periodKey;
    return GestureDetector(
      onTap: () => _updatePeriod(periodKey),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryOrange : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          displayLabel,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
          ),
        ),
      ),
    );
  }
}
