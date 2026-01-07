// Basic app tests for YMmoney

import 'package:flutter_test/flutter_test.dart';

import 'package:ymmoney/models/transaction.dart';
import 'package:ymmoney/models/user_profile.dart';
import 'package:ymmoney/models/budget.dart';

void main() {
  group('Model Tests', () {
    test('TransactionModel should create with required fields', () {
      final tx = TransactionModel(
        id: 'test_id',
        amount: 100.0,
        categoryId: 'food',
        date: DateTime(2024, 1, 15),
        isExpense: true,
      );

      expect(tx.id, 'test_id');
      expect(tx.amount, 100.0);
      expect(tx.categoryId, 'food');
      expect(tx.isExpense, true);
      expect(tx.currency, '฿'); // default value
    });

    test('TransactionModel copyWith should work correctly', () {
      final tx = TransactionModel(
        id: 'test_id',
        amount: 100.0,
        categoryId: 'food',
        date: DateTime(2024, 1, 15),
        isExpense: true,
      );

      final updated = tx.copyWith(amount: 200.0, note: 'Updated');

      expect(updated.id, 'test_id'); // unchanged
      expect(updated.amount, 200.0); // changed
      expect(updated.note, 'Updated'); // changed
      expect(updated.isExpense, true); // unchanged
    });

    test('UserProfile.defaultProfile should create with defaults', () {
      final profile = UserProfile.defaultProfile();

      expect(profile.name, 'User');
      expect(profile.currency, '฿');
      expect(profile.isDarkMode, false);
      expect(profile.languageCode, 'en');
      expect(profile.hiddenCategories, isEmpty);
    });

    test('Budget.forCurrentMonth should create for current month', () {
      final budget = Budget.forCurrentMonth(limit: 10000.0);
      final now = DateTime.now();

      expect(budget.monthlyLimit, 10000.0);
      expect(budget.year, now.year);
      expect(budget.month, now.month);
    });
  });
}
