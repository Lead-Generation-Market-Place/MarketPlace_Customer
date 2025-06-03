import 'package:get/get.dart';
import 'package:us_connector/feature/initial_page/controllers/initial_page_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InitialPageController>(() => InitialPageController());
  }
}