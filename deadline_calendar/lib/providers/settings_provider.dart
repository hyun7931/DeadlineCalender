// lib/providers/settings_provider.dart
// 환경설정정

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class SettingsProvider with ChangeNotifier {
  // 기본 설정값
  bool _isDarkMode = true;
  double _fontSize = 1.0;
  int _alarmMinutes = 60; // 기본 1시간 전 알림
  
  // Getters
  bool get isDarkMode => _isDarkMode;
  double get fontSize => _fontSize;
  int get alarmMinutes => _alarmMinutes;
  
  // SharedPreferences keys
  static const String _darkModeKey = 'dark_mode';
  static const String _fontSizeKey = 'font_size';
  static const String _alarmMinutesKey = 'alarm_minutes';
  
  // 초기화 함수
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 저장된 설정 불러오기
    _isDarkMode = prefs.getBool(_darkModeKey) ?? true;
    _fontSize = prefs.getDouble(_fontSizeKey) ?? 1.0;
    _alarmMinutes = prefs.getInt(_alarmMinutesKey) ?? 60;
    
    // 폰트 크기 적용
    AppTheme.setFontSize(_fontSize);
    
    notifyListeners();
  }
  
  // 다크 모드 설정
  Future<void> setDarkMode(bool value) async {
    if (_isDarkMode == value) return;
    
    _isDarkMode = value;
    await _saveSettings();
    notifyListeners();
  }
  
  // 폰트 크기 설정 TODO : 폰트 크기를 적용시켜야함!
  Future<void> setFontSize(double size) async {
    if (_fontSize == size) return;
    
    _fontSize = size;
    AppTheme.setFontSize(_fontSize);
    await _saveSettings();
    notifyListeners();
  }
  
  // 알림 시간 설정
  Future<void> setAlarmMinutes(int minutes) async {
    if (_alarmMinutes == minutes) return;
    
    _alarmMinutes = minutes;
    await _saveSettings();
    notifyListeners();
  }
  
  // 설정 저장
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setBool(_darkModeKey, _isDarkMode);
    await prefs.setDouble(_fontSizeKey, _fontSize);
    await prefs.setInt(_alarmMinutesKey, _alarmMinutes);
  }
} 