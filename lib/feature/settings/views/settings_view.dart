import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/web.dart';
import 'package:us_connector/core/constants/file_urls.dart';
import 'package:us_connector/core/routes/routes.dart';
import 'package:us_connector/feature/auth/controllers/auth_controller.dart';
import 'package:us_connector/core/widgets/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:us_connector/feature/settings/controller/setting_controller.dart';
import 'package:us_connector/main.dart';

class SettingsView extends GetView<SettingsController> {
  final AuthController authController = Get.put(AuthController());
  SettingsView({super.key}){
    authController.loadUserData();
  }

  Future<bool> _handlePermission(ImageSource source) async {
    if (source == ImageSource.camera) {
      final status = await Permission.camera.status;
      if (status.isPermanentlyDenied) {
        await _showPermissionDialog(
          'Camera Permission Required',
          'Camera access is required to take photos. Please enable it in your device settings.',
          Permission.camera,
        );
        return false;
      }

      final result = await Permission.camera.request();
      if (result.isDenied) {
        Get.snackbar(
          'Permission Required',
          'Camera permission is required to take photos',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } else {
      // For gallery access
      if (Platform.isAndroid) {
        // On Android, we need storage permission
        final status = await Permission.storage.status;
        if (status.isPermanentlyDenied) {
          await _showPermissionDialog(
            'Storage Permission Required',
            'Storage access is required to select images. Please enable it in your device settings.',
            Permission.storage,
          );
          return false;
        }

        final result = await Permission.storage.request();
        if (result.isDenied) {
          Get.snackbar(
            'Permission Required',
            'Storage permission is required to select images',
            snackPosition: SnackPosition.BOTTOM,
          );
          return false;
        }
      } else if (Platform.isIOS) {
        // On iOS, we need photos permission
        final status = await Permission.photos.status;
        if (status.isPermanentlyDenied) {
          await _showPermissionDialog(
            'Photos Permission Required',
            'Photos access is required to select images. Please enable it in your device settings.',
            Permission.photos,
          );
          return false;
        }

        final result = await Permission.photos.request();
        if (result.isDenied) {
          Get.snackbar(
            'Permission Required',
            'Photos permission is required to select images',
            snackPosition: SnackPosition.BOTTOM,
          );
          return false;
        }
      }
    }

    return true;
  }

  Future<void> _showPermissionDialog(
    String title,
    String message,
    Permission permission,
  ) async {
    await Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _showImagePickerBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () async {
                  Navigator.pop(context);
                  if (await _handlePermission(ImageSource.camera)) {
                    final file = await ImagePickerService().pickFromCamera();
                    if (file != null) {
                      // TODO: Handle the picked image file
                      // You can upload it to your server or update the profile picture
                      controller.updateProfileImage(file);
                      Logger().d(file);
                      Get.snackbar('Success', 'Image captured successfully');
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  if (await _handlePermission(ImageSource.gallery)) {
                    final file = await ImagePickerService().pickFromGallery();
                    if (file != null) {
                      Logger().d(file);
                      // TODO: Handle the picked image file
                      // You can upload it to your server or update the profile picture
                      controller.updateProfileImage(file);
                      Get.snackbar('Success', 'Image selected successfully');
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget build(BuildContext context) {


    // ThemeData for easy access to theme properties
    final theme = Theme.of(context);
    final imageUrl = authController.profilePictureUrl.value ?? '';
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // TODO: Implement back navigation if needed, or remove if handled by GetX routing
            if (Get.key.currentState?.canPop() ?? false) {
              Get.back();
            }
          },
        ),
        title: const Text('You'),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0, // Remove shadow to match the image
        iconTheme: IconThemeData(
          color: theme.textTheme.bodyLarge?.color,
        ), // Match icon color with text
        titleTextStyle: theme.textTheme.titleLarge?.copyWith(
          fontWeight:
              FontWeight.bold, // Making title bold as per common UI practices
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              // Outer ListView to ensure the entire page is scrollable if content exceeds screen height
              children: <Widget>[
                const SizedBox(height: 20),
                // User Profile Section
                Column(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () => _showImagePickerBottomSheet(context),
                      child: Obx(() {
                        final hasImage = authController.profilePictureUrl.value.isNotEmpty;
                        return CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey,
                          backgroundImage: hasImage
                              ? NetworkImage('${FileUrls.profilePicture}$imageUrl')
                              : null,
                          child: !hasImage
                              ? const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.white,
                                )
                              : null,
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    Obx(
                      () => Text(
                        authController.name.value,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Obx(
                      () => Text(
                        authController.email.value,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30), // Spacing before the list items
                // Settings List - Individual Widgets
                ListTile(
                  title: const Text('Set password'),
                  onTap: () {
                    // TODO: Implement navigation or action
                    Get.snackbar('Selected', 'Tapped on Set password');
                  },
                ),
                const Divider(height: 1, indent: 16, endIndent: 0),
                ListTile(
                  title: const Text('Notification settings'),
                  onTap: () {
                    // TODO: Implement navigation or action
                    Get.snackbar('Selected', 'Tapped on Notification settings');
                  },
                ),
                const Divider(height: 1, indent: 16, endIndent: 0),
                ListTile(
                  title: const Text('Help'),
                  onTap: () {
                    // TODO: Implement navigation or action
                    Get.snackbar('Selected', 'Tapped on Help');
                  },
                ),
                const Divider(height: 1, indent: 16, endIndent: 0),
                ListTile(
                  title: const Text('Privacy Policy'),
                  onTap: () {
                    // TODO: Implement navigation or action
                    Get.snackbar('Selected', 'Tapped on Privacy Policy');
                  },
                ),
                const Divider(height: 1, indent: 16, endIndent: 0),
                ListTile(
                  title: const Text('CA Notice at Collection'),
                  onTap: () {
                    // TODO: Implement navigation or action
                    Get.snackbar(
                      'Selected',
                      'Tapped on CA Notice at Collection',
                    );
                  },
                ),
                const Divider(height: 1, indent: 16, endIndent: 0),
                ListTile(
                  title: const Text('Terms of Use'),
                  onTap: () {
                    // TODO: Implement navigation or action
                    Get.snackbar('Selected', 'Tapped on Terms of Use');
                  },
                ),
                const Divider(height: 1, indent: 16, endIndent: 0),
                ListTile(
                  title: const Text('Report a technical problem'),
                  onTap: () {
                    // TODO: Implement navigation or action
                    Get.snackbar(
                      'Selected',
                      'Tapped on Report a technical problem',
                    );
                  },
                ),
                const Divider(height: 1, indent: 16, endIndent: 0),
                ListTile(
                  title: const Text('Do not sell or share my info'),
                  onTap: () {
                    // TODO: Implement navigation or action
                    Get.snackbar(
                      'Selected',
                      'Tapped on Do not sell or share my info',
                    );
                  },
                ),
                const Divider(height: 1, indent: 16, endIndent: 0),
                ListTile(
                  title: const Text('Deactivate account'),
                  onTap: () {
                    // TODO: Implement navigation or action
                    Get.snackbar('Selected', 'Tapped on Deactivate account');
                  },
                ),
                const Divider(height: 1, indent: 16, endIndent: 0),
                ListTile(
                  title: const Text('Delete my account data'),
                  onTap: () {
                    // TODO: Implement navigation or action
                    Get.snackbar(
                      'Selected',
                      'Tapped on Delete my account data',
                    );
                  },
                ),
                const Divider(height: 1, indent: 16, endIndent: 0),
                ListTile(
                  title: const Text('Sign out'),
                  onTap: () {
                    Get.dialog(
                      AlertDialog(
                        title: const Text('Sign Out'),
                        content: const Text(
                          'Are you sure you want to sign out?',
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('No'),
                            onPressed: () {
                              Get.back(); // Dismiss the dialog
                            },
                          ),
                          TextButton(
                            child: const Text('Yes'),
                            onPressed: () {
                              supabase.auth.signOut();
                              Get.offAllNamed(Routes.login);
                            },
                          ),
                        ],
                      ),
                      barrierDismissible:
                          true, // Default is true, explicitly set for clarity
                    );
                  },
                ),
                // No divider after the last item
              ],
            ),
          ),
          // Version Text
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Text(
              'Version 375.0',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
