import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../services/database_service.dart';
import '../widgets/balance_card.dart';
import '../widgets/budget_progress.dart';
import '../widgets/category_budget_widget.dart';
import '../models/user_profile.dart';
import '../config/theme.dart';
import '../l10n/app_strings.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> with AutomaticKeepAliveClientMixin {
  final _db = DatabaseService();
  final _budgetController = TextEditingController();
  double _totalBalance = 0;
  double _totalIncome = 0;
  double _totalExpense = 0;
  late UserProfile _profile;
  bool _isLoaded = false;

  @override
  bool get wantKeepAlive => true;

  /// Public method to refresh data from outside
  void refreshData() {
    _loadData();
  }

  @override
  void initState() {
    super.initState();
    _profile = _db.getUserProfile();
    // Defer data loading to allow UI to render first
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data when screen becomes visible
    if (_isLoaded) {
      _loadData();
    }
  }

  void _loadData() {
    final totalIncome = _db.getTotalIncome();
    final totalExpense = _db.getTotalExpense();
    final totalBalance = _db.getBalance();
    final profile = _db.getUserProfile();
    
    setState(() {
      _totalIncome = totalIncome;
      _totalExpense = totalExpense;
      _totalBalance = totalBalance;
      _profile = profile;
      _isLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _loadData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(),
                const SizedBox(height: 24),
                
                // Balance Card
                BalanceCard(
                  totalBalance: _totalBalance,
                  income: _totalIncome,
                  expense: _totalExpense,
                ),
                const SizedBox(height: 20),
                
                // Budget Progress
                BudgetProgressWidget(
                  onTap: _showBudgetEditor,
                ),
                const SizedBox(height: 16),
                
                // Category Budgets
                CategoryBudgetWidget(
                  onBudgetChanged: _loadData,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showBudgetEditor() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentBudget = _db.getCurrentMonthBudget();
    _budgetController.text = currentBudget != null && currentBudget.monthlyLimit > 0
        ? currentBudget.monthlyLimit.toStringAsFixed(0)
        : '';
    
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
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.setMonthlyBudget,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.setSpendingLimit,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _budgetController,
                autofocus: true,
                keyboardType: TextInputType.number,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                decoration: InputDecoration(
                  prefixText: '${_profile.currency} ',
                  prefixStyle: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryOrange,
                  ),
                  hintText: '0',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  filled: true,
                  fillColor: isDark ? AppTheme.surfaceDark : Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(AppStrings.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () async {
                        final budgetText = _budgetController.text.trim();
                        final budget = double.tryParse(budgetText) ?? 0;
                        await _db.setBudget(budget);
                        _loadData();
                        if (mounted) Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text('Save Budget'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final avatarColor = Color(_profile.avatarColorValue);
    return Row(
      children: [
        // Avatar
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [avatarColor, avatarColor.withValues(alpha: 0.7)],
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark ? Colors.grey.shade700 : Colors.white,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              _profile.name.isNotEmpty ? _profile.name[0].toUpperCase() : 'U',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.welcome,
                style: TextStyle(
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
              Text(
                _profile.name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
