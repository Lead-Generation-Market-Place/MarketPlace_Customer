import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:us_connector/core/routes/routes.dart';
import 'package:us_connector/core/widgets/bottom_navbar.dart';
import 'package:us_connector/feature/home/controllers/home_controller.dart';
import 'package:us_connector/feature/home/widgets/horizontal_services_list.dart';

class HomeView extends GetView<HomeController> {
  HomeView({super.key});
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavbar(),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final services = controller.services;

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              // AppBar and Search
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Let's get started",
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.person_outline),
                      onPressed: () => Get.toNamed(Routes.settings),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "What do you need help with?",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  onChanged: (value) {
                    // Optional: debounce or search filter
                    print("Search: $value");
                  },
                  onSubmitted: (value) {
                    print("Search submitted: $value");
                  },
                ),
              ),
              // Horizontal Services List
              HorizontalServicesList(
                services: services,
                onServiceTap: (service) async {
                  await controller.fetchQuestions(service['id']);
                  print('Tapped: ${service['name']}');
                },
                itemWidth: 160,
                itemHeight: 200,
                imageHeight: 120,
              ),
            
            ],
          );
        }),
      ),
    );
  }
}
