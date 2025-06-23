import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SetNewPasswordController extends GetxController {
  final isLoading = false.obs;

  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;

  // Validation flags
  final isPasswordBetweenSixAndSeventy = false.obs;
  final isPasswordContainsUppercase = false.obs;
  final isPasswordContainsLowercase = false.obs;
  final isPasswordContainsNumber = false.obs;
  final isPasswordContainsSpecialCharacter = false.obs;
  final isPasswordMatch = false.obs;
  final isPasswordNotSameAsUsername = false.obs;
  final isPasswordOld = false.obs;

  final supabase = Supabase.instance.client;

  // Toggle password visibility
  void togglePasswordVisibility() => isPasswordVisible.toggle();
  void toggleConfirmPasswordVisibility() => isConfirmPasswordVisible.toggle();

  // Validate input fields in one place
  void validatePassword(String password) {
    isPasswordBetweenSixAndSeventy.value =
        password.length >= 6 && password.length <= 70;
    isPasswordContainsUppercase.value = RegExp(r'[A-Z]').hasMatch(password);
    isPasswordContainsLowercase.value = RegExp(r'[a-z]').hasMatch(password);
    isPasswordContainsNumber.value = RegExp(r'\d').hasMatch(password);
    isPasswordContainsSpecialCharacter.value = RegExp(
      r'[!@#$%^&*(),.?":{}|<>]',
    ).hasMatch(password);

    checkUserName(password);
    checkOldPassword(password);
  }

  // Check if password contains username
  void checkUserName(String password) {
    final username = supabase.auth.currentUser?.userMetadata?['username'];
    isPasswordNotSameAsUsername.value =
        username == null || !password.contains(username);
  }

  // Check if the new password is not the same as the current one
  void checkOldPassword(String password) {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    // WARNING: This is just a simulation.
    // In production, avoid re-authenticating like this for password comparison.
    supabase.auth
        .signInWithPassword(email: user.email!, password: password)
        .then((response) {
          isPasswordOld.value = response.user == null;
        })
        .catchError((_) {
          isPasswordOld.value = true;
        });
  }

  // Submit password update
  Future<void> updatePassword(String newPassword) async {
    isLoading.value = true;
    final user = supabase.auth.currentUser;

    try {
      if (user == null) throw Exception('User not authenticated');

      // Check all validation flags
      if (!isPasswordBetweenSixAndSeventy.value ||
          !isPasswordContainsUppercase.value ||
          !isPasswordContainsLowercase.value ||
          !isPasswordContainsNumber.value ||
          !isPasswordContainsSpecialCharacter.value ||
          !isPasswordMatch.value ||
          !isPasswordNotSameAsUsername.value ||
          !isPasswordOld.value) {
        throw Exception('Password does not meet the required conditions');
      }

      final response = await supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      if (response.user == null) throw Exception('Failed to update password');

      Get.back();
      Get.snackbar('Success', 'Password updated successfully');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void validateConfirmPassword(
    String confirmPassword,
    String originalPassword,
  ) {
    isPasswordMatch.value = confirmPassword == originalPassword;
  }
}
