import 'package:hive/hive.dart';

part 'custom_category.g.dart';

@HiveType(typeId: 1)
class CustomCategory extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int iconCodePoint;

  @HiveField(3)
  int colorValue;

  @HiveField(4)
  bool isExpense;

  @HiveField(5)
  DateTime createdAt;

  CustomCategory({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    required this.colorValue,
    required this.isExpense,
    required this.createdAt,
  });
}
