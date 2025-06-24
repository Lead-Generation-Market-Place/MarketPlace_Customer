import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:us_connector/feature/settings/controller/notification_settings_controller.dart';

class NotificationSettingsView extends GetView<NotificationSettingsController> {
  const NotificationSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      endDrawer: _buildEndDrawer(),
      body: _buildBody(context),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Notification Settings'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: Get.back,
      ),
    );
  }

  Widget _buildEndDrawer() {
    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDrawerItem(
                title: 'Account',
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: _handleAccountTap,
              ),
              const SizedBox(height: 5),
              _buildDrawerItem(
                title: 'Notifications',
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: _handleNotificationsTap,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            _buildUserAvatar(context),
            const SizedBox(height: 40),
            _buildHeaderText(),
            const SizedBox(height: 30),
            _buildNotificationDescription(),
            const SizedBox(height: 20),
            _buildNotificationSwitches(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserAvatar(BuildContext context) {
    return GestureDetector(
      onTap: () => _showUserDetailsSheet(context),
      child: const CircleAvatar(
        radius: 30,
        backgroundImage: AssetImage('assets/icons/us-connector.png'),
      ),
    );
  }

  Widget _buildHeaderText() {
    return const Center(
      child: Text(
        'Notifications',
        style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildNotificationDescription() {
    return const Text(
      'Get Notified about important updates',
      style: TextStyle(fontSize: 16),
    );
  }

  Widget _buildNotificationSwitches() {
    return Expanded(
      child: ListView.separated(
        itemCount: 1,
        separatorBuilder: (context, index) => const Divider(
          indent: 10,
          endIndent: 10,
          color: Colors.grey,
          height: 1,
        ),
        itemBuilder: (context, index) {
          return Obx(
            () => _buildSwitchTile(
              title: 'Can Use Biometric Authentication',
              value: controller.isBiometricAvailable.value,
              onChanged: (value) => controller.toggleBiometricAvailability(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildDrawerItem({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
      child: ListTile(
        leading: Icon(icon),
        trailing: Text(title, style: const TextStyle(fontSize: 20)),
        onTap: onTap,
      ),
    );
  }

  void _showUserDetailsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildBottomSheetContent(),
    );
  }

  Widget _buildBottomSheetContent() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildSheetItem('Home', _handleHomeTap),
            _buildSheetItem('Sign up as a pro', _handleSignUpProTap),
            _buildSheetItem('Plan', _handlePlanTap),
            _buildSheetItem('Team', _handleTeamTap),
            _buildSheetItem('Inbox', _handleInboxTap),
            const Divider(
              indent: 10,
              endIndent: 10,
              color: Colors.grey,
              height: 1,
            ),
            _buildSheetItem('Profile', _handleProfileTap),
            _buildSheetItem('Payment methods', _handlePaymentMethodsTap),
            _buildSheetItem('Log Out', _handleLogOutTap),
          ],
        ),
      ),
    );
  }

  Widget _buildSheetItem(String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          children: [
            const SizedBox(width: 40),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // Event Handlers
  void _handleAccountTap() {
    debugPrint('Account pressed');
  }

  void _handleNotificationsTap() {
    debugPrint('Notifications pressed');
  }

  void _handleHomeTap() {
    _closeSheetAndShowSnackbar('home pressed');
  }

  void _handleSignUpProTap() {
    _closeSheetAndShowSnackbar('Sign up as a pro pressed');
  }

  void _handlePlanTap() {
    _closeSheetAndShowSnackbar('Plan Pressed');
  }

  void _handleTeamTap() {
    _closeSheetAndShowSnackbar('Team pressed');
  }

  void _handleInboxTap() {
    _closeSheetAndShowSnackbar('Inbox pressed');
  }

  void _handleProfileTap() {
    _closeSheetAndShowSnackbar('Profile pressed');
  }

  void _handlePaymentMethodsTap() {
    _closeSheetAndShowSnackbar('Payment Methods pressed');
  }

  void _handleLogOutTap() {
    _closeSheetAndShowSnackbar('Log Out pressed');
  }

  void _closeSheetAndShowSnackbar(String message) {
    Get.back();
    Get.snackbar('Pressed', message);
  }
}
