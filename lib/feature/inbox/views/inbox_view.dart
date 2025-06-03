import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:us_connector/core/widgets/bottom_navbar.dart';
import 'package:us_connector/feature/inbox/controller/inbox_controller.dart';


class InboxView extends GetView<InboxController> {
  const InboxView({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavbar(),
      body: Center(child: Text('Inbox')),
    );
  }
}