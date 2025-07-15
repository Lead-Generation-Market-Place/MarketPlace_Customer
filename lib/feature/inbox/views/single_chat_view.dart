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

// Constants for consistent styling
class _ChatConstants {
  static const double avatarRadius = 18.0;
  static const double messageHorizontalPadding = 14.0;
  static const double messageVerticalPadding = 10.0;
  static const double messageBorderRadius = 16.0;
  static const double imageWidth = 180.0;
  static const double pickedImageSize = 100.0;
  static const double typingDotRadius = 4.0;
  static const EdgeInsets listPadding = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 12,
  );
  static const EdgeInsets messagePadding = EdgeInsets.symmetric(vertical: 6);
  static const EdgeInsets inputPadding = EdgeInsets.all(12.0);
  static const EdgeInsets contentPadding = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 8,
  );
}

class SingleChatView extends GetView<SingleChatController> {
  const SingleChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Column(
          children: [
            _ChatActionSection(controller: controller),
            const Expanded(child: _MessagesList()),
            const _PickedImagesPreview(),
            const _SendMessageInput(),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      actions: [const _ChatActionsMenu()],
      title: Text(controller.receiver['username'] ?? 'Chat'),
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
        return const Center(child: CircularProgressIndicator.adaptive());
      }

      if (controller.messages.isEmpty) {
        return const Center(child: Text('No Messages'));
      }

      return Stack(
        children: [
          _buildMessagesList(controller),
          _buildTypingIndicatorOverlay(controller),
        ],
      );
    });
  }

  Widget _buildMessagesList(SingleChatController controller) {
    return ListView.builder(
      controller: controller.scrollController,
      reverse: true,
      padding: _ChatConstants.listPadding,
      itemCount: controller.messages.length,
      itemBuilder: (context, index) {
        final message = controller.messages[index];
        return _MessageTile(message: message, controller: controller);
      },
    );
  }

  Widget _buildTypingIndicatorOverlay(SingleChatController controller) {
    return Positioned(
      bottom: 0,
      left: 16,
      child: Obx(
        () => controller.isOtherUserTyping.value
            ? _TypingIndicator(controller: controller)
            : const SizedBox.shrink(),
      ),
    );
  }
}

class _MessageTile extends StatelessWidget {
  final Map<String, dynamic> message;
  final SingleChatController controller;

  const _MessageTile({required this.message, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isMe = message['sender_id'] == controller.myUserId;

    return Padding(
      padding: _ChatConstants.messagePadding,
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) _buildAvatar(isReceiver: true),
          if (!isMe) const SizedBox(width: 8),
          Flexible(child: _buildMessageBubble(isMe)),
          if (isMe) const SizedBox(width: 8),
          if (isMe) _buildAvatar(isReceiver: false),
        ],
      ),
    );
  }

  Widget _buildAvatar({required bool isReceiver}) {
    final user = isReceiver ? controller.receiver : controller.sender;
    final avatarUrl = user['profile_picture_url'];
    final username = user['username'] ?? 'User';

    return _UserAvatar(
      avatarUrl: avatarUrl,
      username: username,
      radius: _ChatConstants.avatarRadius,
    );
  }

  Widget _buildMessageBubble(bool isMe) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _ChatConstants.messageHorizontalPadding,
        vertical: _ChatConstants.messageVerticalPadding,
      ),
      decoration: _buildBubbleDecoration(isMe),
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          _buildMessageContent(),
          const SizedBox(height: 4),
          _buildTimestamp(isMe),
        ],
      ),
    );
  }

  BoxDecoration _buildBubbleDecoration(bool isMe) {
    return BoxDecoration(
      color: isMe ? Colors.blue : Colors.grey.shade200,
      borderRadius: BorderRadius.only(
        topLeft: const Radius.circular(_ChatConstants.messageBorderRadius),
        topRight: const Radius.circular(_ChatConstants.messageBorderRadius),
        bottomLeft: isMe
            ? const Radius.circular(_ChatConstants.messageBorderRadius)
            : Radius.zero,
        bottomRight: isMe
            ? Radius.zero
            : const Radius.circular(_ChatConstants.messageBorderRadius),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Widget _buildMessageContent() {
    final messageText = message['message'] ?? '';
    final fileUrl = message['file_url'];
    final isMe = message['sender_id'] == controller.myUserId;

    return Column(
      crossAxisAlignment: isMe
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        if (_hasValidFileUrl(fileUrl)) _buildMessageImage(fileUrl),
        if (messageText.isNotEmpty) _buildMessageText(messageText, isMe),
      ],
    );
  }

  bool _hasValidFileUrl(dynamic fileUrl) {
    return fileUrl != null && fileUrl.toString().toLowerCase() != 'null';
  }

  Widget _buildMessageImage(String fileUrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: CachedNetworkImage(
        width: _ChatConstants.imageWidth,
        imageUrl: fileUrl,
        fit: BoxFit.cover,
        progressIndicatorBuilder: (context, url, progress) =>
            LinearProgressIndicator(value: progress.progress, minHeight: 3),
        errorWidget: (context, url, error) =>
            const Icon(Icons.error_outline, color: Colors.red),
      ),
    );
  }

  Widget _buildMessageText(String text, bool isMe) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 15,
        color: isMe ? Colors.white : Colors.black87,
      ),
    );
  }

  Widget _buildTimestamp(bool isMe) {
    final sentAt = _formatTimestamp(message['sent_at']);
    return Text(
      sentAt,
      style: TextStyle(
        fontSize: 10,
        color: isMe ? Colors.white70 : Colors.black54,
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    try {
      final date = DateTime.parse(timestamp.toString());
      return timeago.format(date, allowFromNow: true);
    } catch (_) {
      return '';
    }
  }
}

class _UserAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String username;
  final double radius;

  const _UserAvatar({
    required this.avatarUrl,
    required this.username,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final hasValidUrl =
        avatarUrl != null &&
        avatarUrl!.toLowerCase() != 'null' &&
        avatarUrl!.isNotEmpty;

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey.shade300,
      backgroundImage: hasValidUrl
          ? CachedNetworkImageProvider(FileUrls.userProfilePicture + avatarUrl!)
          : null,
      child: !hasValidUrl
          ? Text(
              username.isNotEmpty ? username[0].toUpperCase() : 'U',
              style: const TextStyle(color: Colors.black),
            )
          : null,
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  final SingleChatController controller;

  const _TypingIndicator({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _UserAvatar(
          avatarUrl: controller.receiver['profile_picture_url'],
          username: controller.receiver['username'] ?? 'User',
          radius: _ChatConstants.avatarRadius,
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              _AnimatedDot(),
              SizedBox(width: 3),
              _AnimatedDot(delay: Duration(milliseconds: 150)),
              SizedBox(width: 3),
              _AnimatedDot(delay: Duration(milliseconds: 300)),
            ],
          ),
        ),
      ],
    );
  }
}

class _AnimatedDot extends StatefulWidget {
  final Duration delay;

  const _AnimatedDot({this.delay = Duration.zero});

  @override
  State<_AnimatedDot> createState() => _AnimatedDotState();
}

class _AnimatedDotState extends State<_AnimatedDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  void _initializeAnimation() {
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
      child: const CircleAvatar(
        radius: _ChatConstants.typingDotRadius,
        backgroundColor: Colors.black54,
      ),
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
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SingleChatController>();

    return Padding(
      padding: _ChatConstants.inputPadding,
      child: Row(
        children: [
          Expanded(child: _buildTextField(controller)),
          const SizedBox(width: 8),
          _buildSendButton(controller),
        ],
      ),
    );
  }

  Widget _buildTextField(SingleChatController controller) {
    return TextField(
      onChanged: (value) => controller.handleTyping(value.isNotEmpty),
      controller: _messageController,
      decoration: InputDecoration(
        prefixIcon: _ImagePickerButton(controller: controller),
        hintText: 'Type your message...',
        border: const OutlineInputBorder(),
        contentPadding: _ChatConstants.contentPadding,
      ),
    );
  }

  Widget _buildSendButton(SingleChatController controller) {
    return Obx(() {
      return controller.isMessageSending.value
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : IconButton(
              icon: const Icon(Icons.send),
              color: Colors.blue,
              onPressed: () => _handleSendMessage(controller),
            );
    });
  }

  Future<void> _handleSendMessage(SingleChatController controller) async {
    final text = _messageController.text.trim();
    if (text.isNotEmpty || controller.images.isNotEmpty) {
      await controller.sendMessage(text);
      _messageController.clear();
      controller.handleTyping(false);
    }
  }
}

class _ImagePickerButton extends StatelessWidget {
  final SingleChatController controller;

  const _ImagePickerButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _pickImages(),
      child: const Icon(Icons.image_outlined),
    );
  }

  Future<void> _pickImages() async {
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
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick images: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

class _PickedImagesPreview extends StatelessWidget {
  const _PickedImagesPreview();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SingleChatController>();

    return Obx(() {
      if (controller.images.isEmpty) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.all(8),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: controller.images
              .map(
                (file) => _ImagePreviewTile(
                  file: file,
                  onRemove: () => controller.images.remove(file),
                ),
              )
              .toList(),
        ),
      );
    });
  }
}

class _ImagePreviewTile extends StatelessWidget {
  final File file;
  final VoidCallback onRemove;

  const _ImagePreviewTile({required this.file, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [_buildImageContainer(), _buildRemoveButton()],
    );
  }

  Widget _buildImageContainer() {
    return Container(
      width: _ChatConstants.pickedImageSize,
      height: _ChatConstants.pickedImageSize,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          file,
          fit: BoxFit.cover,
          width: _ChatConstants.pickedImageSize,
          height: _ChatConstants.pickedImageSize,
        ),
      ),
    );
  }

  Widget _buildRemoveButton() {
    return Positioned(
      top: -8,
      right: -8,
      child: GestureDetector(
        onTap: onRemove,
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red,
          ),
          padding: const EdgeInsets.all(4),
          child: const Icon(Icons.close, size: 16, color: Colors.white),
        ),
      ),
    );
  }
}

class _ChatActionsMenu extends StatelessWidget {
  const _ChatActionsMenu();

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: _handleMenuSelection,
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'see_profile', child: Text('See profile')),
        PopupMenuItem(value: 'share_pro', child: Text('Share pro')),
        PopupMenuItem(value: 'book_time', child: Text('Book a time')),
        PopupMenuItem(
          value: 'decline_pro',
          child: Text('Decline pro', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'see_profile':
        // TODO: Implement see profile functionality
        break;
      case 'share_pro':
        // TODO: Implement share pro functionality
        break;
      case 'book_time':
        // TODO: Implement book time functionality
        break;
      case 'decline_pro':
        // TODO: Implement decline pro functionality
        break;
    }
  }
}

class _ChatActionSection extends StatelessWidget {
  final SingleChatController controller;

  const _ChatActionSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Colors.grey[200],
      trailing: const Icon(Icons.arrow_forward_ios_sharp),
      title: Text(controller.receiver['username'] ?? 'User'),
      subtitle: Row(
        spacing: 4,
        mainAxisSize: MainAxisSize.min,
        children: [
          _ActionButton(
            icon: Icons.call_outlined,
            label: 'Call',
            onPressed: () => _showCallDialog(context),
          ),
          _ActionButton(
            icon: Icons.star_outline,
            label: 'Review',
            onPressed: () => buildSendReview(context),
          ),
          _ActionButton(
            icon: Icons.sms_outlined,
            label: 'SMS',
            onPressed: () => _showSmsDialog(context),
          ),
        ],
      ),
    );
  }

  void _showCallDialog(BuildContext context) {
    final phoneNumber = controller.receiver['phone_number'] ?? "";

    showCupertinoDialog(
      context: context,
      builder: (context) => PhoneDialPopup(
        phoneNumber: phoneNumber,
        onDial: () => controller.dialPhoneNumber(phoneNumber),
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _showSmsDialog(BuildContext context) {
    final phoneNumber = controller.receiver['phone_number'] ?? "";

    showCupertinoDialog(
      context: context,
      builder: (context) => SmsDialPopup(
        phoneNumber: phoneNumber,
        onSms: () => controller.sendSms(phoneNumber),
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      onPressed: onPressed,
      label: Text(label),
    );
  }
}
