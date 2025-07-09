import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/web.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class SingleChatController extends GetxController {
  // Images selected for sending
  final RxList<File> images = <File>[].obs;

  // Supabase client
  final SupabaseClient _client = Supabase.instance.client;

  // Arguments from previous screen
  final RxString otherUserId = ''.obs;
  final RxString conversationId = ''.obs;
  final RxMap professional = <String, dynamic>{}.obs;

  // Local state
  late final String myUserId;
  final RxBool isLoading = false.obs;
  final RxBool isMessageSending = false.obs;
  final RxList<Map<String, dynamic>> messages = <Map<String, dynamic>>[].obs;
  final RxBool isOtherUserTyping = false.obs;

  // Realtime channel
  late RealtimeChannel _channel;
  Timer? _typingTimer;
  bool _lastTypingState = false;
  bool _isChannelInitialized = false;

  @override
  void onInit() {
    final args = Get.arguments;
    otherUserId.value = args['senderId'] ?? '';
    conversationId.value = args['conversationId'] ?? '';
    professional.value = args['professional'] ?? {};
    myUserId = _client.auth.currentUser?.id ?? '';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeRealtime();
    });
    if (conversationId.isEmpty || myUserId.isEmpty) {
      Get.snackbar('Error', 'Missing chat information');
    } else {
      _setupChannel(); //creating a channel
      _setupMessagesSubscription(); //setup listeners
      _subscribeToTypingEvents(); //set up typing listeners
      _channel.subscribe((status, [_]) {
        print('Channel status: $status');
      });
      _isChannelInitialized = true;
    }
    super.onInit();
  }

  void _initializeRealtime() {
    if (_isChannelInitialized) return;

    _setupChannel();
    _subscribeToTypingEvents();
    _isChannelInitialized = true;
  }

  void _setupChannel() {
    _channel = _client.channel('chat_${conversationId.value}');
  }

  void _setupMessagesSubscription() {
    _channel.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'messages',
      callback: (payload) {
        final newMessage = payload.newRecord;
        Logger().d('New Message Arrived: $newMessage');
        messages.insert(0, newMessage);
      },
    );
  }

  void _subscribeToTypingEvents() {
    _channel.onBroadcast(
      event: 'typing',
      callback: (payload, [ref]) {
        try {
          if (payload == null) return;

          final conversationIdPayload = payload['conversation_id']?.toString();
          final userId = payload['user_id']?.toString();
          final isTyping = payload['is_typing'] == true;

          final isFromOtherUser = userId != myUserId;

          if (conversationIdPayload == conversationId.value &&
              isFromOtherUser) {
            isOtherUserTyping.value = isTyping;
            print('Typing status from other user: $isTyping (User: $userId)');
          }
        } catch (e) {
          print('Error in typing event: $e');
        }
      },
    );
  }

  void sendTypingEvent(bool isTyping) {
    if (!_isChannelInitialized) return;

    final payload = {
      'user_id': myUserId,
      'is_typing': isTyping,
      'conversation_id': conversationId.value,
      'timestamp': DateTime.now().toIso8601String(),
    };

    print('Sending typing event: $payload');

    _channel.sendBroadcastMessage(event: 'typing', payload: payload);
  }

  void handleTyping(bool isTyping) {
    _typingTimer?.cancel();

    if (isTyping != _lastTypingState) {
      _lastTypingState = isTyping;
      sendTypingEvent(isTyping);
    }

    if (isTyping) {
      _typingTimer = Timer(const Duration(seconds: 2), () {
        if (_lastTypingState) {
          handleTyping(false);
        }
      });
    }
  }

  Stream<List<Map<String, dynamic>>> get messagesStream {
    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId.value)
        .order('sent_at', ascending: false)
        .map((event) => List<Map<String, dynamic>>.from(event));
  }

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty && images.isEmpty) return;
    isMessageSending.value = true;
    handleTyping(false); // Always stop typing when sending

    try {
      // Upload images first
      for (final image in images) {
        final bytes = await image.readAsBytes();
        final ext = image.path.split('.').last;
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
        final path = 'messages/${conversationId.value}/$fileName';

        await _client.storage
            .from('chatmedia')
            .uploadBinary(
              path,
              bytes,
              fileOptions: FileOptions(contentType: 'image/$ext'),
            );

        final imageUrl = _client.storage.from('chatmedia').getPublicUrl(path);

        await _client.from('messages').insert({
          'conversation_id': conversationId.value,
          'sender_id': myUserId,
          'file_url': imageUrl,
        });
      }

      // Send text message if exists
      if (message.trim().isNotEmpty) {
        await _client.from('messages').insert({
          'conversation_id': conversationId.value,
          'sender_id': myUserId,
          'message': message.trim(),
        });
      }

      images.clear();
    } catch (e) {
      Get.snackbar('Error', 'Failed to send message: ${e.toString()}');
    } finally {
      isMessageSending.value = false;
    }
  }

  @override
  void onClose() {
    _typingTimer?.cancel();
    _channel.unsubscribe();
    _client.removeChannel(_channel);
    super.onClose();
  }

  void dialPhoneNumber(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      Get.snackbar('Error', "Couldn't dial phone number");
    }
  }
}
