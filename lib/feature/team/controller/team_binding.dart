import 'package:get/get.dart';
import 'package:us_connector/feature/team/controller/team_controller.dart';


class TeamBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TeamController>(() => TeamController());
  }
}