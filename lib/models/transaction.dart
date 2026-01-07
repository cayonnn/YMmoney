import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 0)
class TransactionModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  double amount;

  @HiveField(2)
  String categoryId;

  @HiveField(3)
  String note;

  @HiveField(4)
  DateTime date;

  @HiveField(5)
  bool isExpense;

  @HiveField(6)
  String currency;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.categoryId,
    this.note = '',
    required this.date,
    required this.isExpense,
    this.currency = '฿',
  });

  TransactionModel copyWith({
    String? id,
    double? amount,
    String? categoryId,
    String? note,
    DateTime? date,
    bool? isExpense,
    String? currency,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      note: note ?? this.note,
      date: date ?? this.date,
      isExpense: isExpense ?? this.isExpense,
      currency: currency ?? this.currency,
    );
  }
}

