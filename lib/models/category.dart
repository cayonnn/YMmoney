import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/custom_category.dart';
import '../services/database_service.dart';
import '../l10n/app_strings.dart';
import '../utils/icon_helper.dart'; // Added helper

enum TransactionType { income, expense }

class CategoryModel {
  final String id;
  final String name;
  final String nameEn;
  final IconData icon;
  final Color color;
  final TransactionType type;
  final bool isCustom;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.icon,
    required this.color,
    required this.type,
    this.isCustom = false,
  });

  /// Get translated category name based on current language
  String get displayName {
    if (isCustom) return name; // Custom categories use user-defined name
    return AppStrings.getCategoryName(id);
  }

  // Convert CustomCategory to CategoryModel
  factory CategoryModel.fromCustom(CustomCategory custom) {
    return CategoryModel(
      id: custom.id,
      name: custom.name,
      nameEn: custom.name,
      icon: IconHelper.getIconFromCodePoint(custom.iconCodePoint), // Use helper
      color: Color(custom.colorValue),
      type: custom.isExpense ? TransactionType.expense : TransactionType.income,
      isCustom: true,
    );
  }

  static List<CategoryModel> get defaultExpenseCategories => [
    CategoryModel(
      id: 'food',
      name: 'อาหาร',
      nameEn: 'Food',
      icon: Icons.restaurant,
      color: AppTheme.foodColor,
      type: TransactionType.expense,
    ),
    CategoryModel(
      id: 'shopping',
      name: 'ช้อปปิ้ง',
      nameEn: 'Shopping',
      icon: Icons.shopping_bag,
      color: AppTheme.shoppingColor,
      type: TransactionType.expense,
    ),
    CategoryModel(
      id: 'entertainment',
      name: 'บันเทิง',
      nameEn: 'Entertainment',
      icon: Icons.movie,
      color: AppTheme.entertainmentColor,
      type: TransactionType.expense,
    ),
    CategoryModel(
      id: 'travel',
      name: 'เดินทาง',
      nameEn: 'Travel',
      icon: Icons.flight,
      color: AppTheme.travelColor,
      type: TransactionType.expense,
    ),
    CategoryModel(
      id: 'home',
      name: 'ค่าบ้าน',
      nameEn: 'Home Rent',
      icon: Icons.home,
      color: AppTheme.homeColor,
      type: TransactionType.expense,
    ),
    CategoryModel(
      id: 'pet',
      name: 'สัตว์เลี้ยง',
      nameEn: 'Pet',
      icon: Icons.pets,
      color: AppTheme.petColor,
      type: TransactionType.expense,
    ),
    CategoryModel(
      id: 'recharge',
      name: 'เติมเงิน',
      nameEn: 'Recharge',
      icon: Icons.phone_android,
      color: AppTheme.rechargeColor,
      type: TransactionType.expense,
    ),
    CategoryModel(
      id: 'other_expense',
      name: 'อื่นๆ',
      nameEn: 'Other',
      icon: Icons.more_horiz,
      color: Colors.grey,
      type: TransactionType.expense,
    ),
  ];

  static List<CategoryModel> get defaultIncomeCategories => [
    CategoryModel(
      id: 'salary',
      name: 'เงินเดือน',
      nameEn: 'Salary',
      icon: Icons.work,
      color: AppTheme.incomeColor,
      type: TransactionType.income,
    ),
    CategoryModel(
      id: 'bonus',
      name: 'โบนัส',
      nameEn: 'Bonus',
      icon: Icons.card_giftcard,
      color: const Color(0xFF9B59B6),
      type: TransactionType.income,
    ),
    CategoryModel(
      id: 'investment',
      name: 'การลงทุน',
      nameEn: 'Investment',
      icon: Icons.trending_up,
      color: const Color(0xFF3498DB),
      type: TransactionType.income,
    ),
    CategoryModel(
      id: 'freelance',
      name: 'ฟรีแลนซ์',
      nameEn: 'Freelance',
      icon: Icons.laptop,
      color: const Color(0xFFE67E22),
      type: TransactionType.income,
    ),
    CategoryModel(
      id: 'other_income',
      name: 'อื่นๆ',
      nameEn: 'Other',
      icon: Icons.more_horiz,
      color: Colors.grey,
      type: TransactionType.income,
    ),
  ];

  // Get expense categories including custom ones, filtering hidden and applying overrides
  static List<CategoryModel> get expenseCategories {
    final db = DatabaseService();
    final hiddenIds = db.getHiddenCategoryIds();
    final customCategories = db.getCustomCategoriesByType(true);
    
    // Create map of custom categories by ID for quick lookup (overrides)
    final customMap = {for (var c in customCategories) c.id: c};
    
    // Process default categories - apply overrides and filter hidden
    final processedDefault = defaultExpenseCategories
        .where((cat) => !hiddenIds.contains(cat.id))
        .map((cat) {
          // Check if there's a custom override for this system category
          if (customMap.containsKey(cat.id)) {
            return CategoryModel.fromCustom(customMap[cat.id]!);
          }
          return cat;
        })
        .toList();
    
    // Get truly custom categories (IDs not in default list)
    final defaultIds = defaultExpenseCategories.map((c) => c.id).toSet();
    final trulyCustom = customCategories
        .where((c) => !defaultIds.contains(c.id) && !hiddenIds.contains(c.id))
        .map((c) => CategoryModel.fromCustom(c))
        .toList();
    
    return [...processedDefault, ...trulyCustom];
  }

  // Get income categories including custom ones, filtering hidden and applying overrides
  static List<CategoryModel> get incomeCategories {
    final db = DatabaseService();
    final hiddenIds = db.getHiddenCategoryIds();
    final customCategories = db.getCustomCategoriesByType(false);
    
    // Create map of custom categories by ID for quick lookup (overrides)
    final customMap = {for (var c in customCategories) c.id: c};
    
    // Process default categories - apply overrides and filter hidden
    final processedDefault = defaultIncomeCategories
        .where((cat) => !hiddenIds.contains(cat.id))
        .map((cat) {
          // Check if there's a custom override for this system category
          if (customMap.containsKey(cat.id)) {
            return CategoryModel.fromCustom(customMap[cat.id]!);
          }
          return cat;
        })
        .toList();
    
    // Get truly custom categories (IDs not in default list)
    final defaultIds = defaultIncomeCategories.map((c) => c.id).toSet();
    final trulyCustom = customCategories
        .where((c) => !defaultIds.contains(c.id) && !hiddenIds.contains(c.id))
        .map((c) => CategoryModel.fromCustom(c))
        .toList();
    
    return [...processedDefault, ...trulyCustom];
  }

  static List<CategoryModel> get allCategories => [
    ...expenseCategories,
    ...incomeCategories,
  ];

  static CategoryModel? getById(String id) {
    try {
      return allCategories.firstWhere((cat) => cat.id == id);
    } catch (e) {
      // Check custom categories
      final db = DatabaseService();
      final custom = db.getCustomCategory(id);
      if (custom != null) {
        return CategoryModel.fromCustom(custom);
      }
      return null;
    }
  }
}
