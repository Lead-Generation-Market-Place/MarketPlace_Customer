import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:us_connector/core/constants/file_urls.dart';
import 'package:us_connector/core/constants/screen_size.dart';
import 'package:us_connector/core/widgets/bottom_navbar.dart';
import 'package:us_connector/feature/inbox/controller/inbox_controller.dart';

class InboxView extends GetView<InboxController> {
  const InboxView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [_buildAppBarButtons(controller, context)]),
      bottomNavigationBar: BottomNavbar(),
      body: Obx(() => _buildConversationsList(controller, context)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => print('New Chat Pressed'),
        label: const Icon(Icons.chat_outlined),
      ),
    );
  }
}

Widget _buildConversationsList(
  InboxController controller,
  BuildContext context,
) {
  if (controller.isLoading.value) {
    return const Center(child: CircularProgressIndicator.adaptive());
  }

  if (controller.conversations.isEmpty) {
    return const Center(child: Text("No Data Exists"));
  }

  return ListView.separated(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
    itemCount: controller.conversations.length,
    separatorBuilder: (_, __) => const Divider(height: 1),
    itemBuilder: (context, index) {
      final professional = controller.conversations[index]['professional'];
      final customer = controller.conversations[index]['customer'];
      return ListTile(
        onTap: () => print(professional),
        leading: ClipOval(
          child: CachedNetworkImage(
            fit: BoxFit.cover,
            width: 48,
            height: 48,
            imageUrl:
                '${FileUrls.userProfilePicture}${professional['profile_picture_url'] ?? ''}',
            progressIndicatorBuilder: (context, url, progress) => SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                value: progress.progress,
                color: Colors.deepPurple,
                strokeWidth: 2,
              ),
            ),
            errorWidget: (context, url, error) =>
                CircleAvatar(child: const Icon(Icons.person, size: 32)),
          ),
        ),
        title: Text(
          professional['username'] ?? 'No Name',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          customer['username'] != null
              ? 'Chat with ${customer['username']}'
              : '',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 18,
          color: Colors.deepPurple,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      );
    },
  );
}

Widget _buildAppBarButtons(InboxController controller, BuildContext context) {
  return Row(
    children: [
      Container(
        margin: const EdgeInsets.all(5),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).highlightColor, width: 2),
          shape: BoxShape.circle,
        ),
        child: InkWell(
          onTap: () => print('Search Clicked'),
          child: const Icon(Icons.search_outlined),
        ),
      ),
      Container(
        margin: const EdgeInsets.all(5),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).highlightColor, width: 2),
          shape: BoxShape.circle,
        ),
        child: InkWell(
          onTap: () => print('Menu Clicked'),
          child: const Icon(Icons.more_vert_rounded),
        ),
      ),
    ],
  );
}
