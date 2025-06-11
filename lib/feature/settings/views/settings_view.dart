import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:us_connector/core/routes/routes.dart';
import 'package:us_connector/feature/auth/controllers/auth_controller.dart';

import 'package:us_connector/feature/settings/controller/setting_controller.dart';
import 'package:us_connector/main.dart';

class SettingsView extends GetView<SettingsController> {
  SettingsView({super.key});
  final AuthController authController = Get.put(AuthController() );
  Widget build(BuildContext context) {
    // ThemeData for easy access to theme properties
    final theme = Theme.of(context);

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
                    CircleAvatar(
                    
                      radius: 50,
                      backgroundColor: Colors.grey,
                      backgroundImage: NetworkImage(authController.profilePictureUrl.value),
                      child: authController.profilePictureUrl.value.isEmpty
                          ? const Icon(Icons.person, size: 50, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Obx(() => Text(
                      authController.name.value,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    )),
                    const SizedBox(height: 4),
                    Obx(() => Text(
                      authController.email.value,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    )),
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
