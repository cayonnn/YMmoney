import 'package:hive/hive.dart';

part 'budget.g.dart';

@HiveType(typeId: 3)
class Budget extends HiveObject {
  @HiveField(0)
  double monthlyLimit;

  @HiveField(1)
  int year;

  @HiveField(2)
  int month;

  @HiveField(3)
  DateTime createdAt;

  Budget({
    required this.monthlyLimit,
    required this.year,
    required this.month,
    required this.createdAt,
  });

  // Get unique key for the budget (year-month)
  @override
  String get key => '$year-$month';

  // Factory to create budget for current month
  factory Budget.forCurrentMonth({double limit = 0}) {
    final now = DateTime.now();
    return Budget(
      monthlyLimit: limit,
      year: now.year,
      month: now.month,
      createdAt: DateTime.now(),
    );
  }
}
