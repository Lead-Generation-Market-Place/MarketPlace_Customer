import 'dart:io';

import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class SingleChatController extends GetxController {
  // Images selected for sending
  final RxList<File> images = <File>[].obs;

  // Supabase client
  final SupabaseClient _client = Supabase.instance.client;

  // Arguments from previous screen
  final RxString otherUserId = ''.obs; // The user you are chatting with
  final RxString conversationId = ''.obs;
  final RxMap professional = <String, dynamic>{}.obs;

  // Local state
  late final String myUserId;
  final RxBool isLoading = false.obs;
  final RxBool isMessageSending = false.obs;
  final RxList<Map<String, dynamic>> messages = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    final args = Get.arguments;
    otherUserId.value = args['senderId'] ?? '';
    conversationId.value = args['conversationId'] ?? '';
    professional.value = args['professional'] ?? {};
    myUserId = _client.auth.currentUser?.id ?? '';

    if (conversationId.isEmpty || myUserId.isEmpty) {
      Get.snackbar('Error', 'Missing chat information');
    } else {
      messagesStream;
    }
    super.onInit();
  }

  /// Stream of messages for the current conversation
  Stream<List<Map<String, dynamic>>> get messagesStream {
    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId.value)
        .order('sent_at', ascending: false)
        .map((event) => List<Map<String, dynamic>>.from(event));
  }

  /// Sends a new message to Supabase
  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty && images.isEmpty) return;
    isMessageSending.value = true;
    try {
      // 1. Upload and send image messages
      for (final image in images) {
        final bytes = await image.readAsBytes();
        final ext = image.path.split('.').last;
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
        final storagePath = 'messages/${conversationId.value}/$fileName';

        await _client.storage
            .from('chatmedia')
            .uploadBinary(
              storagePath,
              bytes,
              fileOptions: FileOptions(contentType: 'image/$ext'),
            );

        final imageUrl = _client.storage
            .from('chatmedia')
            .getPublicUrl(storagePath);
        print(imageUrl);
        final imageMessage = {
          'conversation_id': conversationId.value,
          'sender_id': myUserId,
          'message': '', // no text, just image
          'file_url': imageUrl,
        };

        final response = await _client
            .from('messages')
            .insert(imageMessage)
            .select();
        if (response.isNotEmpty) {
          messages.add(Map<String, dynamic>.from(response.first));
        }
      }

      // 2. If there's a text message, send that as a separate message
      if (message.trim().isNotEmpty) {
        final textMessage = {
          'conversation_id': conversationId.value,
          'sender_id': myUserId,
          'message': message.trim(),
          'file_url': null,
        };

        final response = await _client
            .from('messages')
            .insert(textMessage)
            .select();
        if (response.isNotEmpty) {
          messages.add(Map<String, dynamic>.from(response.first));
        }
      }

      // 3. Clear selected images
      images.clear();
    } catch (e) {
      Get.snackbar('Error', 'Failed to send message: $e');
    } finally {
      isMessageSending.value = false;
    }
  }

  void dialPhoneNumber(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);

    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      Get.snackbar('Phone Dial', "Could Not Dial Phone to that phone number");
    }
  }
}
