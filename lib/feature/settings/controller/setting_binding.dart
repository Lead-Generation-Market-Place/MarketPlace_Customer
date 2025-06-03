import 'package:get/get.dart';
import 'package:us_connector/feature/settings/controller/setting_controller.dart';


class SettingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingsController>(() => SettingsController());
  }
} 