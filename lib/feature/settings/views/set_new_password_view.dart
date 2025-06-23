import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:us_connector/core/constants/app_colors.dart';
import 'package:us_connector/core/widgets/custom_button.dart';
import 'package:us_connector/feature/settings/controller/set_new_password_controller.dart';

class SetNewPasswordView extends StatelessWidget {
  SetNewPasswordView({super.key});

  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmNewPasswordController =
      TextEditingController();
  final GlobalKey<FormState> passwordValidationKey = GlobalKey<FormState>();

  final controller = Get.put(SetNewPasswordController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Password'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Form(
                key: passwordValidationKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PasswordField(
                      controller: newPasswordController,
                      hintText: 'New Password',
                      onChanged: controller.validatePassword,
                      isVisible: controller.isPasswordVisible,
                      toggleVisibility: controller.togglePasswordVisibility,
                    ),
                    const SizedBox(height: 16),
                    PasswordField(
                      controller: confirmNewPasswordController,
                      hintText: 'Confirm New Password',
                      onChanged: (value) {
                        controller.isPasswordMatch.value =
                            confirmNewPasswordController.text ==
                            newPasswordController.text;
                        controller.validateConfirmPassword(
                          value,
                          newPasswordController.text,
                        );
                      },
                      isVisible: controller.isConfirmPasswordVisible,
                      toggleVisibility:
                          controller.toggleConfirmPasswordVisibility,
                    ),
                    const SizedBox(height: 16),
                    const PasswordRequirements(),
                  ],
                ),
              ),
              Obx(
                () => CustomButton(
                  text: 'Save Password',
                  isLoading: controller.isLoading.value,
                  onPressed: () {
                    if (passwordValidationKey.currentState!.validate()) {
                      controller.updatePassword(newPasswordController.text);
                    }
                  },
                  size: CustomButtonSize.large,
                  isFullWidth: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;
  final RxBool isVisible;
  final VoidCallback toggleVisibility;

  const PasswordField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onChanged,
    required this.isVisible,
    required this.toggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => TextFormField(
        controller: controller,
        onChanged: onChanged,
        obscureText: !isVisible.value,
        keyboardType: TextInputType.text,
        style: TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: AppColors.textTertiary),
          suffixIcon: InkWell(
            onTap: toggleVisibility,
            child: Icon(
              isVisible.value
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppColors.textTertiary,
            ),
          ),
          filled: true,
          fillColor: AppColors.surface,
        ),
      ),
    );
  }
}

class PasswordRequirements extends StatelessWidget {
  const PasswordRequirements({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SetNewPasswordController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Your Password must:'),
        _RequirementItem(
          text: 'Be 6–70 characters',
          condition: controller.isPasswordBetweenSixAndSeventy,
        ),
        _RequirementItem(
          text: 'Contain an uppercase letter',
          condition: controller.isPasswordContainsUppercase,
        ),
        _RequirementItem(
          text: 'Contain a lowercase letter',
          condition: controller.isPasswordContainsLowercase,
        ),
        _RequirementItem(
          text: 'Contain a number',
          condition: controller.isPasswordContainsNumber,
        ),
        _RequirementItem(
          text: 'Contain a special character',
          condition: controller.isPasswordContainsSpecialCharacter,
        ),
        _RequirementItem(
          text: 'Not contain your username',
          condition: controller.isPasswordNotSameAsUsername,
        ),
        _RequirementItem(
          text: 'Not match your old password',
          condition: controller.isPasswordOld,
        ),
        _RequirementItem(
          text: 'Confirm password must match',
          condition: controller.isPasswordMatch,
        ),
      ],
    );
  }
}

class _RequirementItem extends StatelessWidget {
  final String text;
  final RxBool condition;

  const _RequirementItem({required this.text, required this.condition});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        children: [
          Icon(
            condition.value ? Icons.done : Icons.circle,
            color: condition.value ? Colors.green : Colors.grey,
            size: 12,
          ),
          const SizedBox(width: 8),
          Flexible(child: Text(text)),
        ],
      ),
    );
  }
}
