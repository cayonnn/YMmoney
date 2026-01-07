import 'package:ymmoney/models/transaction.dart';
import 'package:ymmoney/models/custom_category.dart';
import 'package:ymmoney/models/user_profile.dart';
import 'package:ymmoney/models/budget.dart';
import 'package:ymmoney/models/category_budget.dart';
import 'package:ymmoney/models/recurring_transaction.dart';

/// Test helper class for creating mock data
class TestHelpers {
  /// Generate a sample expense transaction
  static TransactionModel createExpenseTransaction({
    String? id,
    double amount = 100.0,
    String categoryId = 'food',
    String note = 'Test expense',
    DateTime? date,
    String currency = '฿',
  }) {
    return TransactionModel(
      id: id ?? 'tx_${DateTime.now().millisecondsSinceEpoch}',
      amount: amount,
      categoryId: categoryId,
      note: note,
      date: date ?? DateTime.now(),
      isExpense: true,
      currency: currency,
    );
  }

  /// Generate a sample income transaction
  static TransactionModel createIncomeTransaction({
    String? id,
    double amount = 500.0,
    String categoryId = 'salary',
    String note = 'Test income',
    DateTime? date,
    String currency = '฿',
  }) {
    return TransactionModel(
      id: id ?? 'tx_${DateTime.now().millisecondsSinceEpoch}',
      amount: amount,
      categoryId: categoryId,
      note: note,
      date: date ?? DateTime.now(),
      isExpense: false,
      currency: currency,
    );
  }

  /// Generate a sample custom category
  static CustomCategory createCustomCategory({
    String? id,
    String name = 'Test Category',
    int iconCodePoint = 0xe318, // Icons.category
    int colorValue = 0xFFFF5722, // Orange
    bool isExpense = true,
    DateTime? createdAt,
  }) {
    return CustomCategory(
      id: id ?? 'cat_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      iconCodePoint: iconCodePoint,
      colorValue: colorValue,
      isExpense: isExpense,
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  /// Generate a sample user profile
  static UserProfile createUserProfile({
    String name = 'Test User',
    String currency = '฿',
    int avatarColorValue = 0xFFFF9A9E,
    bool isDarkMode = false,
    String languageCode = 'en',
    List<String>? hiddenCategories,
  }) {
    return UserProfile(
      name: name,
      currency: currency,
      avatarColorValue: avatarColorValue,
      createdAt: DateTime.now(),
      isDarkMode: isDarkMode,
      languageCode: languageCode,
      hiddenCategories: hiddenCategories ?? [],
    );
  }

  /// Generate a sample budget
  static Budget createBudget({
    double monthlyLimit = 10000.0,
    int? year,
    int? month,
  }) {
    final now = DateTime.now();
    return Budget(
      monthlyLimit: monthlyLimit,
      year: year ?? now.year,
      month: month ?? now.month,
      createdAt: DateTime.now(),
    );
  }

  /// Generate a sample category budget
  static CategoryBudget createCategoryBudget({
    String categoryId = 'food',
    double limit = 2000.0,
    int? year,
    int? month,
  }) {
    final now = DateTime.now();
    final y = year ?? now.year;
    final m = month ?? now.month;
    return CategoryBudget(
      id: '${categoryId}_${y}_$m',
      categoryId: categoryId,
      limit: limit,
      year: y,
      month: m,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Generate a sample recurring transaction
  static RecurringTransaction createRecurringTransaction({
    String? id,
    String name = 'Test Recurring',
    double amount = 500.0,
    String categoryId = 'bills',
    int frequencyIndex = 2, // 0=daily, 1=weekly, 2=monthly, 3=yearly
    bool isExpense = true,
    bool isActive = true,
    DateTime? startDate,
    DateTime? lastGenerated,
    String currency = '฿',
    String note = '',
  }) {
    final now = DateTime.now();
    return RecurringTransaction(
      id: id ?? 'rec_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      amount: amount,
      categoryId: categoryId,
      note: note,
      isExpense: isExpense,
      currency: currency,
      frequencyIndex: frequencyIndex,
      startDate: startDate ?? now,
      lastGenerated: lastGenerated ?? now.subtract(const Duration(days: 30)),
      isActive: isActive,
      createdAt: now,
    );
  }

  /// Create multiple sample expense transactions for a given month
  static List<TransactionModel> createMonthlyExpenses({
    required int year,
    required int month,
    int count = 5,
  }) {
    final transactions = <TransactionModel>[];
    final categories = ['food', 'transport', 'shopping', 'bills', 'entertainment'];
    
    for (int i = 0; i < count; i++) {
      transactions.add(TransactionModel(
        id: 'tx_$year$month$i',
        amount: (i + 1) * 100.0,
        categoryId: categories[i % categories.length],
        note: 'Monthly expense $i',
        date: DateTime(year, month, (i + 1).clamp(1, 28)),
        isExpense: true,
        currency: '฿',
      ));
    }
    return transactions;
  }

  /// Create multiple sample income transactions for a given month
  static List<TransactionModel> createMonthlyIncomes({
    required int year,
    required int month,
    int count = 2,
  }) {
    final transactions = <TransactionModel>[];
    final categories = ['salary', 'freelance'];
    
    for (int i = 0; i < count; i++) {
      transactions.add(TransactionModel(
        id: 'tx_income_$year$month$i',
        amount: (i + 1) * 5000.0,
        categoryId: categories[i % categories.length],
        note: 'Monthly income $i',
        date: DateTime(year, month, (i + 1).clamp(1, 28)),
        isExpense: false,
        currency: '฿',
      ));
    }
    return transactions;
  }
}
