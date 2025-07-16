import 'package:get/get.dart';
import 'package:logger/web.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppPresenceService extends GetxService {
  static AppPresenceService get to => Get.find();

  final SupabaseClient _client = Supabase.instance.client;
  late final RealtimeChannel _presenceChannel;

  final RxSet<String> onlineUsers = <String>{}.obs;
  bool _isSubscribed = false;

  /// Initialize and subscribe to the presence channel
  Future<AppPresenceService> init() async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) return this;

    _presenceChannel = _client.channel('online-users');

    // Setup presence event handlers
    _presenceChannel
      ..onPresenceSync((_) {
        final state = _presenceChannel.presenceState();
        final updated = <String>{};

        for (final item in state) {
          for (final presence in item.presences) {
            final id = presence.payload['user_id'];
            if (id != null) updated.add(id);
          }
        }

        onlineUsers.value = updated;
        Logger().i('Online users: ${onlineUsers.length}');
      })
      ..onPresenceJoin((e) {
        Logger().i('User joined: ${e.newPresences}');
      })
      ..onPresenceLeave((e) {
        Logger().i('User left: ${e.leftPresences}');
      });

    // Subscribe and wait for completion
    await _presenceChannel.subscribe();
    _isSubscribed = true;
    Logger().i("Presence channel subscribed ✅");

    _trackCurrentUser();

    return this;
  }

  void _trackCurrentUser() {
    final userId = _client.auth.currentUser?.id;
    if (userId != null && _isSubscribed) {
      _presenceChannel.track({
        'user_id': userId,
        'online_at': DateTime.now().toIso8601String(),
      });
      Logger().d('Presence tracked for $userId');
    } else {
      Logger().w('User not tracked (missing ID or not subscribed yet)');
    }
  }

  void trackPresence() => _trackCurrentUser();

  void untrackPresence() {
    if (_isSubscribed) {
      _presenceChannel.untrack();
      Logger().d('Presence untracked');
    }
  }

  void disposePresence() {
    if (_isSubscribed) {
      _presenceChannel.untrack();
      _presenceChannel.unsubscribe();
      _isSubscribed = false;
      Logger().d('Presence channel disposed');
    }
  }
}
