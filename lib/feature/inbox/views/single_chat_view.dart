import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:us_connector/feature/inbox/controller/single_chat_controller.dart';
import 'package:us_connector/feature/inbox/widgets/phone_dial_popup.dart';
import 'package:us_connector/feature/inbox/widgets/send_review.dart';
import 'package:timeago/timeago.dart' as timeago;

class SingleChatView extends GetView<SingleChatController> {
  const SingleChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [_buildActions(context)],
        title: Text(controller.professional['username']),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildCallOrReviewSection(controller, context),
            Expanded(child: _MessagesList()),

            _buildPickedImages(),
            _SendMessageInput(),
          ],
        ),
      ),
    );
  }
}

class _MessagesList extends StatelessWidget {
  const _MessagesList();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SingleChatController>();

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: controller.messagesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No messages yet.'));
        }
        final messages = snapshot.data!;
        return Stack(
          children: [
            ListView.builder(
              reverse: true,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final date = DateTime.parse(msg['sent_at']);
                final sentAt = timeago.format(date);
                final isMe = msg['sender_id'] == controller.myUserId;

                return Align(
                  alignment: isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue : Colors.grey[300],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: isMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        if (msg['file_url'] != null &&
                            msg['file_url'].toString().toLowerCase() != 'null')
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: CachedNetworkImage(
                              width: 180,
                              progressIndicatorBuilder:
                                  (context, url, progress) {
                                    return LinearProgressIndicator(
                                      value: progress.progress,
                                      minHeight: 4,
                                    );
                                  },
                              imageUrl: msg['file_url'],

                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error_outline, color: Colors.red),
                            ),
                          ),
                        Text(
                          msg['message'] ?? '',
                          style: TextStyle(
                            fontSize: 15,
                            color: isMe ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          sentAt,
                          style: TextStyle(
                            fontSize: 10,
                            color: isMe ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            Positioned(
              bottom: 0,
              child: Obx(
                () => controller.isOtherUserTyping.value
                    ? _buildTypingIndicator(controller)
                    : SizedBox.shrink(),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SendMessageInput extends StatefulWidget {
  const _SendMessageInput();

  @override
  State<_SendMessageInput> createState() => _SendMessageInputState();
}

class _SendMessageInputState extends State<_SendMessageInput> {
  final TextEditingController messageController = TextEditingController();

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SingleChatController>();
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (value) {
                // Only send typing events if text is not empty
                controller.handleTyping(value.isNotEmpty);
              },
              controller: messageController,
              decoration: InputDecoration(
                prefixIcon: InkWell(
                  onTap: () => _chooseImages(controller),
                  child: const Icon(Icons.image_outlined),
                ),
                hintText: 'Type your message...',
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Obx(() {
            return controller.isMessageSending.value
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : IconButton(
                    icon: const Icon(Icons.send),
                    color: Colors.blue,
                    onPressed: () async {
                      final text = messageController.text.trim();
                      if (text.isNotEmpty || controller.images.isNotEmpty) {
                        await controller.sendMessage(text);
                        messageController.clear();
                        controller.handleTyping(false);
                      }
                    },
                  );
          }),
        ],
      ),
    );
  }
}

Future<void> _chooseImages(SingleChatController controller) async {
  try {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
    );

    if (result != null && result.files.isNotEmpty) {
      final pickedFiles = result.paths
          .whereType<String>()
          .map((path) => File(path))
          .toList();

      controller.images.assignAll(pickedFiles);
      print('Picked images: ${controller.images}');
    }
  } catch (e) {
    print('Error picking images: $e');
  }
}

Widget _buildPickedImages() {
  final controller = Get.find<SingleChatController>();

  return Obx(() {
    if (controller.images.isEmpty) return const SizedBox();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: controller.images.map((file) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  file,
                  fit: BoxFit.cover,
                  width: 100,
                  height: 100,
                ),
              ),
            ),
            Positioned(
              top: -8,
              right: -8,
              child: GestureDetector(
                onTap: () => controller.images.remove(file),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                  padding: const EdgeInsets.all(4),
                  child: const Icon(Icons.close, size: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  });
}

Widget _buildActions(BuildContext context) {
  return PopupMenuButton<String>(
    icon: Icon(Icons.more_vert),
    onSelected: (String value) {
      switch (value) {
        case 'see_profile':
          break;
        case 'share_pro':
          break;
        case 'book_time':
          break;
        case 'decline_pro':
          break;
      }
    },
    itemBuilder: (BuildContext context) => [
      const PopupMenuItem(value: 'see_profile', child: Text('See profile')),
      const PopupMenuItem(value: 'share_pro', child: Text('Share pro')),
      const PopupMenuItem(value: 'book_time', child: Text('Book a time')),
      const PopupMenuItem(
        value: 'decline_pro',
        child: Text('Decline pro', style: TextStyle(color: Colors.red)),
      ),
    ],
  );
}

Widget _buildCallOrReviewSection(
  SingleChatController controller,
  BuildContext context,
) {
  return ListTile(
    tileColor: Colors.grey[200],
    trailing: Icon(Icons.arrow_forward_ios_sharp),
    title: Text(controller.professional['username']),
    subtitle: Row(
      spacing: 10,
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton.icon(
          icon: Icon(Icons.call_outlined),
          onPressed: () {
            showCupertinoDialog(
              context: context,
              builder: (context) => PhoneDialPopup(
                phoneNumber: controller.professional['phone_number'] ?? "",
                onDial: () {
                  controller.dialPhoneNumber(
                    controller.professional['phone_number'] ?? "",
                  );
                },
                onCancel: () {
                  Navigator.of(context).pop();
                },
              ),
            );
          },
          label: Text('Call pro'),
        ),
        ElevatedButton.icon(
          icon: Icon(Icons.star_outline),
          onPressed: () => buildSendReview(context),
          label: Text('Review pro'),
        ),
      ],
    ),
  );
}

Widget _buildTypingIndicator(SingleChatController controller) {
  return Container(
    padding: EdgeInsets.all(8),
    margin: EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.grey[200],
      borderRadius: BorderRadius.circular(16),
    ),
    child: Text('${controller.professional['username']} is typing...'),
  );
}
