import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:us_connector/core/routes/routes.dart';
import 'package:us_connector/feature/plan/controller/local_plan_controller.dart';

class LocalPlanView extends GetView<LocalPlansController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.toNamed(Routes.plan),
          icon: Icon(Icons.arrow_back_ios),
        ),
      ),
      body: Obx(() {
        return Text(controller.startedPlans.toString());
      }),
    );
  }
}
