import 'package:get/get.dart';
import 'package:us_connector/feature/one_time_initial_view/controllers/one_time_initial_controller.dart';

class OneTimeInitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OneTimeInitialController>(() => OneTimeInitialController());
  }}