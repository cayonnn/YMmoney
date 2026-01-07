import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../l10n/app_strings.dart';

/// Global language controller for managing app localization
class LanguageController extends ChangeNotifier {
  static final LanguageController _instance = LanguageController._internal();
  factory LanguageController() => _instance;
  LanguageController._internal();

  AppLanguage _language = AppLanguage.english;

  AppLanguage get language => _language;

  void setLanguage(AppLanguage lang) {
    _language = lang;
    AppStrings.setLanguage(lang);
    notifyListeners();
  }

  void setLanguageFromCode(String code) {
    switch (code) {
      case 'th': setLanguage(AppLanguage.thai); break;
      case 'en': setLanguage(AppLanguage.english); break;
      case 'zh_CN': setLanguage(AppLanguage.chineseSimplified); break;
      case 'zh_TW': setLanguage(AppLanguage.chineseTraditional); break;
      case 'ja': setLanguage(AppLanguage.japanese); break;
      case 'ko': setLanguage(AppLanguage.korean); break;
      case 'ru': setLanguage(AppLanguage.russian); break;
      default: setLanguage(AppLanguage.english);
    }
  }

  void loadFromProfile() {
    final db = DatabaseService();
    final profile = db.getUserProfile();
    setLanguageFromCode(profile.languageCode);
  }
}
