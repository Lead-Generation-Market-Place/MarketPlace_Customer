import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:us_connector/core/utils/app_constants.dart';
import 'package:us_connector/core/routes/routes.dart';

class OneTimeInitialController extends GetxController {
  final pageController = PageController();
  final currentPage = 0.obs;
  late final SharedPreferences _prefs;

  @override
  void onInit() {
    super.onInit();
    _prefs = Get.find<SharedPreferences>();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void onPageChanged(int page) {
    currentPage.value = page;
  }

  void nextPage() {
    if (currentPage.value < 3) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> finishOnboarding() async {
    debugPrint('Onboarding: Marking as complete');
    await _prefs.setBool(AppConstants.onboardingCompleteKey, true);
    debugPrint('Onboarding: Navigating to login');
    Get.offAllNamed(Routes.login);
  }

  Future<void> skipOnboarding() async {
    debugPrint('Onboarding: Skipping onboarding');
    await finishOnboarding();
  }
}
