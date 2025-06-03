import 'package:get/get.dart';
import '../controllers/theme_controller.dart';
import '../../feature/splash/controllers/splash_controller.dart';

class ServiceBindings extends Bindings {
  @override
  Future<void> dependencies() async {
    // Core Services
    // Add your core services here
    
    // Controllers
    Get.lazyPut<ThemeController>(
      () => ThemeController(),
      fenix: true,
    );

    Get.lazyPut<SplashController>(
      () => SplashController(),
      fenix: true,
    );

    // Repositories
    // Add your repositories here

    // API Services
    // Add your API services here

    // Utils
    // Add your utility services here
  }
} 