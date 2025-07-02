import 'package:get/get.dart';
import 'package:us_connector/feature/inbox/controller/inbox_controller.dart';

class InboxBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InboxController>(() => InboxController());
  }
}
