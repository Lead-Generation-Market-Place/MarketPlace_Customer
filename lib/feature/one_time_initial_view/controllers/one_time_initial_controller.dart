import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:us_connector/core/utils/app_constants.dart';
import 'package:us_connector/core/routes/routes.dart';

class OneTimeInitialController extends GetxController {
  final pageController = PageController();
  final currentPage = 0.obs;

  @override
  void onInit() {
    super.onInit();
    checkOnboardingStatus();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  Future<void> checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingComplete = prefs.getBool(AppConstants.onboardingCompleteKey) ?? false;
    
    if (onboardingComplete) {
      Get.offAllNamed(Routes.login);
    }
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.onboardingCompleteKey, true);
    Get.offAllNamed(Routes.login);
  }

  Future<void> skipOnboarding() async {
    await finishOnboarding();
  }
}
