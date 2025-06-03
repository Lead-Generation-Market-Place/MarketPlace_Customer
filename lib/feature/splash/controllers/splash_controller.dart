import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/routes/routes.dart';
import '../../../core/utils/app_constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashController extends GetxController {
  final _prefs = Get.find<SharedPreferences>();

  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }








  

  Future<void> _initializeApp() async {
    try {
      // Add a small delay to show splash screen
      await Future.delayed(const Duration(seconds: 2));

      // First, check if onboarding is completed
      final hasCompletedOnboarding = _prefs.getBool(AppConstants.onboardingCompleteKey) ?? false;

      if (!hasCompletedOnboarding) {
        Get.offAllNamed(Routes.onboarding);
        return;
      }

      // If onboarding is completed, check authentication status
      final session = Supabase.instance.client.auth.currentSession;
      final isAuthenticated = session != null && session.isExpired == false;

      if (isAuthenticated) {
        Get.offAllNamed(Routes.home);
      } else {
        Get.offAllNamed(Routes.login);
      }
    } catch (e) {
      debugPrint('Error during app initialization: $e');
      // In case of any error, default to login screen
      Get.offAllNamed(Routes.login);
    }
  }
} 