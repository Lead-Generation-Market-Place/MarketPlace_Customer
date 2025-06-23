import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:us_connector/core/constants/app_colors.dart';
import 'package:us_connector/core/widgets/custom_button.dart';
import 'package:us_connector/feature/settings/controller/set_new_password_controller.dart';

class SetNewPasswordView extends GetView<SetNewPasswordController> {
  SetNewPasswordView({super.key});
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmNewPasswordController =
      TextEditingController();
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
                  Form(
                    key: passwordValidationKey,
                    child: Column(
                      children: [
                        _textFormField(newPasswordController, 'New Password'),
                        const SizedBox(height: 16),
                        _confirmPasswordFormField(
                          confirmNewPasswordController,
                          'Confirm New Password',
                          newPasswordController,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  _passwordRequirements(), //Password requirements
                ],
              ),
              Obx(
                () => CustomButton(
                  //Button to save the new password
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

Widget _textFormField(
  TextEditingController passwordController,
  String hintText,
) {
  var isPasswordController = Get.put(SetNewPasswordController());
  return Obx(
    () => SizedBox(
      child: TextFormField(
        onChanged: (value) {
          if (passwordController.text.length >= 6 &&
              passwordController.text.length <= 70) {
            isPasswordController.isPasswordBetweenSixAndSeventy.value = true;
          } else {
            isPasswordController.isPasswordBetweenSixAndSeventy.value = false;
          }
          if (passwordController.text.contains(RegExp(r'[A-Z]'))) {
            isPasswordController.isPasswordContainsUppercase.value = true;
          } else {
            isPasswordController.isPasswordContainsUppercase.value = false;
          }
          if (passwordController.text.contains(RegExp(r'[a-z]'))) {
            isPasswordController.isPasswordContainsLowercase.value = true;
          } else {
            isPasswordController.isPasswordContainsLowercase.value = false;
          }
          if (passwordController.text.contains(RegExp(r'[0-9]'))) {
            isPasswordController.isPasswordContainsNumber.value = true;
          } else {
            isPasswordController.isPasswordContainsNumber.value = false;
          }
          if (passwordController.text.contains(
            RegExp(r'[!@#$%^&*(),.?":{}|<>]'),
          )) {
            isPasswordController.isPasswordContainsSpecialCharacter.value =
                true;
          } else {
            isPasswordController.isPasswordContainsSpecialCharacter.value =
                false;
          }
          isPasswordController.checkOldPassword(passwordController.text);
          isPasswordController.checkUserName(passwordController.text);
        },

        controller: passwordController,
        obscureText: isPasswordController.isPasswordVisible.value,
        keyboardType: TextInputType.text,
        style: TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: AppColors.textTertiary),
          suffixIcon: InkWell(
            onTap: () {
              isPasswordController.isPasswordVisible.value =
                  !isPasswordController.isPasswordVisible.value;
            },
            child: _showHidePasswordIcon(
              isPasswordController.isPasswordVisible.value,
            ),
          ),
          filled: true,
          fillColor: AppColors.surface,
        ),
      ),
    ),
  );
}

Widget _confirmPasswordFormField(
  TextEditingController confirmController,
  String hintText,
  TextEditingController originalController,
) {
  var isPasswordController = Get.put(SetNewPasswordController());
  return SizedBox(
    child: Obx(
      () => TextFormField(
        onChanged: (value) {
          if (confirmController.text == originalController.text) {
            isPasswordController.isPasswordMatch.value = true;
          } else {
            isPasswordController.isPasswordMatch.value = false;
          }
        },
        controller: confirmController,
        obscureText: isPasswordController.isConfirmPasswordVisible.value,
        keyboardType: TextInputType.text,
        style: TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: AppColors.textTertiary),
          suffixIcon: InkWell(
            onTap: () {
              isPasswordController.isConfirmPasswordVisible.value =
                  !isPasswordController.isConfirmPasswordVisible.value;
            },
            child: _showHidePasswordIcon(
              isPasswordController.isConfirmPasswordVisible.value,
            ),
          ),
          filled: true,
          fillColor: AppColors.surface,
        ),
      ),
    ),
  );
}

_passwordRequirements() {
  final controller = Get.find<SetNewPasswordController>();
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Your Password must:'),
      _bulletListItem(
        'Be at least 6 characters short and 70 characters long',
        controller.isPasswordBetweenSixAndSeventy,
      ),
      _bulletListItem(
        'Contain an uppercase letter',
        controller.isPasswordContainsUppercase,
      ),
      _bulletListItem(
        'Contain a lowercase letter',
        controller.isPasswordContainsLowercase,
      ),
      _bulletListItem('Contain a number', controller.isPasswordContainsNumber),
      _bulletListItem(
        'Contain a special character',
        controller.isPasswordContainsSpecialCharacter,
      ),
      _bulletListItem(
        'Not contain your username or parts of your username',
        controller
            .isPasswordNotSameAsUsername, // You can implement this logic as needed
      ),
      _bulletListItem(
        'Not match with your old password',
        controller.isPasswordOld, // You can implement this logic as needed
      ),
      _bulletListItem(
        'Confirm Password must match',
        controller.isPasswordMatch, // You can implement this logic as needed
      ),
    ],
  );
}

Widget _bulletListItem(String text, RxBool? isMet) {
  return Row(
    children: [
      SizedBox(
        height: 12,
        width: 12,
        child: isMet == null
            ? Container(
                margin: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey,
                ),
              )
            : Obx(
                () => isMet.value
                    ? Icon(Icons.done, color: Colors.green, size: 12.0)
                    : Container(
                        margin: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey,
                        ),
                      ),
              ),
      ),
      const SizedBox(width: 8),
      Flexible(child: Text(text)),
    ],
  );
}

_showHidePasswordIcon(bool isPasswordVisible) {
  return isPasswordVisible
      ? Icon(Icons.visibility_off_outlined, color: AppColors.textTertiary)
      : Icon(Icons.visibility_outlined, color: AppColors.textTertiary);
}

_showHideConfirmPasswordIcon(bool isPasswordVisible) {
  return isPasswordVisible
      ? Icon(Icons.visibility_off_outlined, color: AppColors.textTertiary)
      : Icon(Icons.visibility_outlined, color: AppColors.textTertiary);
}
