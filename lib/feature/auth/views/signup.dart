import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:us_connector/core/constants/app_colors.dart';
import 'package:us_connector/core/routes/routes.dart';
import 'package:us_connector/core/widgets/custom_button.dart';
import 'package:us_connector/core/widgets/custom_input.dart';
import 'package:us_connector/core/widgets/foldable_widgets.dart';
import 'package:us_connector/feature/auth/controllers/auth_controller.dart';

class SignupView extends GetView<AuthController> {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.nameController.clear();
      controller.emailController.clear();
      controller.passwordController.clear();
      controller.confirmPasswordController.clear();
    });
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(context),
        tablet: _buildTabletLayout(context),
        desktop: _buildDesktopLayout(context),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return ResponsiveContainer(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: Responsive.heightPercent(context, 8)),
              _buildLogo(),
              const SizedBox(height: 32),
              _buildWelcomeText(),
              const SizedBox(height: 32),
              _buildSignupForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return ResponsiveContainer(
      maxWidth: 600,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: Responsive.heightPercent(context, 10)),
              _buildLogo(),
              const SizedBox(height: 32),
              _buildWelcomeText(),
              const SizedBox(height: 32),
              _buildSignupForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        // Left side - Image or Decoration
        Expanded(
          flex: 6,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              image: const DecorationImage(
                image: AssetImage('assets/images/signup_bg.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(48.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLogo(isLight: true),
                    const SizedBox(height: 24),
                    Text(
                      'Join Our Community',
                      style: TextStyle(
                        color: AppColors.textOnPrimary,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Right side - Signup Form
        Expanded(
          flex: 4,
          child: ResponsiveContainer(
            maxWidth: 480,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: Responsive.heightPercent(context, 10)),
                    _buildWelcomeText(),
                    const SizedBox(height: 32),
                    _buildSignupForm(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogo({bool isLight = false}) {
    return Image.asset(
      'assets/images/signup.png',
      height: 60,
      color: isLight ? AppColors.textOnPrimary : AppColors.primaryBlue,
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create Account',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Join us and start connecting',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildSignupForm() {
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Full Name Field
        CustomInput(
          label: 'Full Name',
          hint: 'Enter your full name',
          controller: controller.nameController,
          prefixIcon: Icon(Icons.person_outline),
          errorText: controller.nameError.value,
          onChanged: (value) {
            if (value.isEmpty) {
              controller.nameError.value = 'Full name is required';
            } else if (value.length < 2) {
              controller.nameError.value = 'Name must be at least 2 characters';
            } else {
              controller.nameError.value = null;
            }
          },
        ),
        const SizedBox(height: 16),

        // Email Field
        CustomInput(
          label: 'Email',
          hint: 'Enter your email',
          controller: controller.emailController,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icon(Icons.email_outlined),
          errorText: controller.emailError.value,
          onChanged: (value) {
            if (value.isEmpty) {
              controller.emailError.value = 'Email is required';
            } else if (!GetUtils.isEmail(value)) {
              controller.emailError.value = 'Please enter a valid email';
            } else {
              controller.emailError.value = null;
            }
          },
        ),
        const SizedBox(height: 16),
        
        // Password Field
        CustomInput(
          label: 'Password',
          hint: 'Create a password',
          controller: controller.passwordController,
          type: CustomInputType.password,
          prefixIcon: Icon(Icons.lock_outline),
          errorText: controller.passwordError.value,
          onChanged: (value) {
            if (value.isEmpty) {
              controller.passwordError.value = 'Password is required';
            } else if (value.length < 6) {
              controller.passwordError.value = 'Password must be at least 6 characters';
            } else {
              controller.passwordError.value = null;
            }
            // Also validate confirm password if it's not empty
            if (controller.confirmPasswordController.text.isNotEmpty) {
              if (value != controller.confirmPasswordController.text) {
                controller.confirmPasswordError.value = 'Passwords do not match';
              } else {
                controller.confirmPasswordError.value = null;
              }
            }
          },
        ),
        const SizedBox(height: 16),

        // Confirm Password Field
        CustomInput(
          label: 'Confirm Password',
          hint: 'Confirm your password',
          controller: controller.confirmPasswordController,
          type: CustomInputType.password,
          prefixIcon: Icon(Icons.lock_outline),
          errorText: controller.confirmPasswordError.value,
          onChanged: (value) {
            if (value.isEmpty) {
              controller.confirmPasswordError.value = 'Please confirm your password';
            } else if (value != controller.passwordController.text) {
              controller.confirmPasswordError.value = 'Passwords do not match';
            } else {
              controller.confirmPasswordError.value = null;
            }
          },
        ),
        const SizedBox(height: 24),

        // Terms and Conditions
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: controller.acceptedTerms.value,
                  onChanged: (value) {
                    controller.acceptedTerms.value = value ?? false;
                    controller.termsError.value = null;
                  },
                  activeColor: AppColors.primaryBlue,
                ),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: AppColors.textSecondary),
                      children: [
                        const TextSpan(text: 'I agree to the '),
                        TextSpan(
                          text: 'Terms of Service',
                          style: TextStyle(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: TextStyle(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (controller.termsError.value != null)
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 4),
                child: Text(
                  controller.termsError.value!,
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 24),
        
        // Sign Up Button
        CustomButton(
          text: 'Create Account',
          isLoading: controller.isLoading.value,
          onPressed: () {
            // Clear previous errors
            controller.nameError.value = null;
            controller.emailError.value = null;
            controller.passwordError.value = null;
            controller.confirmPasswordError.value = null;
            controller.termsError.value = null;

            // Validate all fields
            bool isValid = true;

            // Validate name
            if (controller.nameController.text.isEmpty) {
              controller.nameError.value = 'Full name is required';
              isValid = false;
            } else if (controller.nameController.text.length < 2) {
              controller.nameError.value = 'Name must be at least 2 characters';
              isValid = false;
            }

            // Validate email
            if (controller.emailController.text.isEmpty) {
              controller.emailError.value = 'Email is required';
              isValid = false;
            } else if (!GetUtils.isEmail(controller.emailController.text)) {
              controller.emailError.value = 'Please enter a valid email';
              isValid = false;
            }

            // Validate password
            if (controller.passwordController.text.isEmpty) {
              controller.passwordError.value = 'Password is required';
              isValid = false;
            } else if (controller.passwordController.text.length < 6) {
              controller.passwordError.value = 'Password must be at least 6 characters';
              isValid = false;
            }

            // Validate confirm password
            if (controller.confirmPasswordController.text.isEmpty) {
              controller.confirmPasswordError.value = 'Please confirm your password';
              isValid = false;
            } else if (controller.confirmPasswordController.text != controller.passwordController.text) {
              controller.confirmPasswordError.value = 'Passwords do not match';
              isValid = false;
            }

            // Validate terms acceptance
            if (!controller.acceptedTerms.value) {
              controller.termsError.value = 'Please accept the Terms and Privacy Policy';
              isValid = false;
            }

            // Only proceed with signup if all validations pass
            if (isValid) {
              controller.signUp();
            }
          },
          size: CustomButtonSize.large,
          isFullWidth: true,
        ),
        const SizedBox(height: 24),
        
        // Social Login
        // _buildSocialLogin(),
        const SizedBox(height: 24),
        
        // Login Link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Already have an account? ',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            TextButton(
              onPressed: () => Get.toNamed(Routes.login),
              child: Text(
                'Sign In',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    ));
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool isPassword = false,
    TextInputType? keyboardType,
    IconData? prefixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          style: TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.textTertiary),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: AppColors.textTertiary)
                : null,
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.neutral200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.neutral200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primaryBlue),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLogin() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: AppColors.neutral200)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Or sign up with',
                style: TextStyle(color: AppColors.textTertiary),
              ),
            ),
            Expanded(child: Divider(color: AppColors.neutral200)),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // _buildSocialButton(
            //   icon: 'assets/images/google.png',
            //   onPressed: () => controller.signupWithGoogle(),
            // ),
            // const SizedBox(width: 16),
            // _buildSocialButton(
            //   icon: 'assets/images/github_icon.png',
            //   onPressed: () => controller.signInWithGithub(),
            // ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required String icon,
    required VoidCallback onPressed,
  }) {
    // Check if it's the Github icon and use Material icon instead
    // if (icon == 'assets/images/github_icon.png') {
    //   return InkWell(
    //     onTap: onPressed,
    //     borderRadius: BorderRadius.circular(12),
    //     child: Container(
    //       padding: const EdgeInsets.all(16),
    //       decoration: BoxDecoration(
    //         border: Border.all(color: AppColors.neutral200),
    //         borderRadius: BorderRadius.circular(12),
    //       ),
    //       child: Icon(
    //         Icons.code,
    //         size: 24,
    //         color: AppColors.textPrimary,
    //       ),
    //     ),
    //   );
    // }
    
    // For other icons (like Google), use the asset image
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.neutral200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Image.asset(
          icon,
          height: 24,
          width: 24,
        ),
      ),
    );
  }
}