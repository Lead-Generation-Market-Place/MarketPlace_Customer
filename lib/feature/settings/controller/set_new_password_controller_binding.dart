import 'package:get/get.dart';
import 'package:us_connector/feature/settings/controller/set_new_password_controller.dart';



class SetNewPasswordControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SetNewPasswordController>(() => SetNewPasswordController());
  }
} 