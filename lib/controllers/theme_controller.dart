import 'package:flutter/material.dart';
import '../services/database_service.dart';

/// Global theme controller for managing dark/light mode
class ThemeController extends ChangeNotifier {
  static final ThemeController _instance = ThemeController._internal();
  factory ThemeController() => _instance;
  ThemeController._internal();

  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void setDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  void loadFromProfile() {
    final db = DatabaseService();
    final profile = db.getUserProfile();
    _isDarkMode = profile.isDarkMode;
  }
}
