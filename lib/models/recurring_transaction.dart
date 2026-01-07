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
    
    // For monthly/yearly, use the day from startDate to keep consistency
    final targetDay = startDate.day;
    
    // Calculate next due date based on frequency
    DateTime next;
    
    switch (frequency) {
      case RecurrenceFrequency.daily:
        // For daily, simply find the next day after lastGenerated that's >= today
        next = lastGenerated.add(const Duration(days: 1));
        while (next.isBefore(todayStart)) {
          next = next.add(const Duration(days: 1));
        }
        break;
        
      case RecurrenceFrequency.weekly:
        // For weekly, add 7 days from lastGenerated until >= today
        next = lastGenerated.add(const Duration(days: 7));
        while (next.isBefore(todayStart)) {
          next = next.add(const Duration(days: 7));
        }
        break;
        
      case RecurrenceFrequency.monthly:
        // For monthly, use the original startDate.day
        int nextMonth = lastGenerated.month + 1;
        int nextYear = lastGenerated.year;
        if (nextMonth > 12) {
          nextMonth = 1;
          nextYear++;
        }
        // Handle months with fewer days (e.g., Feb 30 -> Feb 28)
        int daysInMonth = DateTime(nextYear, nextMonth + 1, 0).day;
        int actualDay = targetDay > daysInMonth ? daysInMonth : targetDay;
        next = DateTime(nextYear, nextMonth, actualDay);
        
        while (next.isBefore(todayStart)) {
          nextMonth++;
          if (nextMonth > 12) {
            nextMonth = 1;
            nextYear++;
          }
          daysInMonth = DateTime(nextYear, nextMonth + 1, 0).day;
          actualDay = targetDay > daysInMonth ? daysInMonth : targetDay;
          next = DateTime(nextYear, nextMonth, actualDay);
        }
        break;
        
      case RecurrenceFrequency.yearly:
        // For yearly, use the original startDate's month and day
        int nextYear = lastGenerated.year + 1;
        // Handle leap year for Feb 29
        int daysInMonth = DateTime(nextYear, startDate.month + 1, 0).day;
        int actualDay = targetDay > daysInMonth ? daysInMonth : targetDay;
        next = DateTime(nextYear, startDate.month, actualDay);
        
        while (next.isBefore(todayStart)) {
          nextYear++;
          daysInMonth = DateTime(nextYear, startDate.month + 1, 0).day;
          actualDay = targetDay > daysInMonth ? daysInMonth : targetDay;
          next = DateTime(nextYear, startDate.month, actualDay);
        }
        break;
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
