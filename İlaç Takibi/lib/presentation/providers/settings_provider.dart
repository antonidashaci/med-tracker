import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';

class SettingsProvider extends ChangeNotifier {
  final Box _settingsBox = Hive.box(AppConstants.settingsKey);
  
  Locale _locale = const Locale('tr', 'TR');
  Brightness _brightness = Brightness.light;
  bool _notificationsEnabled = true;
  int _reminderAdvanceMinutes = 15;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  // Getters
  Locale get locale => _locale;
  Brightness get brightness => _brightness;
  bool get notificationsEnabled => _notificationsEnabled;
  int get reminderAdvanceMinutes => _reminderAdvanceMinutes;
  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;

  // Initialize
  Future<void> initialize() async {
    await loadSettings();
  }

  // Load settings
  Future<void> loadSettings() async {
    try {
      _locale = Locale(
        _settingsBox.get('language', defaultValue: 'tr'),
        _settingsBox.get('languageCountry', defaultValue: 'TR'),
      );
      
      final brightnessString = _settingsBox.get('brightness', defaultValue: 'light');
      _brightness = _getBrightnessFromString(brightnessString);
      
      _notificationsEnabled = _settingsBox.get('notificationsEnabled', defaultValue: true);
      _reminderAdvanceMinutes = _settingsBox.get('reminderAdvanceMinutes', defaultValue: 15);
      _soundEnabled = _settingsBox.get('soundEnabled', defaultValue: true);
      _vibrationEnabled = _settingsBox.get('vibrationEnabled', defaultValue: true);
      
      notifyListeners();
    } catch (e) {
      debugPrint('Settings yüklenirken hata: $e');
    }
  }

  // Save settings
  Future<void> _saveSettings() async {
    try {
      await _settingsBox.put('language', _locale.languageCode);
      await _settingsBox.put('languageCountry', _locale.countryCode);
      await _settingsBox.put('brightness', _getBrightnessString(_brightness));
      await _settingsBox.put('notificationsEnabled', _notificationsEnabled);
      await _settingsBox.put('reminderAdvanceMinutes', _reminderAdvanceMinutes);
      await _settingsBox.put('soundEnabled', _soundEnabled);
      await _settingsBox.put('vibrationEnabled', _vibrationEnabled);
    } catch (e) {
      debugPrint('Settings kaydedilirken hata: $e');
    }
  }

  // Set locale
  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    await _saveSettings();
    notifyListeners();
  }

  // Set brightness
  Future<void> setBrightness(Brightness brightness) async {
    _brightness = brightness;
    await _saveSettings();
    notifyListeners();
  }

  // Set notifications enabled
  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    await _saveSettings();
    notifyListeners();
  }

  // Set reminder advance minutes
  Future<void> setReminderAdvanceMinutes(int minutes) async {
    _reminderAdvanceMinutes = minutes;
    await _saveSettings();
    notifyListeners();
  }

  // Set sound enabled
  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    await _saveSettings();
    notifyListeners();
  }

  // Set vibration enabled
  Future<void> setVibrationEnabled(bool enabled) async {
    _vibrationEnabled = enabled;
    await _saveSettings();
    notifyListeners();
  }

  // Helper methods
  Brightness _getBrightnessFromString(String brightnessString) {
    switch (brightnessString) {
      case 'dark':
        return Brightness.dark;
      default:
        return Brightness.light;
    }
  }

  String _getBrightnessString(Brightness brightness) {
    switch (brightness) {
      case Brightness.dark:
        return 'dark';
      case Brightness.light:
        return 'light';
    }
  }

  // Get brightness display name
  String getBrightnessDisplayName() {
    switch (_brightness) {
      case Brightness.light:
        return 'Açık';
      case Brightness.dark:
        return 'Koyu';
    }
  }

  // Get locale display name
  String getLocaleDisplayName() {
    switch (_locale.languageCode) {
      case 'tr':
        return 'Türkçe';
      case 'en':
        return 'English';
      default:
        return 'Türkçe';
    }
  }

  // Reset to defaults
  Future<void> resetToDefaults() async {
    _locale = const Locale('tr', 'TR');
    _brightness = Brightness.light;
    _notificationsEnabled = true;
    _reminderAdvanceMinutes = 15;
    _soundEnabled = true;
    _vibrationEnabled = true;
    
    await _saveSettings();
    notifyListeners();
  }
} 