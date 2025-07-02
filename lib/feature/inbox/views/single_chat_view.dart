import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:us_connector/feature/inbox/controller/single_chat_controller.dart';

class SingleChatView extends GetView<SingleChatController> {
  const SingleChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chat")),
      body: Column(
        children: const [
          Expanded(child: _MessagesList()),
          _SendMessageInput(),
        ],
      ),
    );
  }
}

class _MessagesList extends StatelessWidget {
  const _MessagesList();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SingleChatController>();

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.messages.isEmpty) {
        return const Center(child: Text('No messages yet.'));
      }

      return ListView.builder(
        reverse: false,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: controller.messages.length,
        itemBuilder: (context, index) {
          final msg = controller.messages[index];
          final isMe = msg['sender_id'] == controller.isMe.value;

          return Align(
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? Colors.green : Colors.grey[300],
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
                      child: Image.network(
                        msg['file_url'],
                        width: 180,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image),
                      ),
                    ),
                  Text(
                    msg['message'] ?? '',
                    style: const TextStyle(fontSize: 15),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    msg['sent_at']?.toString().substring(0, 16) ?? '',
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
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
    final senderId = controller.isMe.value;
    final conversationId = controller.conversationId.value;

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: messageController,
              decoration: const InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
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
                      if (text.isNotEmpty) {
                        await controller.sendMessage(
                          text,
                          senderId,
                          conversationId,
                        );
                        messageController.clear();
                      }
                    },
                  );
          }),
        ],
      ),
    );
  }
}
