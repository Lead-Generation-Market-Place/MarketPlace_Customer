import 'package:get/get.dart';

class NotificationSettingsController extends GetxController {
  var isDrawerOpen = false.obs;
  var isExpanded = false.obs;
  var isLoading = false.obs;
  var isNotificationEnabled = true.obs;
  var isNotificationSoundEnabled = true.obs;

  chageDrawerState() {
    isDrawerOpen.value = !isDrawerOpen.value;
  }
}
