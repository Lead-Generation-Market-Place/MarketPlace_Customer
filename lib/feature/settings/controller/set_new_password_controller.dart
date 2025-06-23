import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SetNewPasswordController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;
  final RxBool isPasswordBetweenSixAndSeventy = false.obs;
  final RxBool isPasswordContainsUppercase = false.obs;
  final RxBool isPasswordContainsLowercase = false.obs;
  final RxBool isPasswordContainsNumber = false.obs;
  final RxBool isPasswordContainsSpecialCharacter = false.obs;
  final RxBool isPasswordMatch = false.obs;
  final RxBool isPasswordNotSameAsUsername = false.obs;
  final RxBool isPasswordOld = false.obs;

  Future<void> updatePassword(String newPassword) async {
    final supabase = Supabase.instance.client;
    isLoading.value = true;
    try {
      final user = supabase.auth.currentUser;
      final session = supabase.auth.currentSession;
      if (user?.userMetadata!['username'] == newPassword) {
        throw Exception('New password cannot be the same as the username');
      }
      if (user?.email != null && session != null) {
        //Check Conditions
        if (isPasswordBetweenSixAndSeventy.value == false ||
            isPasswordContainsUppercase.value == false ||
            isPasswordContainsLowercase.value == false ||
            isPasswordContainsNumber.value == false ||
            isPasswordContainsSpecialCharacter.value == false ||
            isPasswordMatch.value == false ||
            isPasswordOld.value == false ||
            isPasswordNotSameAsUsername.value == false) {
          throw Exception('Password does not meet the required conditions');
        }
        final response = await supabase.auth.updateUser(
          UserAttributes(password: newPassword),
        );
        if (response.user == null) {
          throw Exception('Failed to update password');
        }
        Get.back();
        Get.snackbar('Success', 'Password updated successfully');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> checkOldPassword(String oldPassword) async {
    final supabase = Supabase.instance.client;
    try {
      final user = supabase.auth.currentUser;

      final response = await supabase.auth.signInWithPassword(
        email: user!.email,
        password: oldPassword,
      );
      if (response.user != null) {
        isPasswordOld.value = false;
      }
      if (response.user == null) {
        isPasswordOld.value = true;
      }
    } catch (e) {
      isPasswordOld.value = true;
    }
  }

  Future<void> checkUserName(String password) async {
    final supabase = Supabase.instance.client;
    try {
      final user = supabase.auth.currentUser;
      if (user?.userMetadata?['username'] == password) {
        isPasswordNotSameAsUsername.value = false;
        print('user name matched');
      } else {
        isPasswordNotSameAsUsername.value = true;
      }
    } catch (e) {
      isPasswordNotSameAsUsername.value = false;
      print('Error checking User name: $e');
    }
  }
}
