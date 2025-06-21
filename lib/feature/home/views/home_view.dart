import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:us_connector/core/constants/capitalize_first_letter.dart';
import 'package:us_connector/core/constants/date_format_helper.dart';
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
                  onTap: () => Get.toNamed(Routes.search),
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
                  onChanged: (value) {},
                  onSubmitted: (value) {},
                ),
              ),
              // Horizontal Services List
              HorizontalServicesList(
                services: services,
                onServiceTap: (service) async {
                  await controller.fetchQuestions(service['id']);
                },
                itemWidth: 160,
                itemHeight: 200,
                imageHeight: 120,
              ),
              _buildPlans(controller, context),
            ],
          );
        }),
      ),
    );
  }
}

Widget _buildPlans(HomeController controller, BuildContext context) {
  return Obx(() {
    final plans = controller.plansToDo;
    if (plans.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            "No plans to do yet.",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Your ${capitalizeWords(plans[0]['plan_status'])} Plans",
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: plans.length > 4 ? 4 : plans.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final plan = plans[index];
              final serviceName = capitalizeWords(plan['services']['name']);
              final planDate = DateFormatHelper().formatDate(
                plan['created_at'],
              );
              final planStatus = plan['plan_status'] ?? 'Pending';

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColorLight,
                    child: Icon(
                      Icons.event_note,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  title: Text(
                    serviceName,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: planDate.isNotEmpty
                      ? Text(
                          "Date: $planDate",
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      : null,
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: planStatus == 'active'
                          ? Color(0xFFFF9800)
                          : planStatus == 'todo'
                          ? Color(0xFF2196F3)
                          : Color(0xFF43A047),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      capitalizeWords(planStatus),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  onTap: () {
                    //    print('Taped plan $plan');
                    //Navigating to Single Plan View upon request
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  });
}
