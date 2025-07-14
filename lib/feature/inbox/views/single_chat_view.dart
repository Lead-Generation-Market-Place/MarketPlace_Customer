import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:us_connector/core/constants/file_urls.dart';
import 'package:us_connector/feature/inbox/controller/single_chat_controller.dart';
import 'package:us_connector/feature/inbox/widgets/phone_dial_popup.dart';
import 'package:us_connector/feature/inbox/widgets/send_review.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:us_connector/feature/inbox/widgets/sms_dial_popup.dart';

class SingleChatView extends GetView<SingleChatController> {
  const SingleChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [_buildActions(context)],
        title: Text(controller.receiver['username']),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildCallOrReviewOrSmsSection(controller, context),
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
  const _MessagesList({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SingleChatController>();

    return Obx(() {
      if (controller.isLoading.value) {
        return Center(child: CircularProgressIndicator.adaptive());
      }
      if (controller.messages.isEmpty) {
        return Center(child: Text('No Messages'));
      }
      return Stack(
        children: [
          ListView.builder(
            controller: controller.scrollController,
            reverse: true,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            itemCount: controller.messages.length,
            itemBuilder: (context, index) {
              final msg = controller.messages[index];
              return _buildMessageTile(msg, controller);
            },
          ),
          Positioned(
            bottom: 0,
            left: 16,
            child: Obx(
              () => controller.isOtherUserTyping.value
                  ? _buildTypingIndicator()
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildMessageTile(
    Map<String, dynamic> msg,
    SingleChatController controller,
  ) {
    final isMe = msg['sender_id'] == controller.myUserId;
    final messageText = msg['message'] ?? '';
    final fileUrl = msg['file_url'];
    final receiverAvatarUrl = controller.receiver['profile_picture_url'];
    final senderAvatarUrl = controller.sender['profile_picture_url'];
    final senderName = controller.sender['username'] ?? 'User';
    final receiverName = controller.receiver['username'];
    final sentAt = _formatTimestamp(msg['sent_at']);

    final receiverAvatar = CircleAvatar(
      radius: 18,
      backgroundColor: Colors.grey.shade300,
      backgroundImage:
          receiverAvatarUrl != null &&
              receiverAvatarUrl.toString().toLowerCase() != 'null'
          ? CachedNetworkImageProvider(
              FileUrls.userProfilePicture + receiverAvatarUrl,
            )
          : null,
      child:
          receiverAvatarUrl == null ||
              receiverAvatarUrl.toString().toLowerCase() == 'null'
          ? Text(
              receiverName[0].toUpperCase(),
              style: const TextStyle(color: Colors.black),
            )
          : null,
    );
    final senderAvatar = CircleAvatar(
      radius: 18,
      backgroundColor: Colors.grey.shade300,
      backgroundImage:
          senderAvatarUrl != null &&
              senderAvatarUrl.toString().toLowerCase() != 'null'
          ? CachedNetworkImageProvider(
              FileUrls.userProfilePicture + senderAvatarUrl,
            )
          : null,
      child:
          senderAvatarUrl == null ||
              senderAvatarUrl.toString().toLowerCase() == 'null'
          ? Text(
              senderName[0].toUpperCase(),
              style: const TextStyle(color: Colors.black),
            )
          : null,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) receiverAvatar,
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isMe ? Colors.blue : Colors.grey.shade200,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: isMe
                          ? const Radius.circular(16)
                          : const Radius.circular(0),
                      bottomRight: isMe
                          ? const Radius.circular(0)
                          : const Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: isMe
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      if (fileUrl != null &&
                          fileUrl.toString().toLowerCase() != 'null')
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: CachedNetworkImage(
                            width: 180,
                            imageUrl: fileUrl,
                            fit: BoxFit.cover,
                            progressIndicatorBuilder:
                                (context, url, progress) =>
                                    LinearProgressIndicator(
                                      value: progress.progress,
                                      minHeight: 3,
                                    ),
                            errorWidget: (context, url, error) => const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      if (messageText.isNotEmpty)
                        Text(
                          messageText,
                          style: TextStyle(
                            fontSize: 15,
                            color: isMe ? Colors.white : Colors.black87,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        sentAt,
                        style: TextStyle(
                          fontSize: 10,
                          color: isMe ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isMe) senderAvatar,
        ],
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      return timeago.format(date, allowFromNow: true);
    } catch (_) {
      return '';
    }
  }

  Widget _buildTypingIndicator() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 18,
          backgroundColor: Colors.grey,
          child: Icon(Icons.person, color: Colors.white),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: const [
              _Dot(),
              SizedBox(width: 3),
              _Dot(delay: Duration(milliseconds: 150)),
              SizedBox(width: 3),
              _Dot(delay: Duration(milliseconds: 300)),
            ],
          ),
        ),
      ],
    );
  }
}

class _Dot extends StatefulWidget {
  final Duration delay;
  const _Dot({this.delay = Duration.zero});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0.3,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    if (widget.delay != Duration.zero) {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: const CircleAvatar(radius: 4, backgroundColor: Colors.black54),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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

Widget _buildCallOrReviewOrSmsSection(
  SingleChatController controller,
  BuildContext context,
) {
  return ListTile(
    tileColor: Colors.grey[200],
    trailing: Icon(Icons.arrow_forward_ios_sharp),
    title: Text(controller.receiver['username']),
    subtitle: Row(
      spacing: 4,
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton.icon(
          icon: Icon(Icons.call_outlined),
          onPressed: () {
            showCupertinoDialog(
              context: context,
              builder: (context) => PhoneDialPopup(
                phoneNumber: controller.receiver['phone_number'] ?? "",
                onDial: () {
                  controller.dialPhoneNumber(
                    controller.receiver['phone_number'] ?? "",
                  );
                },
                onCancel: () {
                  Navigator.of(context).pop();
                },
              ),
            );
          },
          label: Text('Call'),
        ),
        ElevatedButton.icon(
          icon: Icon(Icons.star_outline),
          onPressed: () => buildSendReview(context),
          label: Text('Review'),
        ),
        ElevatedButton.icon(
          icon: Icon(Icons.sms_outlined),
          onPressed: () {
            showCupertinoDialog(
              context: context,
              builder: (context) => SmsDialPopup(
                phoneNumber: controller.receiver['phone_number'] ?? "",

                onSms: () {
                  controller.sendSms(controller.receiver['phone_number'] ?? "");
                },
                onCancel: () {
                  Navigator.of(context).pop();
                },
              ),
            );
          },
          label: Text('SMS'),
        ),
      ],
    ),
  );
}
