class AppConstants {
  // App Info
  static const String appName = 'İlaç Takibi';
  static const String appVersion = '1.0.0';
  
  // Storage Keys
  static const String medicinesKey = 'medicines';
  static const String remindersKey = 'reminders';
  static const String historyKey = 'medicine_history';
  static const String settingsKey = 'user_settings';
  static const String languageKey = 'language';
  static const String themeKey = 'theme';
  
  // Notification IDs
  static const int medicineReminderId = 1000;
  static const int appointmentReminderId = 2000;
  
  // Time Constants
  static const int reminderAdvanceMinutes = 15;
  static const int maxRemindersPerMedicine = 10;
  
  // Medicine Categories
  static const List<String> medicineCategories = [
    'Antibiyotik',
    'Ağrı Kesici',
    'Vitamin',
    'Kalp İlacı',
    'Tansiyon İlacı',
    'Şeker İlacı',
    'Antidepresan',
    'Diğer',
  ];
  
  // Dosage Units
  static const List<String> dosageUnits = [
    'tablet',
    'kapsül',
    'şurup (ml)',
    'damla',
    'ampul',
    'mg',
    'gram',
  ];
  
  // Frequency Options
  static const List<String> frequencyOptions = [
    'Günde 1 kez',
    'Günde 2 kez',
    'Günde 3 kez',
    'Günde 4 kez',
    'Haftada 1 kez',
    'Haftada 2 kez',
    'Haftada 3 kez',
    'Ayda 1 kez',
    'Özel',
  ];
  
  // Days of Week
  static const List<String> daysOfWeek = [
    'Pazartesi',
    'Salı',
    'Çarşamba',
    'Perşembe',
    'Cuma',
    'Cumartesi',
    'Pazar',
  ];
  
  // Short Days
  static const List<String> shortDays = [
    'Pzt',
    'Sal',
    'Çar',
    'Per',
    'Cum',
    'Cmt',
    'Paz',
  ];
  
  // Chart Periods
  static const List<String> chartPeriods = [
    'Son 7 gün',
    'Son 30 gün',
    'Son 3 ay',
    'Son 6 ay',
    'Son 1 yıl',
  ];
} 