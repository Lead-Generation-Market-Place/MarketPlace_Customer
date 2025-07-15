import 'dart:async';

import 'package:get/get.dart';
import 'package:logger/web.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:us_connector/core/routes/routes.dart';

class InboxController extends GetxController {
  final SupabaseClient _client = Supabase.instance.client;

  // UI State
  final RxBool isLoading = false.obs;
  final RxBool isSearchActive = false.obs;
  final RxString searchText = ''.obs;
  final RxList<Map<String, dynamic>> conversations =
      <Map<String, dynamic>>[].obs;

  // Realtime presence tracking
  final RealtimeChannel _presenceChannel = Supabase.instance.client.channel(
    'online-users',
  );

  final RxSet<String> onlineUsers = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    getConversations();
    _initializePresenceChannel();
    _startTrackingUser();
  }

  /// Fetches all conversations where the current user is a customer or professional
  Future<void> getConversations() async {
    isLoading.value = true;
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) {
        Get.toNamed(Routes.login);
        return;
      }

      final response = await _client
          .from('conversations')
          .select('''
            *,
            customer:users_profiles!conversations_customer_id_fkey(*),
            professional:users_profiles!conversations_professional_id_fkey(*)
          ''')
          .or(
            'customer_id.eq.${currentUser.id},professional_id.eq.${currentUser.id}',
          )
          .order('created_at', ascending: false);

      conversations.value = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      Logger().e("Failed to fetch conversations: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Filters the conversation list based on search query
  List<Map<String, dynamic>> get filteredConversations {
    if (!isSearchActive.value || searchText.value.isEmpty) {
      return conversations;
    }

    final query = searchText.value.toLowerCase();
    return conversations.where((conv) {
      final professional = conv['professional'];
      final customer = conv['customer'];
      final professionalName = (professional?['username'] ?? '')
          .toString()
          .toLowerCase();
      final customerName = (customer?['username'] ?? '')
          .toString()
          .toLowerCase();
      return professionalName.contains(query) || customerName.contains(query);
    }).toList();
  }

  /// Initializes and subscribes to presence events
  void _initializePresenceChannel() {
    _presenceChannel
        .onPresenceSync((_) {
          final presenceState = _presenceChannel.presenceState();

          final updatedOnlineUsers = <String>{};
          for (final item in presenceState) {
            for (final presence in item.presences) {
              final userId = presence.payload['user_id'];
              if (userId != null) {
                updatedOnlineUsers.add(userId);
              }
            }
          }

          onlineUsers.value = updatedOnlineUsers;
          Logger().i("Online users: ${onlineUsers.length}");
        })
        .onPresenceJoin((payload) {
          Logger().i("User joined: ${payload.newPresences}");
        })
        .onPresenceLeave((payload) {
          Logger().i("User left: ${payload.leftPresences}");
        })
        .subscribe();
  }

  /// Sends the current user's presence
  void _startTrackingUser() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    _presenceChannel.track({
      'user_id': userId,
      'online_at': DateTime.now().toIso8601String(),
    });

    Logger().d("Presence track sent for user: $userId");
  }

  /// Gracefully untracks and unsubscribes from the channel
  void _cleanupPresenceChannel() {
    _presenceChannel.untrack();
    _presenceChannel.unsubscribe();
    Logger().d("Presence channel closed.");
  }

  @override
  void onClose() {
    _cleanupPresenceChannel();
    super.onClose();
  }
}
