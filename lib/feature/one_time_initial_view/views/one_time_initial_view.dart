import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart' show Lottie;
import 'package:us_connector/core/routes/routes.dart';
import 'package:us_connector/core/widgets/foldable_widgets.dart';
import 'package:us_connector/feature/one_time_initial_view/controllers/one_time_initial_controller.dart';


class OneTimeInitialView extends GetView<OneTimeInitialController> {
  const OneTimeInitialView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: controller.pageController,
        onPageChanged: controller.onPageChanged,
        children: [
          _buildWelcomePage(context),
          _buildGuidesPage(context),
          _buildRemindersPage(context),
          _buildProsPage(context),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildWelcomePage(BuildContext context) {
    return ResponsiveContainer(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Lottie.asset(
                'assets/lottie/splash1.json',
                fit: BoxFit.contain,
                width: Responsive.isMobile(context) ? Responsive.widthPercent(context, 80) : Responsive.widthPercent(context, 50),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Caring for your home, made easy.',
              style: Get.textTheme.headlineMedium?.copyWith(
                fontSize: ResponsiveValue<double>(
                  mobile: 24,
                  tablet: 28,
                  desktop: 32,
                ).get(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: ResponsiveValue<double>(
                mobile: double.infinity,
                tablet: 400,
                desktop: 500,
              ).get(context),
             
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuidesPage(BuildContext context) {
    return ResponsiveContainer(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/lottie/splash2.json',
              height: ResponsiveValue<double>(
                mobile: 200,
                tablet: 250,
                desktop: 300,
              ).get(context),
              width: Responsive.isMobile(context) ? Responsive.widthPercent(context, 80) : Responsive.widthPercent(context, 50),
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 32),
            Text(
              'Generate custom guides, made for your home.',
              style: Get.textTheme.headlineMedium?.copyWith(
                fontSize: ResponsiveValue<double>(
                  mobile: 24,
                  tablet: 28,
                  desktop: 32,
                ).get(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemindersPage(BuildContext context) {
    return ResponsiveContainer(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/lottie/splash3.json',
              height: ResponsiveValue<double>(
                mobile: 200,
                tablet: 250,
                desktop: 300,
              ).get(context),
              width: Responsive.isMobile(context) ? Responsive.widthPercent(context, 80) : Responsive.widthPercent(context, 50),
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 32),
            Text(
              'We\'ll help you stay on track with reminders.',
              style: Get.textTheme.headlineMedium?.copyWith(
                fontSize: ResponsiveValue<double>(
                  mobile: 24,
                  tablet: 28,
                  desktop: 32,
                ).get(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProsPage(BuildContext context) {
    return ResponsiveContainer(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Lottie.asset(
                'assets/lottie/splash4.json',
                fit: BoxFit.contain,
                width: Responsive.isMobile(context) ? Responsive.widthPercent(context, 80) : Responsive.widthPercent(context, 50),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Find nearby pros who can help get things done.',
              style: Get.textTheme.headlineMedium?.copyWith(
                fontSize: ResponsiveValue<double>(
                  mobile: 24,
                  tablet: 28,
                  desktop: 32,
                ).get(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: ResponsiveValue<double>(
                mobile: double.infinity,
                tablet: 400,
                desktop: 500,
              ).get(context),
           
        
              
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Obx(() => Padding(
      padding: ResponsiveValue<EdgeInsets>(
        mobile: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        tablet: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        desktop: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20.0),
      ).get(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () => controller.skipOnboarding(),
            child: Text(
              'Skip',
              style: TextStyle(
                fontSize: ResponsiveValue<double>(
                  mobile: 14,
                  tablet: 16,
                  desktop: 18,
                ).get(context),
              ),
            ),
          ),
          Row(
            children: List.generate(4, (index) => _buildDot(index, context)),
          ),
          controller.currentPage.value == 3
              ? ElevatedButton(
                  onPressed: () => controller.finishOnboarding(),
                  style: ElevatedButton.styleFrom(
                    padding: ResponsiveValue<EdgeInsets>(
                      mobile: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      tablet: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      desktop: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    ).get(context),
                  ),
                  child: Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: ResponsiveValue<double>(
                        mobile: 14,
                        tablet: 16,
                        desktop: 18,
                      ).get(context),
                    ),
                  ),
                )
              : TextButton(
                  onPressed: controller.nextPage,
                  child: Text(
                    'Next',
                    style: TextStyle(
                      fontSize: ResponsiveValue<double>(
                        mobile: 14,
                        tablet: 16,
                        desktop: 18,
                      ).get(context),
                      color: Get.theme.primaryColor,
                    ),
                  ),
                ),
        ],
      ),
    ));
  }

  Widget _buildDot(int index, BuildContext context) {
    return Obx(() => Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: ResponsiveValue<double>(
        mobile: 8,
        tablet: 10,
        desktop: 12,
      ).get(context),
      height: ResponsiveValue<double>(
        mobile: 8,
        tablet: 10,
        desktop: 12,
      ).get(context),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: controller.currentPage.value == index
            ? Get.theme.primaryColor
            : Colors.grey[400],
      ),
    ));
  }
}