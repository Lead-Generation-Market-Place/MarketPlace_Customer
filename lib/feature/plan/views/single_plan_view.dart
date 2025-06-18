import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:us_connector/core/constants/file_urls.dart';
import 'package:us_connector/core/routes/routes.dart';
import 'package:us_connector/feature/plan/controller/single_plan_controller.dart';

class SinglePlanView extends StatefulWidget {
  const SinglePlanView({super.key});

  @override
  State<SinglePlanView> createState() => _SinglePlanViewState();
}

class _SinglePlanViewState extends State<SinglePlanView> {
  final SinglePlanController controller = Get.find();
  late final Map<String, dynamic> plan;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is Map<String, dynamic> && args.containsKey('service_id')) {
      plan = args;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.getPlan(plan['service_id']);
      });
    } else {
      Get.snackbar('Error', 'Invalid navigation arguments.');
      plan = {}; // fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Get.toNamed(Routes.plan)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(200),
          child: Obx(
            () => controller.isLoading.value
                ? const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator.adaptive()),
                  )
                : _buildImage(),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Obx(
          () => controller.isLoading.value
              ? const Center(child: CircularProgressIndicator.adaptive())
              : _buildCard(),
        ),
      ),
    );
  }

  Widget _buildCard() {
    final service = controller.selectedService;
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          service.isEmpty
              ? 'No service details available.'
              : service.toString(),
        ),
      ),
    );
  }

  Widget _buildImage() {
    final imageUrl = controller.selectedService['service_image_url'];
    if (imageUrl == null || imageUrl.toString().isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Icon(Icons.broken_image, size: 40)),
      );
    }

    return Image.network(
      '${FileUrls.servicesLogos}$imageUrl',
      height: 200,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 200,
          color: Colors.grey[300],
          child: const Center(
            child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
          ),
        );
      },
    );
  }
}
