import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'database_service.dart';
import '../models/transaction.dart';
import '../models/custom_category.dart';
import '../models/user_profile.dart';
import '../models/budget.dart';
import '../models/category_budget.dart';
import '../models/recurring_transaction.dart';

/// Service for backing up and restoring app data
class DataBackupService {
  final DatabaseService _db = DatabaseService();

  /// Export all app data to JSON string
  Future<String> exportToJson() async {
    try {
      final data = {
        'version': '1.0',
        'exportDate': DateTime.now().toIso8601String(),
        'transactions': _exportTransactions(),
        'customCategories': _exportCustomCategories(),
        'userProfile': _exportUserProfile(),
        'budgets': _exportBudgets(),
        'categoryBudgets': _exportCategoryBudgets(),
        'recurringTransactions': _exportRecurringTransactions(),
      };
      
      return jsonEncode(data);
    } catch (e) {
      debugPrint('Export error: $e');
      rethrow;
    }
  }

  /// Import data from JSON string
  Future<ImportResult> importFromJson(String jsonString) async {
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      
      // Validate version
      final version = data['version'] as String?;
      if (version == null) {
        return ImportResult(
          success: false, 
          message: 'Invalid backup file format',
        );
      }

      int transactionsImported = 0;
      int categoriesImported = 0;
      int budgetsImported = 0;
      int recurringImported = 0;

      // Import transactions
      if (data['transactions'] != null) {
        final transactions = data['transactions'] as List;
        for (var item in transactions) {
          final tx = _parseTransaction(item);
          if (tx != null) {
            await _db.addTransaction(tx);
            transactionsImported++;
          }
        }
      }

      // Import custom categories
      if (data['customCategories'] != null) {
        final categories = data['customCategories'] as List;
        for (var item in categories) {
          final cat = _parseCustomCategory(item);
          if (cat != null) {
            await _db.addCustomCategory(cat);
            categoriesImported++;
          }
        }
      }

      // Import user profile
      if (data['userProfile'] != null) {
        final profile = _parseUserProfile(data['userProfile']);
        if (profile != null) {
          await _db.updateUserProfile(profile);
        }
      }

      // Import budgets
      if (data['budgets'] != null) {
        final budgets = data['budgets'] as List;
        for (var item in budgets) {
          final budget = _parseBudget(item);
          if (budget != null) {
            await _db.setBudget(budget.monthlyLimit, year: budget.year, month: budget.month);
            budgetsImported++;
          }
        }
      }

      // Import category budgets
      if (data['categoryBudgets'] != null) {
        final catBudgets = data['categoryBudgets'] as List;
        for (var item in catBudgets) {
          final catBudget = _parseCategoryBudget(item);
          if (catBudget != null) {
            await _db.setCategoryBudget(
              catBudget.categoryId, 
              catBudget.limit,
              year: catBudget.year,
              month: catBudget.month,
            );
            budgetsImported++;
          }
        }
      }

      // Import recurring transactions
      if (data['recurringTransactions'] != null) {
        final recurring = data['recurringTransactions'] as List;
        for (var item in recurring) {
          final rec = _parseRecurringTransaction(item);
          if (rec != null) {
            await _db.addRecurringTransaction(rec);
            recurringImported++;
          }
        }
      }

      return ImportResult(
        success: true,
        message: 'Import successful',
        transactionsImported: transactionsImported,
        categoriesImported: categoriesImported,
        budgetsImported: budgetsImported,
        recurringImported: recurringImported,
      );
    } catch (e) {
      debugPrint('Import error: $e');
      return ImportResult(
        success: false,
        message: 'Import failed: ${e.toString()}',
      );
    }
  }

  /// Get backup summary info
  Map<String, dynamic> getBackupInfo() {
    return {
      'transactions': _db.getAllTransactions().length,
      'customCategories': _db.getAllCustomCategories().length,
      'recurringTransactions': _db.getAllRecurringTransactions().length,
      'budgets': _db.getAllCategoryBudgetsForMonth().length,
    };
  }

  // ========== Export helpers ==========

  List<Map<String, dynamic>> _exportTransactions() {
    return _db.getAllTransactions().map((t) => {
      'id': t.id,
      'amount': t.amount,
      'categoryId': t.categoryId,
      'note': t.note,
      'date': t.date.toIso8601String(),
      'isExpense': t.isExpense,
      'currency': t.currency,
    }).toList();
  }

  List<Map<String, dynamic>> _exportCustomCategories() {
    return _db.getAllCustomCategories().map((c) => {
      'id': c.id,
      'name': c.name,
      'iconCodePoint': c.iconCodePoint,
      'colorValue': c.colorValue,
      'isExpense': c.isExpense,
      'createdAt': c.createdAt.toIso8601String(),
    }).toList();
  }

  Map<String, dynamic> _exportUserProfile() {
    final p = _db.getUserProfile();
    return {
      'name': p.name,
      'currency': p.currency,
      'avatarColorValue': p.avatarColorValue,
      'isDarkMode': p.isDarkMode,
      'languageCode': p.languageCode,
      'hiddenCategories': p.hiddenCategories,
    };
  }

  List<Map<String, dynamic>> _exportBudgets() {
    // Export budgets would need iteration over all stored budgets
    final current = _db.getCurrentMonthBudget();
    if (current == null) return [];
    return [{
      'monthlyLimit': current.monthlyLimit,
      'year': current.year,
      'month': current.month,
    }];
  }

  List<Map<String, dynamic>> _exportCategoryBudgets() {
    return _db.getAllCategoryBudgetsForMonth().map((b) => {
      'id': b.id,
      'categoryId': b.categoryId,
      'limit': b.limit,
      'year': b.year,
      'month': b.month,
    }).toList();
  }

  List<Map<String, dynamic>> _exportRecurringTransactions() {
    return _db.getAllRecurringTransactions().map((r) => {
      'id': r.id,
      'name': r.name,
      'amount': r.amount,
      'categoryId': r.categoryId,
      'note': r.note,
      'isExpense': r.isExpense,
      'currency': r.currency,
      'frequencyIndex': r.frequencyIndex,
      'startDate': r.startDate.toIso8601String(),
      'endDate': r.endDate?.toIso8601String(),
      'lastGenerated': r.lastGenerated.toIso8601String(),
      'isActive': r.isActive,
      'createdAt': r.createdAt.toIso8601String(),
    }).toList();
  }

  // ========== Import helpers ==========

  TransactionModel? _parseTransaction(Map<String, dynamic> data) {
    try {
      return TransactionModel(
        id: data['id'] as String,
        amount: (data['amount'] as num).toDouble(),
        categoryId: data['categoryId'] as String,
        note: data['note'] as String? ?? '',
        date: DateTime.parse(data['date'] as String),
        isExpense: data['isExpense'] as bool,
        currency: data['currency'] as String? ?? '฿',
      );
    } catch (e) {
      debugPrint('Parse transaction error: $e');
      return null;
    }
  }

  CustomCategory? _parseCustomCategory(Map<String, dynamic> data) {
    try {
      return CustomCategory(
        id: data['id'] as String,
        name: data['name'] as String,
        iconCodePoint: data['iconCodePoint'] as int,
        colorValue: data['colorValue'] as int,
        isExpense: data['isExpense'] as bool,
        createdAt: DateTime.parse(data['createdAt'] as String),
      );
    } catch (e) {
      debugPrint('Parse category error: $e');
      return null;
    }
  }

  UserProfile? _parseUserProfile(Map<String, dynamic> data) {
    try {
      return UserProfile(
        name: data['name'] as String? ?? 'User',
        currency: data['currency'] as String? ?? '฿',
        avatarColorValue: data['avatarColorValue'] as int? ?? 0xFFFF9A9E,
        createdAt: DateTime.now(),
        isDarkMode: data['isDarkMode'] as bool? ?? false,
        languageCode: data['languageCode'] as String? ?? 'en',
        hiddenCategories: (data['hiddenCategories'] as List?)?.cast<String>(),
      );
    } catch (e) {
      debugPrint('Parse profile error: $e');
      return null;
    }
  }

  Budget? _parseBudget(Map<String, dynamic> data) {
    try {
      return Budget(
        monthlyLimit: (data['monthlyLimit'] as num).toDouble(),
        year: data['year'] as int,
        month: data['month'] as int,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Parse budget error: $e');
      return null;
    }
  }

  CategoryBudget? _parseCategoryBudget(Map<String, dynamic> data) {
    try {
      return CategoryBudget(
        id: data['id'] as String,
        categoryId: data['categoryId'] as String,
        limit: (data['limit'] as num).toDouble(),
        year: data['year'] as int,
        month: data['month'] as int,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Parse category budget error: $e');
      return null;
    }
  }

  RecurringTransaction? _parseRecurringTransaction(Map<String, dynamic> data) {
    try {
      return RecurringTransaction(
        id: data['id'] as String,
        name: data['name'] as String,
        amount: (data['amount'] as num).toDouble(),
        categoryId: data['categoryId'] as String,
        note: data['note'] as String? ?? '',
        isExpense: data['isExpense'] as bool,
        currency: data['currency'] as String? ?? '฿',
        frequencyIndex: data['frequencyIndex'] as int? ?? 2,
        startDate: DateTime.parse(data['startDate'] as String),
        endDate: data['endDate'] != null ? DateTime.parse(data['endDate'] as String) : null,
        lastGenerated: DateTime.parse(data['lastGenerated'] as String),
        isActive: data['isActive'] as bool? ?? true,
        createdAt: data['createdAt'] != null 
            ? DateTime.parse(data['createdAt'] as String) 
            : DateTime.now(),
      );
    } catch (e) {
      debugPrint('Parse recurring error: $e');
      return null;
    }
  }
}

/// Result of import operation
class ImportResult {
  final bool success;
  final String message;
  final int transactionsImported;
  final int categoriesImported;
  final int budgetsImported;
  final int recurringImported;

  ImportResult({
    required this.success,
    required this.message,
    this.transactionsImported = 0,
    this.categoriesImported = 0,
    this.budgetsImported = 0,
    this.recurringImported = 0,
  });

  int get totalImported => 
      transactionsImported + categoriesImported + budgetsImported + recurringImported;
}
