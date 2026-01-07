// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 2;

  @override
  UserProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfile(
      name: fields[0] as String? ?? 'User',
      avatarPath: fields[1] as String?,
      currency: fields[2] as String? ?? '฿',
      avatarColorValue: fields[3] as int? ?? 0xFFFF9A9E,
      createdAt: fields[4] as DateTime? ?? DateTime.now(),
      isDarkMode: fields[5] as bool? ?? false,
      languageCode: fields[6] as String? ?? 'en',
      hiddenCategories: (fields[7] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.avatarPath)
      ..writeByte(2)
      ..write(obj.currency)
      ..writeByte(3)
      ..write(obj.avatarColorValue)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.isDarkMode)
      ..writeByte(6)
      ..write(obj.languageCode)
      ..writeByte(7)
      ..write(obj.hiddenCategories);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
