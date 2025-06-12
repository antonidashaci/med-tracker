import 'package:flutter/cupertino.dart';

class AppColors {
  // iOS Primary Colors
  static const Color primaryBlue = Color(0xFF007AFF);
  static const Color secondaryBlue = Color(0xFF5AC8FA);
  static const Color accentBlue = Color(0xFF34C759);
  
  // Background Colors
  static const Color background = Color(0xFFF2F2F7);
  static const Color secondaryBackground = Color(0xFFFFFFFF);
  static const Color tertiaryBackground = Color(0xFFE5E5EA);
  
  // Text Colors
  static const Color primaryText = Color(0xFF000000);
  static const Color secondaryText = Color(0xFF8E8E93);
  static const Color tertiaryText = Color(0xFFC7C7CC);
  
  // Status Colors
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFF9500);
  static const Color error = Color(0xFFFF3B30);
  static const Color info = Color(0xFF007AFF);
  
  // Medicine Status Colors
  static const Color activeMedicine = Color(0xFF34C759);
  static const Color inactiveMedicine = Color(0xFF8E8E93);
  static const Color expiredMedicine = Color(0xFFFF3B30);
  
  // Chart Colors
  static const List<Color> chartColors = [
    Color(0xFF007AFF),
    Color(0xFF34C759),
    Color(0xFFFF9500),
    Color(0xFFFF3B30),
    Color(0xFFAF52DE),
    Color(0xFF5856D6),
  ];
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, secondaryBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [success, Color(0xFF30D158)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
} 