import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:us_connector/core/widgets/bottom_navbar.dart';
import 'package:us_connector/feature/home/controllers/home_controller.dart';
import 'package:us_connector/core/widgets/app_bar.dart';

class HomeView extends GetView<HomeController> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavbar(),
      body: CustomScrollView(
        slivers: <Widget>[
          ScrollableAppBarWithFixedSearch(
            title: const Text("Let's get started"),
            actions: [
              IconButton(
                icon: const Icon(Icons.person_outline),
                onPressed: () {
                  // TODO: Implement profile action
                },
              ),
            ],
            searchController: _searchController,
            onSearchChanged: (value) {
              // TODO: Implement search logic or debounce
              print("Search: $value");
            },
            onSearchSubmitted: () {
              // TODO: Implement search submission
              print("Search submitted: ${_searchController.text}");
            },
            searchHintText: "What do you need help with?",
          ),
          // SliverList(
          //   delegate: SliverChildBuilderDelegate(
          //     (BuildContext context, int index) {
          //       return ListTile(
          //         title: Text('Service Category $index'),
          //         subtitle: Text('Description for service category $index'),
          //         leading: Icon(Icons.home_repair_service_outlined),
          //         onTap: () {
          //           // TODO: Navigate to category details
          //         },
          //       );
          //     },
          //     childCount: 20,
          //   ),
          // ),
        ],
      ),
    );
  }
}
