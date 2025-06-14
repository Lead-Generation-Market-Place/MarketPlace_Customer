import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/routes/routes.dart';
import '../../../core/utils/app_constants.dart';
import '../../../feature/auth/controllers/auth_service.dart';

class SplashController extends GetxController {
  late final SharedPreferences _prefs;
  final isInitialized = false.obs;

  @override
  void onInit() {
    super.onInit();
    _prefs = Get.find<SharedPreferences>();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      isInitialized.value = true;
      debugPrint('Splash: Starting initialization');
      
      // Add a small delay to show splash screen
      await Future.delayed(const Duration(seconds: 2));

      // First, check if onboarding is completed
      final hasCompletedOnboarding = _prefs.getBool(AppConstants.onboardingCompleteKey) ?? false;
      debugPrint('Splash: Onboarding completed: $hasCompletedOnboarding');

      if (!hasCompletedOnboarding) {
        debugPrint('Splash: Navigating to onboarding');
        Get.offAllNamed(Routes.onboarding);
        return;
      }

      // If onboarding is completed, check authentication status
      final authService = Get.find<AuthService>();
      final isAuthenticated = authService.isUserAuthenticated;
      debugPrint('Splash: User authenticated: $isAuthenticated');

      if (isAuthenticated) {
        debugPrint('Splash: Navigating to home');
        Get.offAllNamed(Routes.home);
      } else {
        debugPrint('Splash: Navigating to login');
        Get.offAllNamed(Routes.login);
      }
    } catch (e) {
      debugPrint('Splash: Error during initialization: $e');
      // In case of any error, default to login screen
      Get.offAllNamed(Routes.login);
    }
  }

  Future<void> finishOnboarding() async {
    await _prefs.setBool(AppConstants.onboardingCompleteKey, true);
    Get.offAllNamed(Routes.login);
  }
} 