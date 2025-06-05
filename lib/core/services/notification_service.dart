import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

/// Callback type for realtime events
typedef RealtimeCallback = void Function(Map<String, dynamic> payload);

/// Service to handle realtime subscriptions and notifications
class RealtimeService {
  // Singleton instance
  static final RealtimeService _instance = RealtimeService._internal();
  factory RealtimeService() => _instance;
  RealtimeService._internal();

  final SupabaseClient _client = Supabase.instance.client;
  final Map<String, RealtimeChannel> _channels = {};
  bool _isDebugMode = kDebugMode;

  /// Enable or disable debug mode
  void setDebugMode(bool enabled) {
    _isDebugMode = enabled;
  }

  void _log(String message, {bool isError = false, dynamic error}) {
    if (_isDebugMode) {
      final prefix = isError ? '[❌ Realtime ERROR]' : '[🔄 Realtime]';
      final errorInfo = error != null ? '\nError details: $error' : '';
      print('$prefix $message$errorInfo');
    }
  }

  /// Subscribe to a table with optional schema (default is "public")
  Future<void> subscribeToTable({
    required String table,
    String schema = 'public',
    RealtimeCallback? onInsert,
    RealtimeCallback? onUpdate,
    RealtimeCallback? onDelete,
    Function(dynamic)? onError,
  }) async {
    try {
      final channelKey = '$schema:$table';

      if (_channels.containsKey(channelKey)) {
        _log('Already subscribed to $channelKey');
        return;
      }

      final channel = _client.channel('realtime:$schema:$table');

      if (onInsert != null) {
        channel.onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: schema,
          table: table,
          callback: (payload) {
            _log('Insert in $table: ${payload.newRecord}');
            onInsert(payload.newRecord);
          },
        );
      }

      if (onUpdate != null) {
        channel.onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: schema,
          table: table,
          callback: (payload) {
            _log('Update in $table: ${payload.newRecord}');
            onUpdate(payload.newRecord);
          },
        );
      }

      if (onDelete != null) {
        channel.onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: schema,
          table: table,
          callback: (payload) {
            _log('Delete in $table: ${payload.oldRecord}');
            onDelete(payload.oldRecord);
          },
        );
      }

      channel.subscribe(
        (status, error) {
          if (status == RealtimeSubscribeStatus.subscribed) {
            _log('Subscribed to $channelKey successfully');
          } else {
            _log('Subscription failed: $status', isError: true, error: error);
            if (onError != null) onError(error);
          }
        },
      );

      _channels[channelKey] = channel;
    } catch (e) {
      _log('Failed to subscribe to $table', isError: true, error: e);
      if (onError != null) onError(e);
      rethrow;
    }
  }

  /// Unsubscribe from a specific table
  Future<void> unsubscribeFromTable({
    required String table,
    String schema = 'public',
    Function(dynamic)? onError,
  }) async {
    try {
      final channelKey = '$schema:$table';
      final channel = _channels[channelKey];

      if (channel != null) {
        await _client.removeChannel(channel);
        _channels.remove(channelKey);
        _log('Unsubscribed from $channelKey');
      } else {
        _log('No active subscription found for $channelKey', isError: true);
      }
    } catch (e) {
      _log('Failed to unsubscribe from $table', isError: true, error: e);
      if (onError != null) onError(e);
      rethrow;
    }
  }

  /// Unsubscribe from all channels
  Future<void> unsubscribeAll({Function(dynamic)? onError}) async {
    try {
      for (final entry in _channels.entries) {
        try {
          await _client.removeChannel(entry.value);
          _log('Unsubscribed from ${entry.key}');
        } catch (e) {
          _log('Failed to unsubscribe from ${entry.key}', isError: true, error: e);
          if (onError != null) onError(e);
        }
      }
      _channels.clear();
    } catch (e) {
      _log('Failed to unsubscribe from all channels', isError: true, error: e);
      if (onError != null) onError(e);
      rethrow;
    }
  }

  /// Get all active subscriptions
  List<String> getActiveSubscriptions() {
    return _channels.keys.toList();
  }

  /// Check if subscribed to a specific table
  bool isSubscribedTo(String table, {String schema = 'public'}) {
    return _channels.containsKey('$schema:$table');
  }
}
