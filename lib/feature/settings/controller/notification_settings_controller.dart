import 'dart:developer';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:us_connector/core/utils/app_constants.dart';

class NotificationSettingsController extends GetxController {
  RxBool isBiometricAvailable = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize any necessary data or state here
    checkBiometricAvailability();
  }

  //to Check if User enabled biometric authentication
  checkBiometricAvailability() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (preferences.containsKey(AppConstants.isBiometricKey)) {
      isBiometricAvailable.value = true;
    } else {
      isBiometricAvailable.value = false;
    }
  }

  // Function to toggle biometric availability
  toggleBiometricAvailability() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (isBiometricAvailable.value) {
      await preferences.remove(AppConstants.isBiometricKey);
      isBiometricAvailable.value = false;
      log('Biometric authentication disabled');
    } else {
      await preferences.setBool(AppConstants.isBiometricKey, true);
      isBiometricAvailable.value = true;
      log('Biometric authentication enabled');
    }
  }
}
