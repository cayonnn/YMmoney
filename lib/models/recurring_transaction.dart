import 'package:hive/hive.dart';

part 'recurring_transaction.g.dart';

enum RecurrenceFrequency {
  daily,
  weekly,
  monthly,
  yearly,
}

@HiveType(typeId: 4)
class RecurringTransaction extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  double amount;

  @HiveField(2)
  String categoryId;

  @HiveField(3)
  String note;

  @HiveField(4)
  bool isExpense;

  @HiveField(5)
  String currency;

  @HiveField(6)
  int frequencyIndex; // 0=daily, 1=weekly, 2=monthly, 3=yearly

  @HiveField(7)
  DateTime startDate;

  @HiveField(8)
  DateTime? endDate; // null = no end

  @HiveField(9)
  DateTime lastGenerated;

  @HiveField(10)
  bool isActive;

  @HiveField(11)
  String name; // e.g. "Monthly Rent", "Electric Bill"

  @HiveField(12)
  DateTime createdAt;

  RecurringTransaction({
    required this.id,
    required this.amount,
    required this.categoryId,
    this.note = '',
    required this.isExpense,
    this.currency = '฿',
    this.frequencyIndex = 2, // default monthly
    required this.startDate,
    this.endDate,
    required this.lastGenerated,
    this.isActive = true,
    required this.name,
    required this.createdAt,
  });

  RecurrenceFrequency get frequency => RecurrenceFrequency.values[frequencyIndex];

  String get frequencyText {
    switch (frequency) {
      case RecurrenceFrequency.daily:
        return 'Daily';
      case RecurrenceFrequency.weekly:
        return 'Weekly';
      case RecurrenceFrequency.monthly:
        return 'Monthly';
      case RecurrenceFrequency.yearly:
        return 'Yearly';
    }
  }

  DateTime getNextDueDate() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final startDateOnly = DateTime(startDate.year, startDate.month, startDate.day);
    
    // If startDate is in the future, return startDate
    if (startDateOnly.isAfter(todayStart)) {
      return startDate;
    }
    
    // Calculate next due date from lastGenerated
    DateTime next = lastGenerated;
    
    while (next.isBefore(now) || next.isAtSameMomentAs(lastGenerated)) {
      switch (frequency) {
        case RecurrenceFrequency.daily:
          next = next.add(const Duration(days: 1));
          break;
        case RecurrenceFrequency.weekly:
          next = next.add(const Duration(days: 7));
          break;
        case RecurrenceFrequency.monthly:
          next = DateTime(next.year, next.month + 1, next.day);
          break;
        case RecurrenceFrequency.yearly:
          next = DateTime(next.year + 1, next.month, next.day);
          break;
      }
    }
    return next;
  }

  bool shouldGenerateToday() {
    if (!isActive) return false;
    if (endDate != null && DateTime.now().isAfter(endDate!)) return false;
    
    final nextDue = getNextDueDate();
    final today = DateTime.now();
    
    return nextDue.year == today.year &&
           nextDue.month == today.month &&
           nextDue.day == today.day;
  }
}
