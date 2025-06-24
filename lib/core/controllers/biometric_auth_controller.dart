import 'package:local_auth/local_auth.dart';

class BiometricAuthController {
  Future<bool> authenticate() async {
    final LocalAuthentication auth = LocalAuthentication();

    // Check if the device supports biometric authentication
    if (!await auth.isDeviceSupported()) {
      return true; // Allow access if device doesn't support biometrics
    }

    try {
      return await auth.authenticate(localizedReason: 'Powered By Yalpax');
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }
}
