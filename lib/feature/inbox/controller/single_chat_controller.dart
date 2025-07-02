import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SingleChatController extends GetxController {
  // Supabase client
  final SupabaseClient _client = Supabase.instance.client;

  // Arguments from previous screen
  final RxString senderId = ''.obs;
  final RxString conversationId = ''.obs;

  // Local state
  final RxString isMe = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isMessageSending = false.obs;
  final RxList<Map<String, dynamic>> messages = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    final args = Get.arguments;

    senderId.value = args['senderId'] ?? '';
    conversationId.value = args['conversationId'] ?? '';
    isMe.value = _client.auth.currentUser?.id ?? '';

    if (conversationId.isEmpty || isMe.isEmpty) {
      Get.snackbar('Error', 'Missing chat information');
    } else {
      getMessages();
    }

    super.onInit();
  }

  /// Loads all messages for the current conversation
  Future<void> getMessages() async {
    isLoading.value = true;

    try {
      final response = await _client
          .from('messages')
          .select('*')
          .eq('conversation_id', conversationId.value)
          .order('sent_at', ascending: true);

      messages.assignAll(List<Map<String, dynamic>>.from(response));
    } catch (e) {
      Get.snackbar('Messages', 'Failed to load messages: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Sends a new message to Supabase
  Future<void> sendMessage(
    String message,
    String senderId,
    String conversationId,
  ) async {
    if (message.trim().isEmpty) return;

    isMessageSending.value = true;

    try {
      final messageModel = {
        'conversation_id': conversationId,
        'sender_id': senderId,
        'message': message,
      };

      final response = await _client
          .from('messages')
          .insert(messageModel)
          .select();

      if (response.isNotEmpty) {
        final inserted = Map<String, dynamic>.from(response.first);
        messages.add(inserted); // Optimistically add to the list
      } else {
        Get.snackbar('Error', 'Message not sent.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to send message: $e');
    } finally {
      isMessageSending.value = false;
    }
  }
}
