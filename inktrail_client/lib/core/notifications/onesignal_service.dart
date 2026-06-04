import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:ink_trail_client/core/notifications/notification_navigation_service.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

const _oneSignalAppId = 'b26d3397-b394-49d2-b643-62d52a50f46f';
const _disableOneSignal =
    bool.fromEnvironment('DISABLE_ONESIGNAL', defaultValue: false);
bool _hasRegisteredNotificationClickListener = false;
const Duration _oneSignalInitTimeout = Duration(seconds: 2);
const Duration _oneSignalTagDebounce = Duration(milliseconds: 600);

Timer? _pendingTagSyncTimer;
final Map<String, String> _desiredTags = <String, String>{};
Map<String, String> _lastAppliedTags = <String, String>{};

bool get _isOneSignalEnabled =>
    !_disableOneSignal && _oneSignalAppId.isNotEmpty;
bool _hasInitializedOneSignalSdk = false;
bool _hasRegisteredPushSubscriptionObserver = false;

void primeOneSignalClickHandling() {
  if (!_isOneSignalEnabled) return;
  if (!_hasInitializedOneSignalSdk) {
    OneSignal.Debug.setLogLevel(
      OSLogLevel.none,
    );
    OneSignal.initialize(_oneSignalAppId);
    _hasInitializedOneSignalSdk = true;
  }
  _registerPushSubscriptionObserver();
  _registerNotificationClickListener();
}

Future<void> initializeOneSignal() async {
  if (!_isOneSignalEnabled) {
    if (kDebugMode) {
      debugPrint(
        '[OneSignal] Disabled via DISABLE_ONESIGNAL.',
      );
    }
    return;
  }

  try {
    primeOneSignalClickHandling();
    unawaited(OneSignal.Notifications.requestPermission(true));
    _setDesiredTags(<String, String>{'publish_public': 'true', 'app': 'inktrail'});
    _scheduleTagSync();
  } catch (e) {
    if (kDebugMode) {
      debugPrint('[OneSignal] initialize failed: $e');
    }
  }
}

Future<void> bindOneSignalUser({
  required String userId,
  required String role,
}) async {
  if (!_isOneSignalEnabled) return;
  final normalizedUserId = userId.trim();
  if (normalizedUserId.isEmpty) return;

  try {
    primeOneSignalClickHandling();
    OneSignal.login(normalizedUserId);
    _setDesiredTags(<String, String>{
      'publish_public': 'true',
      'app': 'inktrail',
      'publish_member': 'true',
      'is_logged_in': 'true',
      'user_role': role.trim().isEmpty ? 'reader' : role.trim(),
    });
    _scheduleTagSync();
  } catch (e) {
    if (kDebugMode) {
      debugPrint('[OneSignal] bind user failed: $e');
    }
  }
}

Future<void> unbindOneSignalUser() async {
  if (!_isOneSignalEnabled) return;
  try {
    primeOneSignalClickHandling();
    OneSignal.logout();
    _setDesiredTags(<String, String>{
      'publish_public': 'true',
      'app': 'inktrail',
      'publish_member': 'false',
      'is_logged_in': 'false',
      'user_role': 'reader',
    });
    _scheduleTagSync();
  } catch (e) {
    if (kDebugMode) {
      debugPrint('[OneSignal] unbind user failed: $e');
    }
  }
}

void _setDesiredTags(Map<String, String> tags) {
  _desiredTags.addAll(tags);
}

void _scheduleTagSync() {
  _pendingTagSyncTimer?.cancel();
  _pendingTagSyncTimer = Timer(_oneSignalTagDebounce, () {
    _pendingTagSyncTimer = null;
    unawaited(_syncTagsWithRetry());
  });
}

Future<void> _syncTagsWithRetry() async {
  if (!_isOneSignalEnabled) return;
  if (_desiredTags.isEmpty) return;

  // Only push when something changed.
  final changed = _desiredTags.length != _lastAppliedTags.length ||
      _desiredTags.entries.any((e) => _lastAppliedTags[e.key] != e.value);
  if (!changed) return;

  final snapshot = Map<String, String>.from(_desiredTags);

  const delays = <Duration>[
    Duration(milliseconds: 250),
    Duration(milliseconds: 700),
    Duration(milliseconds: 1400),
  ];

  for (var attempt = 0; attempt < delays.length + 1; attempt += 1) {
    try {
      await OneSignal.User.addTags(snapshot).timeout(_oneSignalInitTimeout);
      _lastAppliedTags = snapshot;
      return;
    } catch (e) {
      if (attempt >= delays.length) {
        if (kDebugMode) {
          debugPrint('[OneSignal] addTags failed: $e');
        }
        return;
      }
      await Future<void>.delayed(delays[attempt]);
    }
  }
}

void _registerPushSubscriptionObserver() {
  if (_hasRegisteredPushSubscriptionObserver) return;
  _hasRegisteredPushSubscriptionObserver = true;

  // When OneSignal assigns subscriptionId / token later, retry tag sync.
  OneSignal.User.pushSubscription.addObserver((_) {
    if (!_isOneSignalEnabled) return;
    _scheduleTagSync();
  });
}

void _registerNotificationClickListener() {
  if (_hasRegisteredNotificationClickListener) return;
  _hasRegisteredNotificationClickListener = true;

  OneSignal.Notifications.addClickListener((event) {
    final notification = event.notification;
    final rawData = notification.additionalData;
    final Map<String, dynamic> data = rawData == null
        ? <String, dynamic>{}
        : Map<String, dynamic>.from(
            rawData.map(
              (dynamic k, dynamic v) => MapEntry(k.toString(), v),
            ),
          );

    // Some payloads may only provide launchUrl; keep routing alive by mapping it.
    final launchUrl = (notification.launchUrl ?? '').trim();
    if (launchUrl.isNotEmpty && !data.containsKey('link_url')) {
      data['link_url'] = launchUrl;
    }
    if (data.isEmpty) return;

    unawaited(
      NotificationNavigationService.openPushPayload(
        data: data,
        title: notification.title,
        body: notification.body,
      ),
    );
  });
}
