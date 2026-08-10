import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _localeKey = 'locale';
  final _userBox = Hive.box('userBox');

  String _currentLocale = 'vi';

  String get currentLocale => _currentLocale;

  LanguageProvider() {
    _loadLocale();
  }

  void _loadLocale() {
    _currentLocale = _userBox.get(_localeKey, defaultValue: 'vi');
    notifyListeners();
  }

  Future<void> toggleLanguage() async {
    _currentLocale = _currentLocale == 'vi' ? 'en' : 'vi';
    await _userBox.put(_localeKey, _currentLocale);
    notifyListeners();
  }

  Future<void> setLanguage(String locale) async {
    if (locale == 'vi' || locale == 'en') {
      _currentLocale = locale;
      await _userBox.put(_localeKey, _currentLocale);
      notifyListeners();
    }
  }
}
