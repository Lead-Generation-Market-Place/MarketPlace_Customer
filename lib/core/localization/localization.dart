import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LocalizationService extends Translations {
  // Default locale
  static const locale = Locale('en', 'US');

  // Fallback locale
  static const fallbackLocale = Locale('en', 'US');

  // Supported languages
  static final languages = [
    'English',
    'العربية',
  ];

  // Supported locales
  static final locales = [
    const Locale('en', 'US'),
    const Locale('ar', 'SA'),
  ];

  // Keys and their translations
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': {
          // Bottom Navigation
          'nav_home': 'Home',
          'nav_search': 'Search',
          'nav_favorites': 'Favorites',
          'nav_settings': 'Settings',

          // General
          'app_name': 'My App',
          'welcome': 'Welcome',
          'loading': 'Loading...',
          'error': 'Error',
          'success': 'Success',
          'try_again': 'Try Again',
          'ok': 'OK',
          'cancel': 'Cancel',
          'save': 'Save',
          'delete': 'Delete',
          'edit': 'Edit',
          'update': 'Update',

          // Settings
          'settings': 'Settings',
          'language': 'Language',
          'theme': 'Theme',
          'dark_mode': 'Dark Mode',
          'light_mode': 'Light Mode',
          'system_default': 'System Default',
          'notifications': 'Notifications',
          'profile': 'Profile',
          'about': 'About',
          'logout': 'Logout',

          // Auth
          'login': 'Login',
          'register': 'Register',
          'email': 'Email',
          'password': 'Password',
          'forgot_password': 'Forgot Password?',
          'confirm_password': 'Confirm Password',
        },
        'ar_SA': {
          // Bottom Navigation
          'nav_home': 'الرئيسية',
          'nav_search': 'البحث',
          'nav_favorites': 'المفضلة',
          'nav_settings': 'الإعدادات',

          // General
          'app_name': 'تطبيقي',
          'welcome': 'مرحباً',
          'loading': 'جاري التحميل...',
          'error': 'خطأ',
          'success': 'نجاح',
          'try_again': 'حاول مرة أخرى',
          'ok': 'موافق',
          'cancel': 'إلغاء',
          'save': 'حفظ',
          'delete': 'حذف',
          'edit': 'تعديل',
          'update': 'تحديث',

          // Settings
          'settings': 'الإعدادات',
          'language': 'اللغة',
          'theme': 'المظهر',
          'dark_mode': 'الوضع الداكن',
          'light_mode': 'الوضع الفاتح',
          'system_default': 'إعدادات النظام',
          'notifications': 'الإشعارات',
          'profile': 'الملف الشخصي',
          'about': 'حول التطبيق',
          'logout': 'تسجيل الخروج',

          // Auth
          'login': 'تسجيل الدخول',
          'register': 'إنشاء حساب',
          'email': 'البريد الإلكتروني',
          'password': 'كلمة المرور',
          'forgot_password': 'نسيت كلمة المرور؟',
          'confirm_password': 'تأكيد كلمة المرور',
        },
      };

  // Gets locale from language, and updates the locale
  static void changeLocale(String lang) {
    final locale = _getLocaleFromLanguage(lang);
    Get.updateLocale(locale);
  }

  // Finds language in `languages` list and returns it as Locale
  static Locale _getLocaleFromLanguage(String lang) {
    for (int i = 0; i < languages.length; i++) {
      if (lang == languages[i]) return locales[i];
    }
    return Get.locale ?? locale;
  }

  static String getCurrentLanguage() {
    final locale = Get.locale;
    if (locale?.languageCode == 'ar') {
      return 'العربية';
    }
    return 'English';
  }

  static bool isArabic() {
    return Get.locale?.languageCode == 'ar';
  }
}
