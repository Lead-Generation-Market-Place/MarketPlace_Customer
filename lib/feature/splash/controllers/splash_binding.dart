import 'package:get/get.dart';
import 'package:us_connector/feature/splash/controllers/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<SplashController>(
      SplashController(),
      permanent: true,
    );
  }
} 