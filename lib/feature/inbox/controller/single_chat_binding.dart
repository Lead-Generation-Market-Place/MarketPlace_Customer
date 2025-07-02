import 'package:get/get.dart';
import 'package:us_connector/feature/inbox/controller/single_chat_controller.dart';

class SingleChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SingleChatController>(() => SingleChatController());
  }
}
