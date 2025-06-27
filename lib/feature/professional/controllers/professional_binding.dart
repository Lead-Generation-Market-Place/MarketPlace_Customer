import 'package:get/get.dart';

import 'professional_controller.dart';

class ProfessionalBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProfessionalController());
  }
}
