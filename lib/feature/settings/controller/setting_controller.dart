import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:us_connector/feature/auth/controllers/auth_controller.dart';
import 'package:us_connector/main.dart';
import 'dart:io';

class SettingsController extends GetxController {
  final AuthController authController = Get.put(AuthController());
  var isLoading = false.obs;

  Future<void> updateProfileImage(File imageFile) async {
    try {
      isLoading.value = true;
      
      // Get the current user's email
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Upload image to Supabase Storage
      final fileName = '${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final response = await supabase.storage
          .from('userprofilepicture')
          .upload(fileName, imageFile);

      // Get the public URL of the uploaded image
      final imageUrl = supabase.storage
          .from('userprofilepicture')
          .getPublicUrl(fileName);

      // Update the user's profile in the database
      await supabase
          .from('users_profiles')
          .update({'profile_picture_url': fileName})
          .eq('email', authController.email);

      // Update the local state
      authController.profilePictureUrl.value = fileName;
      
      Get.snackbar(
        'Success',
        'Profile picture updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Logger().e('Error updating profile image: $e');
      Get.snackbar(
        'Error',
        'Failed to update profile picture',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  

}