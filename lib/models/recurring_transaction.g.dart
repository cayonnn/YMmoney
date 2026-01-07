// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_transaction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecurringTransactionAdapter extends TypeAdapter<RecurringTransaction> {
  @override
  final int typeId = 4;

  @override
  RecurringTransaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecurringTransaction(
      id: fields[0] as String? ?? '',
      amount: fields[1] as double? ?? 0.0,
      categoryId: fields[2] as String? ?? '',
      note: fields[3] as String? ?? '',
      isExpense: fields[4] as bool? ?? true,
      currency: fields[5] as String? ?? '฿',
      frequencyIndex: fields[6] as int? ?? 2,
      startDate: fields[7] as DateTime? ?? DateTime.now(),
      endDate: fields[8] as DateTime?,
      lastGenerated: fields[9] as DateTime? ?? DateTime.now(),
      isActive: fields[10] as bool? ?? true,
      name: fields[11] as String? ?? '',
      createdAt: fields[12] as DateTime? ?? DateTime.now(),
    );
  }

  @override
  void write(BinaryWriter writer, RecurringTransaction obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.categoryId)
      ..writeByte(3)
      ..write(obj.note)
      ..writeByte(4)
      ..write(obj.isExpense)
      ..writeByte(5)
      ..write(obj.currency)
      ..writeByte(6)
      ..write(obj.frequencyIndex)
      ..writeByte(7)
      ..write(obj.startDate)
      ..writeByte(8)
      ..write(obj.endDate)
      ..writeByte(9)
      ..write(obj.lastGenerated)
      ..writeByte(10)
      ..write(obj.isActive)
      ..writeByte(11)
      ..write(obj.name)
      ..writeByte(12)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecurringTransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
