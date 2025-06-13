class AppConstants {
  // App Info
  static const String appName = 'Yalpax';
  static const String appVersion = '1.0.0';
  
  // API Endpoints
  static const String supabaseUrl = 'https://hdwfpfxyzubfksctezkz.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhkd2ZwZnh5enViZmtzY3Rlemt6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc5NDE3NzQsImV4cCI6MjA2MzUxNzc3NH0.tQ8XB__I-tOypaOUzlVd9XG0ldI21Lvu2LjfpF3UgLM';

  // Storage Keys
  static const String themeKey = 'theme_mode';
  static const String localeKey = 'locale';
  static const String onboardingCompleteKey = 'onboarding_complete';
  static const String userTokenKey = 'user_token';

  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds

  // Cache Duration
  static const int cacheDuration = 7; // 7 days

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 32;
  static const int maxUsernameLength = 30;
  static const int maxNameLength = 50;
  static const int maxEmailLength = 254;
  static const int maxPhoneLength = 15;

  // File Size Limits (in bytes)
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB

  // Image Quality
  static const double defaultImageQuality = 0.8;
  static const int maxImageWidth = 1920;
  static const int maxImageHeight = 1080;

  // Private constructor to prevent instantiation
  AppConstants._();
} 