import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:us_connector/core/constants/file_urls.dart';
import 'package:us_connector/core/routes/routes.dart';
import 'package:us_connector/core/widgets/bottom_navbar.dart';
import 'package:us_connector/feature/inbox/controller/inbox_controller.dart';

class InboxView extends GetView<InboxController> {
  const InboxView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          if (controller.isSearchActive.value) {
            return TextField(
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search conversations...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.white, fontSize: 16),
              ),
              onChanged: (val) => controller.searchText.value = val,
              style: Theme.of(
                context,
              ).textTheme.titleMedium!.copyWith(color: Colors.white),
            );
          }
          return const Text('Inbox');
        }),
        actions: [_buildAppBarButtons(controller, context)],
      ),
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

  final conversations = controller.filteredConversations;
  if (conversations.isEmpty) {
    return const Center(child: Text("No Data Exists"));
  }

  return ListView.separated(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
    itemCount: conversations.length,
    separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.grey),
    itemBuilder: (context, index) {
      final conversation = conversations[index];
      final currentUserId = Supabase.instance.client.auth.currentUser?.id;

      // Determine the other user based on current login
      final isUserProfessional =
          currentUserId == conversation['professional_id'];
      final otherUser = isUserProfessional
          ? conversation['customer']
          : conversation['professional'];
      final profilePic = otherUser['profile_picture_url'];
      final imageUrl = (profilePic != null && profilePic.toString().isNotEmpty)
          ? '${FileUrls.userProfilePicture}$profilePic'
          : null;

      return ListTile(
        onTap: () {
          Get.toNamed(
            Routes.singleChatView,
            arguments: {
              'receiver': conversation['professional'],
              'senderId': isUserProfessional
                  ? conversation['customer_id']
                  : conversation['professional_id'],
              'conversationId': conversation['id'],
              'sender': conversation['customer'],
            },
          );
        },
        leading: ClipOval(
          child: imageUrl != null
              ? CachedNetworkImage(
                  fit: BoxFit.cover,
                  width: 48,
                  height: 48,
                  imageUrl: imageUrl,
                  progressIndicatorBuilder: (context, url, progress) =>
                      SizedBox(
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
                )
              : CircleAvatar(child: const Icon(Icons.person, size: 32)),
        ),
        title: Text(
          otherUser['username'] ?? 'No Name',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          'Tap to continue conversation',
          style: Theme.of(context).textTheme.bodySmall,
        ),

        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        trailing: Text(
          timeago.format(DateTime.parse(conversations[index]['created_at'])),
        ),
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
        child: GestureDetector(
          onTap: () {
            if (controller.isSearchActive.value) {
              controller.isSearchActive.value = false;
              controller.searchText.value = '';
            } else {
              controller.isSearchActive.value = true;
            }
          },
          child: Obx(
            () => Icon(
              controller.isSearchActive.value
                  ? Icons.close
                  : Icons.search_outlined,
            ),
          ),
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
