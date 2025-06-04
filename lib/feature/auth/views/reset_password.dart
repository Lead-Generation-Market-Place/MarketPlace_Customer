import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:us_connector/core/routes/routes.dart';
import 'package:us_connector/core/widgets/custom_button.dart';
import 'package:us_connector/core/widgets/custom_input.dart';
import 'package:us_connector/feature/auth/controllers/auth_controller.dart';

class ResetPassword extends GetView<AuthController> {
  const ResetPassword({super.key});

  @override
  Widget build(BuildContext context) {
    final showMessage = false.obs;
    
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.emailController.clear();
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Obx(() => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'Enter your email address to receive a password reset link.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            CustomInput(
              controller: controller.emailController,
              label: 'Email',
              hint: 'Enter your email',
              type: CustomInputType.email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              errorText: controller.resetEmailError.value,
              onChanged: (value) {
                if (value.isEmpty) {
                  controller.resetEmailError.value = 'Email is required';
                } else if (!GetUtils.isEmail(value)) {
                  controller.resetEmailError.value = 'Please enter a valid email';
                } else {
                  controller.resetEmailError.value = null;
                }
              },
            ),

            // const SizedBox(height: 15),
            // TextButton(
            //   onPressed: () {
            //     Get.toNamed(Routes.resetPasswordToken);
            //   },
            //   child: const Text(
            //     'I have received the reset link and have the token.',
            //     textAlign: TextAlign.center,
            //     style: TextStyle(fontSize: 12),
            //   ),
            // ),
            const SizedBox(height: 30),

            CustomButton(
              text: 'Send Reset Link',
              onPressed: () {
                final email = controller.emailController.text;
                
                // Clear previous errore
                controller.resetEmailError.value = null;

                // Validate email
                if (email.isEmpty) {
                  controller.resetEmailError.value = 'Email is required';
                  return;
                }
                if (!GetUtils.isEmail(email)) {
                  controller.resetEmailError.value = 'Please enter a valid email';
                  return;
                }

                // If validation passes, proceed with reset
                controller.resetPassword(email);
                showMessage.value = true;
              },
              isLoading: controller.isLoading.value,
              isFullWidth: true,
              size: CustomButtonSize.large,
            ),
            const SizedBox(height: 20),
            Obx(() => (!showMessage.value || controller.isLoading.value)
              ? const SizedBox.shrink()
              : const Text(
                  'If an account exists with this email, you will receive a password reset link shortly.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
            ),
          ],
        )),
      ),
    );
  }
}