import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SetNewPasswordController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;

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
}
