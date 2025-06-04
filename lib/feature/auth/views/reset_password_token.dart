import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:us_connector/core/widgets/custom_button.dart';
import 'package:us_connector/core/widgets/custom_input.dart';
import 'package:us_connector/feature/auth/controllers/auth_controller.dart';
// import 'package:us_connector/core/routes/routes.dart'; // Import if you use Routes.login

class ResetPasswordToken extends GetView<AuthController> {
  const ResetPasswordToken({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.confirmPasswordController.clear();
      controller.emailController.clear();
      controller.passwordController.clear();
      controller.resetTokenError.value = null;
      controller.resetEmailError.value = null;
    });
    // Handle arguments if they exist
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null) {
      if (arguments.containsKey('email')) {
        controller.emailController.text = arguments['email'];
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Set New Password'),
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
              'Please enter the token you received, your email, and your new password.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),

        
            const SizedBox(height: 20),
            CustomInput(
              controller: controller.emailController,
              label: 'Email',
              hint: 'Enter your email address',
              type: CustomInputType.email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
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
            const SizedBox(height: 20),
            CustomInput(
              controller: controller.passwordController,
              label: 'New Password',
              hint: 'Enter your new password',
              type: CustomInputType.password,
              textInputAction: TextInputAction.next,
              errorText: controller.resetPasswordError.value,
              onChanged: (value) {
                if (value.isEmpty) {
                  controller.resetPasswordError.value = 'Password is required';
                } else if (value.length < 6) {
                  controller.resetPasswordError.value = 'Password must be at least 6 characters';
                } else {
                  controller.resetPasswordError.value = null;
                }
                // Also validate confirm password if it's not empty
                final confirmPass = controller.confirmPasswordController.text;
                if (confirmPass.isNotEmpty && confirmPass != value) {
                  controller.resetConfirmPasswordError.value = 'Passwords do not match';
                } else if (confirmPass.isNotEmpty) {
                  controller.resetConfirmPasswordError.value = null;
                }
              },
            ),
            const SizedBox(height: 20),
            CustomInput(
              controller: controller.confirmPasswordController,
              label: 'Confirm New Password',
              hint: 'Re-enter your new password',
              type: CustomInputType.password,
              textInputAction: TextInputAction.done,
              errorText: controller.resetConfirmPasswordError.value,
              onChanged: (value) {
                if (value.isEmpty) {
                  controller.resetConfirmPasswordError.value = 'Please confirm your password';
                } else if (value != controller.passwordController.text) {
                  controller.resetConfirmPasswordError.value = 'Passwords do not match';
                } else {
                  controller.resetConfirmPasswordError.value = null;
                }
              },
            ),
            const SizedBox(height: 30),
            CustomButton(
              text: 'Set New Password',
              onPressed: () {
                // Clear previous errors
           
                controller.resetEmailError.value = null;
                controller.resetPasswordError.value = null;
                controller.resetConfirmPasswordError.value = null;

                bool isValid = true;
            
                final email = controller.emailController.text;
                final password = controller.passwordController.text;
                final confirmPassword = controller.confirmPasswordController.text;

                // Validate token
            

                // Validate email
                if (email.isEmpty) {
                  controller.resetEmailError.value = 'Email is required';
                  isValid = false;
                } else if (!GetUtils.isEmail(email)) {
                  controller.resetEmailError.value = 'Please enter a valid email';
                  isValid = false;
                }

                // Validate password
                if (password.isEmpty) {
                  controller.resetPasswordError.value = 'Password is required';
                  isValid = false;
                } else if (password.length < 6) {
                  controller.resetPasswordError.value = 'Password must be at least 6 characters';
                  isValid = false;
                }

                // Validate confirm password
                if (confirmPassword.isEmpty) {
                  controller.resetConfirmPasswordError.value = 'Please confirm your password';
                  isValid = false;
                } else if (confirmPassword != password) {
                  controller.resetConfirmPasswordError.value = 'Passwords do not match';
                  isValid = false;
                }

                // If all validations pass, proceed with reset
                if (isValid) {
                  
                  Get.snackbar(
                    'Processing',
                    'Attempting to set new password. You will be redirected on success.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.orange,
                    colorText: Colors.white
                  );
                }
              },
              isLoading: controller.isLoading.value,
              isFullWidth: true,
              size: CustomButtonSize.large,
            ),
          ],
        )),
      ),
    );
  }
}
