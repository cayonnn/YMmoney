import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart';
import '../models/custom_category.dart';
import '../models/user_profile.dart';
import '../models/budget.dart';
import '../models/category_budget.dart';
import '../models/recurring_transaction.dart';
import '../config/constants.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  late Box<TransactionModel> _transactionBox;
  late Box<CustomCategory> _customCategoryBox;
  late Box<UserProfile> _userProfileBox;
  late Box<Budget> _budgetBox;
  late Box<CategoryBudget> _categoryBudgetBox;
  late Box<RecurringTransaction> _recurringBox;
  final _uuid = const Uuid();
  
  bool _isInitialized = false;
  
  // Cache for better performance
  List<TransactionModel>? _cachedTransactions;

  Future<void> init() async {
    if (_isInitialized) return;
    
    try {
      await Hive.initFlutter();
      Hive.registerAdapter(TransactionModelAdapter());
      Hive.registerAdapter(CustomCategoryAdapter());
      Hive.registerAdapter(UserProfileAdapter());
      Hive.registerAdapter(BudgetAdapter());
      Hive.registerAdapter(CategoryBudgetAdapter());
      Hive.registerAdapter(RecurringTransactionAdapter());
      _transactionBox = await Hive.openBox<TransactionModel>(AppConstants.transactionBox);
      _customCategoryBox = await Hive.openBox<CustomCategory>('custom_categories');
      _userProfileBox = await Hive.openBox<UserProfile>('user_profile');
      _budgetBox = await Hive.openBox<Budget>('budgets');
      _categoryBudgetBox = await Hive.openBox<CategoryBudget>('category_budgets');
      _recurringBox = await Hive.openBox<RecurringTransaction>('recurring_transactions');
      _isInitialized = true;
      debugPrint('DatabaseService: Initialized successfully');
    } catch (e, stackTrace) {
      debugPrint('DatabaseService: Init failed - $e');
      debugPrint('$stackTrace');
      rethrow;
    }
  }

  // ========== Hidden Categories (for system categories) ==========
  
  Set<String> getHiddenCategoryIds() {
    final profile = getUserProfile();
    // Store hidden category IDs in profile's hiddenCategories field
    return profile.hiddenCategories?.toSet() ?? {};
  }
  
  Future<void> hideCategory(String categoryId) async {
    final profile = getUserProfile();
    final hidden = profile.hiddenCategories?.toList() ?? [];
    if (!hidden.contains(categoryId)) {
      hidden.add(categoryId);
      profile.hiddenCategories = hidden;
      await updateUserProfile(profile);
    }
  }
  
  Future<void> unhideCategory(String categoryId) async {
    final profile = getUserProfile();
    final hidden = profile.hiddenCategories?.toList() ?? [];
    hidden.remove(categoryId);
    profile.hiddenCategories = hidden;
    await updateUserProfile(profile);
  }
  
  bool isCategoryHidden(String categoryId) {
    return getHiddenCategoryIds().contains(categoryId);
  }

  void _invalidateCache() {
    _cachedTransactions = null;
  }

  // ========== Transaction CRUD ==========
  
  Future<void> addTransaction(TransactionModel transaction) async {
    await _transactionBox.put(transaction.id, transaction);
    _invalidateCache();
  }

  List<TransactionModel> getAllTransactions() {
    if (_cachedTransactions != null) return _cachedTransactions!;
    _cachedTransactions = _transactionBox.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return _cachedTransactions!;
  }

  TransactionModel? getTransaction(String id) {
    return _transactionBox.get(id);
  }

  List<TransactionModel> getTransactionsByDateRange(DateTime start, DateTime end) {
    return getAllTransactions().where((t) {
      return t.date.isAfter(start.subtract(const Duration(days: 1))) &&
             t.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  List<TransactionModel> getTransactionsByType(bool isExpense) {
    return getAllTransactions().where((t) => t.isExpense == isExpense).toList();
  }

  List<TransactionModel> getRecentTransactions({int limit = 5}) {
    final all = getAllTransactions();
    return all.take(limit).toList();
  }

  List<TransactionModel> getTodayTransactions() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return getAllTransactions().where((t) {
      final transactionDate = DateTime(t.date.year, t.date.month, t.date.day);
      return transactionDate.isAtSameMomentAs(today);
    }).toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    await _transactionBox.put(transaction.id, transaction);
    _invalidateCache();
  }

  Future<void> deleteTransaction(String id) async {
    await _transactionBox.delete(id);
    _invalidateCache();
  }

  // ========== Custom Category CRUD ==========

  Future<void> addCustomCategory(CustomCategory category) async {
    await _customCategoryBox.put(category.id, category);
  }

  List<CustomCategory> getAllCustomCategories() {
    return _customCategoryBox.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<CustomCategory> getCustomCategoriesByType(bool isExpense) {
    return getAllCustomCategories()
        .where((c) => c.isExpense == isExpense)
        .toList();
  }

  CustomCategory? getCustomCategory(String id) {
    return _customCategoryBox.get(id);
  }

  Future<void> updateCustomCategory(CustomCategory category) async {
    await _customCategoryBox.put(category.id, category);
  }

  Future<void> deleteCustomCategory(String id) async {
    await _customCategoryBox.delete(id);
  }

  // ========== User Profile ==========

  UserProfile getUserProfile() {
    final profile = _userProfileBox.get('profile');
    if (profile != null) {
      return profile;
    }
    // Create default profile if not exists
    final defaultProfile = UserProfile.defaultProfile();
    _userProfileBox.put('profile', defaultProfile);
    return defaultProfile;
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    await _userProfileBox.put('profile', profile);
  }

  // ========== Statistics ==========

  double getTotalIncome() {
    final incomes = getTransactionsByType(false);
    return incomes.fold(0.0, (sum, t) => sum + t.amount);
  }

  double getTotalExpense() {
    final expenses = getTransactionsByType(true);
    return expenses.fold(0.0, (sum, t) => sum + t.amount);
  }

  double getBalance() {
    return getTotalIncome() - getTotalExpense();
  }

  double getIncomeByDateRange(DateTime start, DateTime end) {
    final transactions = getTransactionsByDateRange(start, end);
    return transactions
        .where((t) => !t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double getExpenseByDateRange(DateTime start, DateTime end) {
    final transactions = getTransactionsByDateRange(start, end);
    return transactions
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  Map<int, double> getDailyExpenses(DateTime start, DateTime end) {
    final transactions = getTransactionsByDateRange(start, end)
        .where((t) => t.isExpense)
        .toList();
    
    Map<int, double> dailyExpenses = {};
    for (var t in transactions) {
      final day = t.date.day;
      dailyExpenses[day] = (dailyExpenses[day] ?? 0) + t.amount;
    }
    return dailyExpenses;
  }

  String generateId() => _uuid.v4();

  // ========== Budget ==========

  Budget? getCurrentMonthBudget() {
    final now = DateTime.now();
    final key = '${now.year}-${now.month}';
    return _budgetBox.get(key);
  }

  Budget? getBudget(int year, int month) {
    final key = '$year-$month';
    return _budgetBox.get(key);
  }

  Future<void> setBudget(double limit, {int? year, int? month}) async {
    final now = DateTime.now();
    final y = year ?? now.year;
    final m = month ?? now.month;
    final key = '$y-$m';
    
    final budget = Budget(
      monthlyLimit: limit,
      year: y,
      month: m,
      createdAt: DateTime.now(),
    );
    await _budgetBox.put(key, budget);
  }

  double getCurrentMonthExpense() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    return getExpenseByDateRange(startOfMonth, endOfMonth);
  }

  double getBudgetProgress() {
    final budget = getCurrentMonthBudget();
    if (budget == null || budget.monthlyLimit <= 0) return 0;
    final spent = getCurrentMonthExpense();
    return (spent / budget.monthlyLimit).clamp(0.0, 2.0);
  }

  double getRemainingBudget() {
    final budget = getCurrentMonthBudget();
    if (budget == null) return 0;
    return budget.monthlyLimit - getCurrentMonthExpense();
  }

  // ========== Recurring Transactions ==========

  List<RecurringTransaction> getAllRecurringTransactions() {
    return _recurringBox.values.toList();
  }

  List<RecurringTransaction> getActiveRecurringTransactions() {
    return _recurringBox.values.where((r) => r.isActive).toList();
  }

  Future<void> addRecurringTransaction(RecurringTransaction recurring) async {
    await _recurringBox.put(recurring.id, recurring);
  }

  Future<void> updateRecurringTransaction(RecurringTransaction recurring) async {
    await _recurringBox.put(recurring.id, recurring);
  }

  Future<void> deleteRecurringTransaction(String id) async {
    await _recurringBox.delete(id);
  }

  Future<void> toggleRecurringTransaction(String id, bool isActive) async {
    final recurring = _recurringBox.get(id);
    if (recurring != null) {
      recurring.isActive = isActive;
      await recurring.save();
    }
  }

  Future<int> processRecurringTransactions() async {
    int generated = 0;
    final activeRecurring = getActiveRecurringTransactions();
    
    for (var recurring in activeRecurring) {
      while (recurring.shouldGenerateToday() || 
             recurring.getNextDueDate().isBefore(DateTime.now())) {
        // Create transaction
        final transaction = TransactionModel(
          id: generateId(),
          amount: recurring.amount,
          categoryId: recurring.categoryId,
          note: '${recurring.name} (Auto)',
          date: recurring.getNextDueDate(),
          isExpense: recurring.isExpense,
          currency: recurring.currency,
        );
        await addTransaction(transaction);
        
        // Update last generated
        recurring.lastGenerated = recurring.getNextDueDate();
        await recurring.save();
        generated++;
        
        // Safety check
        if (generated > 100) break;
      }
    }
    return generated;
  }

  // ========== Category Budget CRUD ==========
  
  /// Get category budget for specific category and month
  CategoryBudget? getCategoryBudget(String categoryId, {int? year, int? month}) {
    final now = DateTime.now();
    final y = year ?? now.year;
    final m = month ?? now.month;
    final key = CategoryBudget.generateKey(categoryId, y, m);
    return _categoryBudgetBox.get(key);
  }

  /// Get current month category budget
  CategoryBudget? getCurrentMonthCategoryBudget(String categoryId) {
    return getCategoryBudget(categoryId);
  }

  /// Get all category budgets for current month
  List<CategoryBudget> getAllCategoryBudgetsForMonth({int? year, int? month}) {
    final now = DateTime.now();
    final y = year ?? now.year;
    final m = month ?? now.month;
    return _categoryBudgetBox.values
        .where((b) => b.year == y && b.month == m)
        .toList();
  }

  /// Set category budget
  Future<void> setCategoryBudget(String categoryId, double limit, {int? year, int? month}) async {
    final now = DateTime.now();
    final y = year ?? now.year;
    final m = month ?? now.month;
    final key = CategoryBudget.generateKey(categoryId, y, m);
    
    final existing = _categoryBudgetBox.get(key);
    if (existing != null) {
      existing.limit = limit;
      existing.updatedAt = DateTime.now();
      await existing.save();
    } else {
      final budget = CategoryBudget(
        id: key,
        categoryId: categoryId,
        limit: limit,
        year: y,
        month: m,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _categoryBudgetBox.put(key, budget);
    }
  }

  /// Delete category budget
  Future<void> deleteCategoryBudget(String categoryId, {int? year, int? month}) async {
    final now = DateTime.now();
    final y = year ?? now.year;
    final m = month ?? now.month;
    final key = CategoryBudget.generateKey(categoryId, y, m);
    await _categoryBudgetBox.delete(key);
  }

  /// Delete all category budgets for a specific category (all months)
  /// Used when a category is deleted/hidden to clean up related budgets
  Future<void> deleteAllCategoryBudgets(String categoryId) async {
    final budgetsToDelete = _categoryBudgetBox.values
        .where((b) => b.categoryId == categoryId)
        .toList();
    
    for (final budget in budgetsToDelete) {
      await _categoryBudgetBox.delete(budget.id);
    }
  }

  /// Get expense for specific category in current month
  double getCategoryExpenseForMonth(String categoryId, {int? year, int? month}) {
    final now = DateTime.now();
    final y = year ?? now.year;
    final m = month ?? now.month;
    
    return getAllTransactions()
        .where((t) => 
            t.isExpense && 
            t.categoryId == categoryId &&
            t.date.year == y && 
            t.date.month == m)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Get all categories with budgets and their spending for current month
  /// Filters out hidden categories
  List<Map<String, dynamic>> getCategoryBudgetSummary({int? year, int? month}) {
    final budgets = getAllCategoryBudgetsForMonth(year: year, month: month);
    final hiddenIds = getHiddenCategoryIds();
    
    return budgets
        .where((budget) => !hiddenIds.contains(budget.categoryId))
        .map((budget) {
          final spent = getCategoryExpenseForMonth(budget.categoryId, year: year, month: month);
          return {
            'budget': budget,
            'spent': spent,
            'remaining': budget.limit - spent,
            'progress': budget.limit > 0 ? spent / budget.limit : 0.0,
            'isOver': spent > budget.limit,
          };
        }).toList()..sort((a, b) => (b['progress'] as double).compareTo(a['progress'] as double));
  }
}
