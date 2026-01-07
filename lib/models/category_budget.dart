import 'package:hive/hive.dart';

part 'category_budget.g.dart';

/// CategoryBudget model for storing per-category spending limits
/// 
/// This allows users to set individual budget limits for each category
/// to better track and control spending in specific areas.
@HiveType(typeId: 5)
class CategoryBudget extends HiveObject {
  /// Unique identifier (categoryId-year-month)
  @HiveField(0)
  String id;

  /// Category ID this budget belongs to
  @HiveField(1)
  String categoryId;

  /// Monthly spending limit for this category
  @HiveField(2)
  double limit;

  /// Year this budget applies to
  @HiveField(3)
  int year;

  /// Month this budget applies to (1-12)
  @HiveField(4)
  int month;

  /// When this budget was created
  @HiveField(5)
  DateTime createdAt;

  /// When this budget was last updated
  @HiveField(6)
  DateTime updatedAt;

  CategoryBudget({
    required this.id,
    required this.categoryId,
    required this.limit,
    required this.year,
    required this.month,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Generate unique key for this category budget
  static String generateKey(String categoryId, int year, int month) {
    return '$categoryId-$year-$month';
  }

  /// Factory to create a category budget for current month
  factory CategoryBudget.forCurrentMonth({
    required String categoryId,
    required double limit,
  }) {
    final now = DateTime.now();
    return CategoryBudget(
      id: generateKey(categoryId, now.year, now.month),
      categoryId: categoryId,
      limit: limit,
      year: now.year,
      month: now.month,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Check if this budget is over limit
  bool isOverLimit(double spent) => spent > limit;

  /// Get remaining budget
  double getRemaining(double spent) => limit - spent;

  /// Get progress as percentage (0.0 - 1.0+)
  double getProgress(double spent) => limit > 0 ? spent / limit : 0;

  /// Copy with updated values
  CategoryBudget copyWith({
    String? categoryId,
    double? limit,
    int? year,
    int? month,
  }) {
    return CategoryBudget(
      id: CategoryBudget.generateKey(
        categoryId ?? this.categoryId,
        year ?? this.year,
        month ?? this.month,
      ),
      categoryId: categoryId ?? this.categoryId,
      limit: limit ?? this.limit,
      year: year ?? this.year,
      month: month ?? this.month,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'CategoryBudget(categoryId: $categoryId, limit: $limit, year: $year, month: $month)';
  }
}
