import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

// Language Provider to manage app language
// Supports changing language at runtime

class LanguageProvider extends ChangeNotifier {
  String _currentLanguage = 'en';

  String get currentLanguage => _currentLanguage;

  // Initialize language from SharedPreferences
  Future<void> initLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString(AppConstants.keyLanguage) ?? 'English';
    
    // Convert to language codes
    _currentLanguage = _getLanguageCode(savedLanguage);
    notifyListeners();
  }

  // Set language
  Future<void> setLanguage(String language) async {
    final languageCode = _getLanguageCode(language);
    
    if (_currentLanguage != languageCode) {
      _currentLanguage = languageCode;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.keyLanguage, language);
      
      notifyListeners();
    }
  }

  // Get language name from code
  String getLanguageName() {
    switch (_currentLanguage) {
      case 'hi':
        return 'Hindi';
      case 'mr':
        return 'Marathi';
      default:
        return 'English';
    }
  }

  // Get language code from name
  String _getLanguageCode(String languageName) {
    switch (languageName) {
      case 'Hindi':
        return 'hi';
      case 'Marathi':
        return 'mr';
      default:
        return 'en';
    }
  }
}
