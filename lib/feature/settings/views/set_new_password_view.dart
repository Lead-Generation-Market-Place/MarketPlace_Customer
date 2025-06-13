import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:us_connector/core/constants/app_colors.dart';
import 'package:us_connector/core/widgets/custom_button.dart';
import 'package:us_connector/feature/settings/controller/set_new_password_controller.dart';

class SetNewPasswordView extends GetView<SetNewPasswordController> {
  SetNewPasswordView({super.key});
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> passwordValidationKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Set Password'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 16.0,
            left: 16.0,
            right: 16.0,
            bottom: 0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(//Text Field for New password
                    newPasswordFormKey: passwordValidationKey,
                    label: 'New Password',
                    hint: '',
                    controller: passwordController,
                    type: null,
                  ),
                  SizedBox(height: 16),
                  _passwordRequirements(),   //Password requirements
                ],
              ),
              Obx(
                () => CustomButton(  //Button to save the new password
                  text: 'Save Password',
                  isLoading: controller.isLoading.value,
                  onPressed: () {
                    if (passwordValidationKey.currentState!.validate()) {
                      controller.updatePassword(passwordController.text);
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

Widget _buildTextField({
  required String label,
  required String hint,
  required TextEditingController controller,
  bool isPassword = false,
  TextInputType? keyboardType,
  required type,
  required GlobalKey<FormState> newPasswordFormKey,
}) {
  var isPasswordController = Get.put(SetNewPasswordController());
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
      Form(
        key: newPasswordFormKey,
        child: Obx(() {
          return TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'This field cannot be empty';
              } else if (value.length < 6 || value.length > 70) {
                return 'Password must be at least 6 characters and not maximum 70';
              }

              return null;
            },
            controller: controller,
            obscureText: isPasswordController.isPasswordVisible.value,
            keyboardType: keyboardType,
            style: TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: AppColors.textTertiary),
              suffixIcon: InkWell(
                onTap: () {
                  isPasswordController.isPasswordVisible.value =
                      !isPasswordController.isPasswordVisible.value;
                },
                child: Obx(
                  () => _showHidePasswordIcon(
                    isPasswordController.isPasswordVisible.value,
                  ),
                ),
              ),
              filled: true,
              fillColor: AppColors.surface,
            ),
          );
        }),
      ),
    ],
  );
}

_showHidePasswordIcon(bool isPasswordVisible) {
  return isPasswordVisible
      ? Icon(Icons.visibility_off_outlined, color: AppColors.textTertiary)
      : Icon(Icons.visibility_outlined, color: AppColors.textTertiary);
}

_passwordRequirements() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Your Password must:'),
      _bulletListItem('Be at least 6 characters short and 70 characters long'),
      _bulletListItem('not contain your username or parts of your username'),
      _bulletListItem('not contain easily guessable information'),
    ],
  );
}

_bulletListItem(String text) {
  return Row(
    children: [
      Container(
        margin: const EdgeInsets.all(8.0),
        height: 5,
        width: 5,
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey),
      ),
      Text(text),
    ],
  );
}
