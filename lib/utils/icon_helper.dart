import 'package:flutter/material.dart';

class IconHelper {
  // Categorized icons for better UI organization
  static final Map<String, List<IconData>> iconGroups = {
    'General': [
      Icons.home, Icons.work, Icons.school, Icons.shopping_bag, Icons.shopping_cart,
      Icons.local_mall, Icons.store, Icons.card_giftcard, Icons.savings,
      Icons.account_balance, Icons.attach_money, Icons.trending_up, Icons.category,
      Icons.build, Icons.delete, Icons.list, Icons.star, Icons.flag,
    ],
    'Food & Drink': [
      Icons.restaurant, Icons.local_cafe, Icons.fastfood, Icons.local_pizza,
      Icons.local_bar, Icons.local_dining, Icons.kitchen, Icons.cake,
      Icons.liquor, Icons.icecream, Icons.bakery_dining, Icons.coffee,
    ],
    'Transport': [
      Icons.flight, Icons.directions_car, Icons.directions_bus, Icons.train,
      Icons.subway, Icons.directions_bike, Icons.local_taxi, Icons.local_gas_station,
      Icons.commute, Icons.directions_boat, Icons.motorcycle, Icons.ev_station,
    ],
    'Leisure': [
      Icons.movie, Icons.sports_esports, Icons.fitness_center, Icons.pool,
      Icons.music_note, Icons.sports_soccer, Icons.beach_access, Icons.camera_alt,
      Icons.book, Icons.palette, Icons.brush, Icons.queue_music, Icons.mic,
    ],
    'Health': [
      Icons.medical_services, Icons.local_hospital, Icons.medication, Icons.spa,
      Icons.healing, Icons.monitor_heart, Icons.local_pharmacy, Icons.fitness_center,
    ],
    'Personal & Family': [
      Icons.person, Icons.group, Icons.face, Icons.child_friendly, Icons.pets,
      Icons.child_care, Icons.accessibility, Icons.wc, Icons.emoji_emotions,
    ],
    'Bills & Utils': [
      Icons.phone_android, Icons.wifi, Icons.electrical_services, Icons.water_drop,
      Icons.receipt, Icons.credit_card, Icons.lightbulb, Icons.router, Icons.laptop,
    ],
  };

  // Get flat list of all availability icons (for backward compatibility/search)
  static List<IconData> get allIcons => iconGroups.values.expand((list) => list).toList();
  
  // Static icon code point map for tree-shaking compatibility
  static final Map<int, IconData> _iconCodePointMap = {
    for (var icon in iconGroups.values.expand((list) => list))
      icon.codePoint: icon,
  };
  
  // Get IconData from CodePoint (tree-shake safe)
  static IconData getIconFromCodePoint(int codePoint) {
    if (codePoint == 0) return Icons.category;
    // Look up from static map, fallback to category icon
    return _iconCodePointMap[codePoint] ?? Icons.category;
  }
}
