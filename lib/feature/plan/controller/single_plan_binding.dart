import 'package:get/get_instance/get_instance.dart';
import 'package:get/route_manager.dart';
import 'package:us_connector/feature/plan/controller/single_plan_controller.dart';

class SinglePlanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SinglePlanController>(() => SinglePlanController());
  }
}
