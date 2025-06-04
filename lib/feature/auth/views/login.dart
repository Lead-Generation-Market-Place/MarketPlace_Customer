import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:us_connector/core/constants/app_colors.dart';
import 'package:us_connector/core/routes/routes.dart';
import 'package:us_connector/core/widgets/custom_button.dart';
import 'package:us_connector/core/widgets/custom_input.dart';
import 'package:us_connector/core/widgets/foldable_widgets.dart';
import 'package:us_connector/feature/auth/controllers/auth_controller.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.emailController.clear();
      controller.passwordController.clear();
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
              SizedBox(height: Responsive.heightPercent(context, 10)),
              _buildLogo(),
              const SizedBox(height: 48),
              _buildWelcomeText(),
              const SizedBox(height: 32),
              _buildLoginForm(),
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
              SizedBox(height: Responsive.heightPercent(context, 15)),
              _buildLogo(),
              const SizedBox(height: 48),
              _buildWelcomeText(),
              const SizedBox(height: 32),
              _buildLoginForm(),
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
                image: AssetImage('assets/images/login_bg.png'),
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
                      'Connect with US',
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
        // Right side - Login Form
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
                    SizedBox(height: Responsive.heightPercent(context, 15)),
                    _buildWelcomeText(),
                    const SizedBox(height: 32),
                    _buildLoginForm(),
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
      'assets/images/login.png',
      height: 60,
      color: isLight ? AppColors.textOnPrimary : AppColors.primaryBlue,
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome Back',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to continue',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
            hint: 'Enter your password',
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
            },
          ),
          const SizedBox(height: 8),

          // Forgot Password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => {Get.toNamed(Routes.resetPassword)},
              child: Text(
                'Forgot Password?',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Login Button
          CustomButton(
            text: 'Sign In',
            isLoading: controller.isLoading.value,
            onPressed: () {
              // Clear any previous errors
              controller.emailError.value = null;
              controller.passwordError.value = null;

              // Validate before login
              bool isValid = true;
              
              final email = controller.emailController.text;
              if (email.isEmpty) {
                controller.emailError.value = 'Email is required';
                isValid = false;
              } else if (!GetUtils.isEmail(email)) {
                controller.emailError.value = 'Please enter a valid email';
                isValid = false;
              }

              final password = controller.passwordController.text;
              if (password.isEmpty) {
                controller.passwordError.value = 'Password is required';
                isValid = false;
              } else if (password.length < 6) {
                controller.passwordError.value = 'Password must be at least 6 characters';
                isValid = false;
              }

              // Only proceed with login if validation passes
              if (isValid) {
                controller.login();
              }
            },
            size: CustomButtonSize.large,
            isFullWidth: true,
          ),
          const SizedBox(height: 24),

          // Social Login
          _buildSocialLogin(),
          const SizedBox(height: 24),

          // Register Link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Don\'t have an account? ',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              TextButton(
                onPressed: () => controller.goToSignup(),
                child: Text(
                  'Register',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool isPassword = false,
    TextInputType? keyboardType,
    IconData? prefixIcon, required type,
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
                'Or continue with',
                style: TextStyle(color: AppColors.textTertiary),
              ),
            ),
            Expanded(child: Divider(color: AppColors.neutral200)),
          ],
        ),
        const SizedBox(height: 24),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildSocialButton(
              icon: 'assets/images/google.png',
              onPressed: () => controller.signInWithGoogle(),
            ),

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
    // Check if it's the Apple icon and use Material icon instead
    if (icon == 'assets/icons/apple.png') {
      return InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.neutral200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.apple, size: 24, color: AppColors.textPrimary),
        ),
      );
    }

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
        child: Image.asset(icon, height: 24, width: 24),
      ),
    );
  }
}
