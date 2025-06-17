import 'package:get/get_instance/get_instance.dart';
import 'package:get/route_manager.dart';
import 'package:us_connector/feature/plan/controller/local_plan_controller.dart';

class LocalPlanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LocalPlansController>(() => LocalPlansController());
  }
}
