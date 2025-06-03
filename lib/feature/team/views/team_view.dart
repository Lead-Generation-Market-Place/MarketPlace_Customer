import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:us_connector/core/widgets/bottom_navbar.dart';
import 'package:us_connector/feature/team/controller/team_controller.dart';


class TeamView extends GetView<TeamController> {
  const TeamView({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavbar(),
      body: Center(child: Text('Team')),
    );
  }
}