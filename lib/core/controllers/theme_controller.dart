import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_colors.dart';

class ThemeController extends GetxController {
  static const String _key = 'themeMode';
  late SharedPreferences _prefs;

  // Theme mode tracker
  final Rx<ThemeMode> _themeMode = ThemeMode.system.obs;
  
  ThemeMode get themeMode => _themeMode.value;

  // Load theme on app start
  @override
  void onInit() async {
    super.onInit();
    await _initPrefs();
    _loadThemeFromPrefs();
  }

  // Initialize theme
  Future<void> initTheme() async {
    await _initPrefs();
    _loadThemeFromPrefs();
  }

  // Initialize SharedPreferences
  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Load saved theme from local storage
  void _loadThemeFromPrefs() {
    final String? savedTheme = _prefs.getString(_key);
    if (savedTheme != null) {
      setThemeMode(ThemeMode.values.firstWhere(
        (e) => e.toString() == savedTheme,
        orElse: () => ThemeMode.system,
      ));
    }
  }

  // Save theme to local storage
  Future<void> _saveThemeToPrefs(ThemeMode mode) async {
    await _prefs.setString(_key, mode.toString());
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode.value = mode;
    _saveThemeToPrefs(mode);
    _updateTheme();
  }

  // Update GetX theme
  void _updateTheme() {
    if (_themeMode.value == ThemeMode.system) {
      final brightness = Get.mediaQuery.platformBrightness;
      Get.changeTheme(brightness == Brightness.dark ? darkTheme : lightTheme);
    } else {
      Get.changeTheme(_themeMode.value == ThemeMode.dark ? darkTheme : lightTheme);
    }
  }

  // Light theme
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primaryBlue,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.light().copyWith(
      primary: AppColors.primaryBlue,
      secondary: AppColors.secondaryBlue,
      error: AppColors.error,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primaryBlue,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primaryBlue,
      unselectedItemColor: AppColors.neutral400,
      elevation: 8,
    ),
    textTheme: TextTheme(
      headlineLarge: TextStyle(color: AppColors.textPrimary),
      headlineMedium: TextStyle(color: AppColors.textPrimary),
      bodyLarge: TextStyle(color: AppColors.textPrimary),
      bodyMedium: TextStyle(color: AppColors.textSecondary),
    ),
    dividerColor: AppColors.neutral200,
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  // Dark theme
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryBlue,
    scaffoldBackgroundColor: const Color(0xFF121212),
    colorScheme: const ColorScheme.dark().copyWith(
      primary: AppColors.primaryBlue,
      secondary: AppColors.secondaryBlue,
      error: AppColors.error,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1E1E1E),
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
      elevation: 8,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: Colors.white),
      headlineMedium: TextStyle(color: Colors.white),
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
    dividerColor: Colors.white24,
    cardTheme: CardThemeData(
      color: const Color(0xFF1E1E1E),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  // Helper methods to check current theme
  bool get isDarkMode => _themeMode.value == ThemeMode.dark;
  bool get isLightMode => _themeMode.value == ThemeMode.light;
  bool get isSystemMode => _themeMode.value == ThemeMode.system;

  // Get current theme mode name
  String get themeModeText {
    switch (_themeMode.value) {
      case ThemeMode.light:
        return 'light_mode'.tr;
      case ThemeMode.dark:
        return 'dark_mode'.tr;
      case ThemeMode.system:
        return 'system_default'.tr;
    }
  }
}
