import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:us_connector/core/constants/file_urls.dart';
import 'package:us_connector/core/constants/screen_size.dart';
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
      plan = {};
      Get.snackbar('Error', 'Invalid navigation arguments.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Obx(
          () => controller.isLoading.value
              ? const Center(child: CircularProgressIndicator.adaptive())
              : _buildServiceCard(context),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: true,
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(ScreenSize().getHeight(context) / 5),
        child: Obx(
          () => controller.isLoading.value
              ? const SizedBox(
                  height: 10,
                  child: Center(child: CircularProgressIndicator.adaptive()),
                )
              : _buildImage(context),
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    final imageUrl = controller.selectedService['service_image_url'];
    final height = ScreenSize().getHeight(context) / 4.5;

    if (imageUrl == null || imageUrl.toString().isEmpty) {
      return _buildImagePlaceholder(height);
    }

    return Image.network(
      '${FileUrls.servicesLogos}$imageUrl',
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildImagePlaceholder(height),
    );
  }

  Widget _buildImagePlaceholder(double height) {
    return Container(
      height: height,
      color: Colors.grey[300],
      child: const Center(
        child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context) {
    Map<dynamic, dynamic> service = controller.selectedService.value;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: service.isEmpty
            ? const Text('No service details available.')
            : _buildServiceDetails(service.cast<String, dynamic>(), context),
      ),
    );
  }

  Widget _buildServiceDetails(
    Map<String, dynamic> service,
    BuildContext context,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ListTile(
          title: Text(service['name'] ?? ""),
          titleTextStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              service['description'] ?? "",
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildPlanActions(service),
      ],
    );
  }

  Widget _buildPlanActions(Map<String, dynamic> service) {
    final status = service['plan_status'];
    if (status == 'todo') {
      return _buildProgressPlanButtons(service);
    }
    return _buildStartedPlanButtons(service);
  }

  Widget _buildProgressPlanButtons(Map<String, dynamic> service) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () => print('Request a Call: $service'),
          child: const Text('Request a Call'),
        ),
        ElevatedButton(
          onPressed: () => print('Message: $service'),
          child: const Text('Message'),
        ),
      ],
    );
  }

  Widget _buildStartedPlanButtons(Map<String, dynamic> service) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () => print('Remove: $service'),
          child: const Text('Remove'),
        ),
        ElevatedButton(
          onPressed: () => print('Next: $service'),
          child: const Text('Next'),
        ),
      ],
    );
  }
}
