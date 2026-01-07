import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 2)
class UserProfile extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String? avatarPath;

  @HiveField(2)
  String currency;

  @HiveField(3)
  int avatarColorValue;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  bool isDarkMode;

  @HiveField(6)
  String languageCode;

  @HiveField(7)
  List<String>? hiddenCategories;

  UserProfile({
    required this.name,
    this.avatarPath,
    this.currency = '฿',
    this.avatarColorValue = 0xFFFF9A9E,
    required this.createdAt,
    this.isDarkMode = false,
    this.languageCode = 'en',
    this.hiddenCategories,
  });

  // Default profile
  factory UserProfile.defaultProfile() {
    return UserProfile(
      name: 'User',
      currency: '฿',
      avatarColorValue: 0xFFFF9A9E,
      createdAt: DateTime.now(),
      isDarkMode: false,
      languageCode: 'en',
      hiddenCategories: [],
    );
  }
}

