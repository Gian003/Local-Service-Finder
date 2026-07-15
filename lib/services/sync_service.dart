import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:lsf/services/api_service.dart';
import 'package:lsf/services/connectivity_service.dart';
import 'package:lsf/services/local_db.dart';

/// Drains the outbox (writes queued while offline) once connectivity comes
/// back. Each queued action already carries the idempotency_key it was
/// enqueued with, so a request that actually reached the server before the
/// connection dropped again won't be double-applied on retry.
class SyncService {
  static StreamSubscription<bool>? _subscription;
  static bool _isSyncing = false;

  static void start() {
    _subscription ??= ConnectivityService.onStatusChange.listen((isOnline) {
      if (isOnline) processOutbox();
    });

    // Also try once immediately — the stream above only fires on a change,
    // so a device that's already online at launch (with items left over
    // from a previous offline session) wouldn't otherwise get a trigger.
    ConnectivityService.isOnline().then((online) {
      if (online) processOutbox();
    });
  }

  static void stop() {
    _subscription?.cancel();
    _subscription = null;
  }

  static Future<void> processOutbox() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final pending = await LocalDb.getOutbox();

      for (final action in pending) {
        try {
          final body = jsonDecode(action['body'] as String) as Map<String, dynamic>;
          final method = action['method'] as String;
          final endpoint = action['endpoint'] as String;

          final response = method == 'POST'
              ? await ApiService.postRequest(endpoint, body, auth: true)
              : await ApiService.putRequest(endpoint, body, auth: true);

          if (response.statusCode >= 200 && response.statusCode < 300) {
            await LocalDb.removeFromOutbox(action['id'] as int);
          }
          // Non-2xx (e.g. validation error): leave queued — retried next
          // time connectivity flips, rather than silently dropped.
        } catch (e) {
          debugPrint('Sync failed for outbox item ${action['id']}: $e');
          // Still offline, or request failed again — stop this pass, the
          // next connectivity-restored event will retry from the top.
          break;
        }
      }
    } finally {
      _isSyncing = false;
    }
  }
}
