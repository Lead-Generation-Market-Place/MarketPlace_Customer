import 'package:get/get.dart';
import 'package:us_connector/feature/settings/controller/notification_settings_controller.dart';

class NotificationSettingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificationSettingsController>(
      () => NotificationSettingsController(),
    );
  }
}
