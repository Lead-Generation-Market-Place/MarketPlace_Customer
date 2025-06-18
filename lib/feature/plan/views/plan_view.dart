import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:us_connector/core/routes/routes.dart';
import 'package:us_connector/core/widgets/bottom_navbar.dart';
import 'package:us_connector/feature/plan/controller/single_plan_controller.dart';
import 'package:us_connector/feature/plan/controller/plan_controller.dart';
import 'package:us_connector/feature/plan/widgets/pic_chart.dart';

class PlanView extends GetView<PlanController> {
  const PlanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      bottomNavigationBar: BottomNavbar(),
      body: _buildBody(context),
      floatingActionButton: _buildFloatingButton(),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Text(
        'My Plans',
        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      elevation: 1,
    );
  }

  Widget _buildBody(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return RefreshIndicator(
        onRefresh: controller.refreshPlans,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildChartSection()),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: _buildPlanListsSection(),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildChartSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 16),
      child: PlanPieChart(
        started: controller.startedPlans.length,
        inProgress: controller.inProgressPlans.length,
        done: controller.donePlans.length,
      ),
    );
  }

  Widget _buildPlanListsSection() {
    return SliverList(
      delegate: SliverChildListDelegate([
        _buildPlanStatusList(
          title: 'Started Plans',
          plans: controller.startedPlans,
          icon: Icons.access_time,
          color: Colors.orange,
        ),
        _buildPlanStatusList(
          title: 'In Progress',
          plans: controller.inProgressPlans,
          icon: Icons.autorenew,
          color: Colors.blue,
        ),
        _buildPlanStatusList(
          title: 'Completed Plans',
          plans: controller.donePlans,
          icon: Icons.check_circle,
          color: Colors.green,
        ),
      ]),
    );
  }

  Widget _buildPlanStatusList({
    required String title,
    required List<Map<String, dynamic>> plans,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Text(
                '$title (${plans.length})',
                style: Get.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (plans.isEmpty)
          _buildEmptyState(title)
        else
          ...plans.map((plan) => _buildPlanItem(plan)),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildEmptyState(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Text(
        'No $title available',
        style: Get.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
      ),
    );
  }

  Widget _buildPlanItem(Map<String, dynamic> plan) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(plan['services']['name'] ?? 'Untitled Plan'),
        subtitle: Text(
          'Created: ${_formatDate(plan['created_at'])}',
          style: Get.textTheme.bodySmall,
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _navigateToPlanDetail(plan),
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Unknown date';
    final parsed = DateTime.tryParse(date);
    return parsed != null ? parsed.toString() : 'Invalid date';
  }

  void _navigateToPlanDetail(Map<String, dynamic> plan) {
    Get.toNamed(Routes.singlePlan, arguments: plan);
  }
}

Widget _buildFloatingButton() {
  return FloatingActionButton.extended(
    icon: Icon(Icons.add),
    onPressed: () {
      SinglePlanController controller = Get.find<SinglePlanController>();
      final naveController = Get.find<BottomNavController>();
      naveController.selectedIndex.value =
          1; //changing the nav bar index to show the exact screen we are in
      controller.isNavigatedFromCreatePlan.value =
          true; // this line tells us that we actually wants to start plan because we are navigating from plan_view
      Get.toNamed(Routes.search);
    },
    label: Text('Create Plan'),
  );
}
