import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive_test/hive_test.dart';

import 'package:ymmoney/models/transaction.dart';
import 'package:ymmoney/models/custom_category.dart';
import 'package:ymmoney/models/user_profile.dart';
import 'package:ymmoney/models/budget.dart';
import 'package:ymmoney/models/category_budget.dart';
import 'package:ymmoney/models/recurring_transaction.dart';

import '../helpers/test_helpers.dart';

/// Unit tests for DatabaseService
/// 
/// Note: These tests use in-memory Hive boxes for testing.
/// Real DatabaseService uses singleton pattern, so we test
/// the logic patterns rather than the actual service.

void main() {
  late Box<TransactionModel> transactionBox;
  late Box<CustomCategory> customCategoryBox;
  late Box<UserProfile> userProfileBox;
  late Box<Budget> budgetBox;
  late Box<CategoryBudget> categoryBudgetBox;
  late Box<RecurringTransaction> recurringBox;

  setUpAll(() async {
    await setUpTestHive();
    
    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TransactionModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(CustomCategoryAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(UserProfileAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(BudgetAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(RecurringTransactionAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(CategoryBudgetAdapter());
    }
  });

  setUp(() async {
    transactionBox = await Hive.openBox<TransactionModel>('test_transactions');
    customCategoryBox = await Hive.openBox<CustomCategory>('test_categories');
    userProfileBox = await Hive.openBox<UserProfile>('test_profile');
    budgetBox = await Hive.openBox<Budget>('test_budgets');
    categoryBudgetBox = await Hive.openBox<CategoryBudget>('test_category_budgets');
    recurringBox = await Hive.openBox<RecurringTransaction>('test_recurring');
  });

  tearDown(() async {
    await transactionBox.clear();
    await customCategoryBox.clear();
    await userProfileBox.clear();
    await budgetBox.clear();
    await categoryBudgetBox.clear();
    await recurringBox.clear();
  });

  tearDownAll(() async {
    await tearDownTestHive();
  });

  group('Transaction CRUD', () {
    test('should add and retrieve transaction', () async {
      final tx = TestHelpers.createExpenseTransaction(
        id: 'tx_001',
        amount: 150.0,
        categoryId: 'food',
      );

      await transactionBox.put(tx.id, tx);
      final retrieved = transactionBox.get('tx_001');

      expect(retrieved, isNotNull);
      expect(retrieved!.amount, 150.0);
      expect(retrieved.categoryId, 'food');
      expect(retrieved.isExpense, true);
    });

    test('should update transaction', () async {
      final tx = TestHelpers.createExpenseTransaction(
        id: 'tx_002',
        amount: 100.0,
      );
      await transactionBox.put(tx.id, tx);

      // Update amount
      final updated = tx.copyWith(amount: 200.0);
      await transactionBox.put(tx.id, updated);

      final retrieved = transactionBox.get('tx_002');
      expect(retrieved!.amount, 200.0);
    });

    test('should delete transaction', () async {
      final tx = TestHelpers.createExpenseTransaction(id: 'tx_003');
      await transactionBox.put(tx.id, tx);
      
      await transactionBox.delete('tx_003');
      
      expect(transactionBox.get('tx_003'), isNull);
    });

    test('should get transactions by type', () async {
      // Add mixed transactions
      await transactionBox.put('exp1', TestHelpers.createExpenseTransaction(id: 'exp1'));
      await transactionBox.put('exp2', TestHelpers.createExpenseTransaction(id: 'exp2'));
      await transactionBox.put('inc1', TestHelpers.createIncomeTransaction(id: 'inc1'));

      final expenses = transactionBox.values.where((t) => t.isExpense).toList();
      final incomes = transactionBox.values.where((t) => !t.isExpense).toList();

      expect(expenses.length, 2);
      expect(incomes.length, 1);
    });

    test('should get transactions by date range', () async {
      final jan15 = DateTime(2024, 1, 15);
      final jan20 = DateTime(2024, 1, 20);
      final jan25 = DateTime(2024, 1, 25);
      final startRange = DateTime(2024, 1, 18);
      final endRange = DateTime(2024, 1, 26);

      await transactionBox.put('t1', TestHelpers.createExpenseTransaction(id: 't1', date: jan15));
      await transactionBox.put('t2', TestHelpers.createExpenseTransaction(id: 't2', date: jan20));
      await transactionBox.put('t3', TestHelpers.createExpenseTransaction(id: 't3', date: jan25));

      final inRange = transactionBox.values.where((t) {
        return t.date.isAfter(startRange.subtract(const Duration(days: 1))) &&
               t.date.isBefore(endRange.add(const Duration(days: 1)));
      }).toList();

      expect(inRange.length, 2); // jan20 and jan25
    });
  });

  group('Custom Category CRUD', () {
    test('should add and retrieve custom category', () async {
      final category = TestHelpers.createCustomCategory(
        id: 'cat_001',
        name: 'Groceries',
        isExpense: true,
      );

      await customCategoryBox.put(category.id, category);
      final retrieved = customCategoryBox.get('cat_001');

      expect(retrieved, isNotNull);
      expect(retrieved!.name, 'Groceries');
      expect(retrieved.isExpense, true);
    });

    test('should filter categories by type', () async {
      await customCategoryBox.put('c1', TestHelpers.createCustomCategory(id: 'c1', isExpense: true));
      await customCategoryBox.put('c2', TestHelpers.createCustomCategory(id: 'c2', isExpense: true));
      await customCategoryBox.put('c3', TestHelpers.createCustomCategory(id: 'c3', isExpense: false));

      final expenseCategories = customCategoryBox.values.where((c) => c.isExpense).toList();
      final incomeCategories = customCategoryBox.values.where((c) => !c.isExpense).toList();

      expect(expenseCategories.length, 2);
      expect(incomeCategories.length, 1);
    });
  });

  group('User Profile', () {
    test('should create default profile', () async {
      final profile = UserProfile.defaultProfile();

      expect(profile.name, 'User');
      expect(profile.currency, '฿');
      expect(profile.isDarkMode, false);
      expect(profile.languageCode, 'en');
    });

    test('should update user profile', () async {
      final profile = TestHelpers.createUserProfile(name: 'John');
      await userProfileBox.put('profile', profile);

      profile.name = 'Jane';
      profile.currency = '\$';
      await userProfileBox.put('profile', profile);

      final retrieved = userProfileBox.get('profile');
      expect(retrieved!.name, 'Jane');
      expect(retrieved.currency, '\$');
    });

    test('should manage hidden categories', () async {
      final profile = TestHelpers.createUserProfile(
        hiddenCategories: ['cat1', 'cat2'],
      );

      expect(profile.hiddenCategories!.contains('cat1'), true);
      expect(profile.hiddenCategories!.contains('cat3'), false);

      // Add hidden category
      profile.hiddenCategories!.add('cat3');
      expect(profile.hiddenCategories!.contains('cat3'), true);

      // Remove hidden category  
      profile.hiddenCategories!.remove('cat1');
      expect(profile.hiddenCategories!.contains('cat1'), false);
    });
  });

  group('Budget Operations', () {
    test('should create and retrieve budget', () async {
      final budget = TestHelpers.createBudget(
        monthlyLimit: 15000.0,
        year: 2024,
        month: 6,
      );

      await budgetBox.put('2024-6', budget);
      final retrieved = budgetBox.get('2024-6');

      expect(retrieved, isNotNull);
      expect(retrieved!.monthlyLimit, 15000.0);
      expect(retrieved.year, 2024);
      expect(retrieved.month, 6);
    });

    test('should calculate budget progress', () async {
      const budgetLimit = 10000.0;
      const spent = 7500.0;
      
      final progress = spent / budgetLimit;
      final remaining = budgetLimit - spent;

      expect(progress, 0.75);
      expect(remaining, 2500.0);
    });

    test('should detect over budget', () async {
      const budgetLimit = 10000.0;
      const spent = 12000.0;
      
      final isOver = spent > budgetLimit;
      final overAmount = spent - budgetLimit;

      expect(isOver, true);
      expect(overAmount, 2000.0);
    });
  });

  group('Category Budget', () {
    test('should create category budget with correct key', () async {
      final catBudget = TestHelpers.createCategoryBudget(
        categoryId: 'food',
        limit: 3000.0,
        year: 2024,
        month: 7,
      );

      final expectedKey = 'food_2024_7';
      expect(catBudget.id, expectedKey);
      
      await categoryBudgetBox.put(catBudget.id, catBudget);
      final retrieved = categoryBudgetBox.get('food_2024_7');
      
      expect(retrieved, isNotNull);
      expect(retrieved!.limit, 3000.0);
    });

    test('should get all category budgets for month', () async {
      await categoryBudgetBox.put('food_2024_7', TestHelpers.createCategoryBudget(
        categoryId: 'food', year: 2024, month: 7));
      await categoryBudgetBox.put('transport_2024_7', TestHelpers.createCategoryBudget(
        categoryId: 'transport', year: 2024, month: 7));
      await categoryBudgetBox.put('food_2024_8', TestHelpers.createCategoryBudget(
        categoryId: 'food', year: 2024, month: 8));

      final july2024 = categoryBudgetBox.values.where((b) => b.year == 2024 && b.month == 7).toList();

      expect(july2024.length, 2);
    });
  });

  group('Recurring Transactions', () {
    test('should create recurring transaction', () async {
      final recurring = TestHelpers.createRecurringTransaction(
        id: 'rec_001',
        name: 'Monthly Rent',
        amount: 8000.0,
        frequencyIndex: 2, // monthly
      );

      await recurringBox.put(recurring.id, recurring);
      final retrieved = recurringBox.get('rec_001');

      expect(retrieved, isNotNull);
      expect(retrieved!.name, 'Monthly Rent');
      expect(retrieved.amount, 8000.0);
      expect(retrieved.frequencyIndex, 2);
    });

    test('should filter active recurring transactions', () async {
      await recurringBox.put('r1', TestHelpers.createRecurringTransaction(id: 'r1', isActive: true));
      await recurringBox.put('r2', TestHelpers.createRecurringTransaction(id: 'r2', isActive: false));
      await recurringBox.put('r3', TestHelpers.createRecurringTransaction(id: 'r3', isActive: true));

      final active = recurringBox.values.where((r) => r.isActive).toList();

      expect(active.length, 2);
    });

    test('should calculate next due date for monthly', () {
      final lastMonth = DateTime.now().subtract(const Duration(days: 35));
      final recurring = TestHelpers.createRecurringTransaction(
        frequencyIndex: 2, // monthly
        lastGenerated: lastMonth,
      );

      final nextDue = recurring.getNextDueDate();
      
      // Next due should be after last generated
      expect(nextDue.isAfter(lastMonth), true);
    });
  });

  group('Statistics', () {
    test('should calculate total income', () async {
      await transactionBox.put('i1', TestHelpers.createIncomeTransaction(id: 'i1', amount: 5000.0));
      await transactionBox.put('i2', TestHelpers.createIncomeTransaction(id: 'i2', amount: 3000.0));
      await transactionBox.put('e1', TestHelpers.createExpenseTransaction(id: 'e1', amount: 1000.0));

      final totalIncome = transactionBox.values
          .where((t) => !t.isExpense)
          .fold(0.0, (sum, t) => sum + t.amount);

      expect(totalIncome, 8000.0);
    });

    test('should calculate total expense', () async {
      await transactionBox.put('e1', TestHelpers.createExpenseTransaction(id: 'e1', amount: 500.0));
      await transactionBox.put('e2', TestHelpers.createExpenseTransaction(id: 'e2', amount: 1500.0));
      await transactionBox.put('i1', TestHelpers.createIncomeTransaction(id: 'i1', amount: 5000.0));

      final totalExpense = transactionBox.values
          .where((t) => t.isExpense)
          .fold(0.0, (sum, t) => sum + t.amount);

      expect(totalExpense, 2000.0);
    });

    test('should calculate balance', () async {
      await transactionBox.put('i1', TestHelpers.createIncomeTransaction(id: 'i1', amount: 10000.0));
      await transactionBox.put('e1', TestHelpers.createExpenseTransaction(id: 'e1', amount: 3000.0));
      await transactionBox.put('e2', TestHelpers.createExpenseTransaction(id: 'e2', amount: 2000.0));

      final income = transactionBox.values
          .where((t) => !t.isExpense)
          .fold(0.0, (sum, t) => sum + t.amount);
      final expense = transactionBox.values
          .where((t) => t.isExpense)
          .fold(0.0, (sum, t) => sum + t.amount);
      final balance = income - expense;

      expect(balance, 5000.0);
    });

    test('should calculate expense by category', () async {
      await transactionBox.put('e1', TestHelpers.createExpenseTransaction(id: 'e1', amount: 100.0, categoryId: 'food'));
      await transactionBox.put('e2', TestHelpers.createExpenseTransaction(id: 'e2', amount: 200.0, categoryId: 'food'));
      await transactionBox.put('e3', TestHelpers.createExpenseTransaction(id: 'e3', amount: 50.0, categoryId: 'transport'));

      final foodExpense = transactionBox.values
          .where((t) => t.isExpense && t.categoryId == 'food')
          .fold(0.0, (sum, t) => sum + t.amount);

      expect(foodExpense, 300.0);
    });
  });
}
