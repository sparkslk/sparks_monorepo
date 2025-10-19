import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'api_service.dart'; // For fetching tasks to build daily incomplete reminders

/// Kind values
/// scheduled_15s: scheduled 15 second after creation
/// scheduled_1m: (reserved for possible future)
/// instant: on-demand (e.g. replay)
/// immediate_fallback: if exact scheduling not permitted
/// daily_incomplete: daily incomplete tasks reminder
class NotificationService {
  NotificationService._();
  static final NotificationService _instance = NotificationService._();
  static NotificationService get I => _instance;

  static const _prefsKey = 'notification_history';
  static const _maxHistory = 100;
  static const _androidChannelId = 'task_channel';
  static const _androidChannelName = 'Task Alerts';
  static const _androidChannelDesc =
      'Notifications about task creation and status.';

  final FlutterLocalNotificationsPlugin _fln =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  bool _timezoneInited = false;

  static const _dailyIncompleteIdsKey = 'notification_daily_incomplete_ids';

  Future<bool> init() async {
    if (_initialized) return true;
    try {
      // Timezone init
      await _ensureTimezone();

      const androidSettings = AndroidInitializationSettings(
        '@mipmap/launcher_icon',
      );
      const ios = DarwinInitializationSettings();
      final initSettings = InitializationSettings(
        android: androidSettings,
        iOS: ios,
      );
      await _fln.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (resp) async {
          // Replay just logs already stored notification by id if exists.
        },
      );

      // Create channel (Android)
      await _fln
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              _androidChannelId,
              _androidChannelName,
              description: _androidChannelDesc,
              importance: Importance.high,
            ),
          );

      _initialized = true;
      debugPrint('[NotificationService] Initialized');
      return true;
    } catch (e) {
      debugPrint('[NotificationService] init error: $e');
      return false;
    }
  }

  Future<void> _ensureTimezone() async {
    if (_timezoneInited) return;
    try {
      tz.initializeTimeZones();
      // Attempt to map the device's numeric offset (e.g. +05:30) to a stable IANA location.
      final now = DateTime.now();
      final offset = now.timeZoneOffset; // Duration
      final offsetKey = _formatOffset(offset); // "+0530" style
      // Fast preferred mapping for common offsets to avoid scanning the whole DB.
      const preferred = <String, String>{
        '+0000': 'Etc/UTC',
        '+0530': 'Asia/Colombo', // also Asia/Kolkata; choose stable no DST
        '+0100': 'Europe/Berlin',
        '-0500': 'America/New_York',
        '+0200': 'Europe/Athens',
        '+0300': 'Europe/Moscow',
        '+0400': 'Asia/Dubai',
        '+0800': 'Asia/Singapore',
        '+0900': 'Asia/Tokyo',
        '+1000': 'Australia/Brisbane',
      };
      String? chosen;
      if (preferred.containsKey(offsetKey)) {
        chosen = preferred[offsetKey];
      } else {
        // As a fallback, scan for any location whose current offset matches.
        for (final entry in tz.timeZoneDatabase.locations.entries) {
          final loc = entry.value;
          final locNow = tz.TZDateTime.now(loc);
          if (locNow.timeZoneOffset == offset) {
            chosen = entry.key;
            break;
          }
        }
      }
      if (chosen != null) {
        tz.setLocalLocation(tz.getLocation(chosen));
        debugPrint(
          '[NotificationService] Timezone mapped to $chosen (offset $offsetKey)',
        );
      } else {
        tz.setLocalLocation(tz.getLocation('UTC'));
        debugPrint(
          '[NotificationService] Timezone fallback to UTC (unmapped offset $offsetKey)',
        );
      }
      _timezoneInited = true;
    } catch (e) {
      debugPrint('[NotificationService] timezone init failed: $e');
    }
  }

  Future<bool> notificationsEnabled() async {
    // On Android 13+ need runtime permission
    final impl = _fln
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (impl != null) {
      final granted = await impl.areNotificationsEnabled();
      return granted ?? true;
    }
    return true; // iOS handled by OS prompts automatically / assume allowed
  }

  /// Ensure we have runtime notification permission (Android 13+). Attempts a request once per session.
  /// Shows an optional SnackBar if still denied.
  Future<bool> ensurePermission({BuildContext? context}) async {
    try {
      final impl = _fln
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (impl != null) {
        bool enabled = (await impl.areNotificationsEnabled()) ?? true;
        if (!enabled) {
          // Attempt a runtime permission request (Android 13+). This call is a no-op pre-13.
          try {
            final requested = await impl.requestNotificationsPermission();
            if (requested != null) enabled = requested;
          } catch (e) {
            debugPrint(
              '[NotificationService] requestNotificationsPermission error: $e',
            );
          }
        }
        // Avoid using context across async gaps if widget tree may have changed; just show if still mounted logically.
        if (!enabled && context != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showSnack(context, 'Notifications disabled in system settings');
          });
        }
        return enabled;
      }
      return true;
    } catch (e) {
      debugPrint('[NotificationService] ensurePermission error: $e');
      return true; // fail open to avoid breaking flows
    }
  }

  void _showSnack(BuildContext context, String msg) {
    try {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (_) {}
  }

  /// Schedule a notification after [seconds]. Falls back to immediate if cannot schedule.
  Future<void> scheduleAfterSeconds({
    required int seconds,
    required String title,
    required String body,
    String kind = 'scheduled_15s',
    Map<String, dynamic>? extra,
  }) async {
    await init();
    await _ensureTimezone();
    final id = _randomId();
    try {
      final enabled = await ensurePermission();
      if (!enabled) {
        debugPrint(
          '[NotificationService] Notifications disabled; fallback immediate',
        );
        await showInstant(
          title: title,
          body: body,
          kind: 'immediate_fallback',
          extra: extra,
        );
        return;
      }

      final scheduled = tz.TZDateTime.now(
        tz.local,
      ).add(Duration(seconds: seconds));
      await _fln.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannelId,
            _androidChannelName,
            channelDescription: _androidChannelDesc,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: jsonEncode({'kind': kind, ...?extra}),
      );
      await _appendHistory({
        'id': id,
        'title': title,
        'body': body,
        'createdAt': DateTime.now().toIso8601String(),
        'scheduledFor': scheduled.toIso8601String(),
        'kind': kind,
        if (extra != null) 'extra': extra,
      });
      debugPrint('[NotificationService] Scheduled $kind id=$id at $scheduled');
    } catch (e) {
      debugPrint(
        '[NotificationService] schedule error: $e -> fallback immediate',
      );
      await showInstant(
        title: title,
        body: body,
        kind: 'immediate_fallback',
        extra: extra,
      );
    }
  }

  Future<void> showInstant({
    required String title,
    required String body,
    String kind = 'instant',
    Map<String, dynamic>? extra,
  }) async {
    await init();
    final id = _randomId();
    try {
      // Check permission quickly for Android 13+ (but still attempt display even if false)
      await ensurePermission();
      await _fln.show(
        id,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannelId,
            _androidChannelName,
            channelDescription: _androidChannelDesc,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: jsonEncode({'kind': kind, ...?extra}),
      );
      await _appendHistory({
        'id': id,
        'title': title,
        'body': body,
        'createdAt': DateTime.now().toIso8601String(),
        'kind': kind,
        if (extra != null) 'extra': extra,
      });
      debugPrint(
        '[NotificationService] Instant notification shown id=$id kind=$kind',
      );
    } catch (e) {
      debugPrint('[NotificationService] showInstant error: $e');
    }
  }

  /// Schedule notifications for incomplete tasks at 00:10:00 local time.
  /// If current time already passed today's 00:10, schedule for next day and optionally fire
  /// immediate notifications (fireImmediateIfPast) so the user still gets alerted now.
  Future<void> scheduleDailyIncompleteTasksCheck({
    bool fireImmediateIfPast = true,
  }) async {
    await init();
    await _ensureTimezone();
    try {
      await _cancelPreviousDailyIncomplete();
      final response = await ApiService.authenticatedRequest(
        'GET',
        '/api/mobile/task',
      );
      final data = response.body.isNotEmpty ? jsonDecode(response.body) : {};
      if (response.statusCode != 200 || data['tasks'] is! List) {
        debugPrint(
          '[NotificationService] Unable to fetch tasks for daily schedule',
        );
        return;
      }
      final List tasks = data['tasks'];
      final now = tz.TZDateTime.now(tz.local);
      tz.TZDateTime target = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        0,
        19,
        0,
      );
      final bool pastTodayWindow = target.isBefore(now);
      if (pastTodayWindow) {
        target = target.add(const Duration(days: 1));
      }
      await _pruneDailyIncompleteHistory(target);
      final scheduledIds = <int>[];
      for (final raw in tasks) {
        try {
          if (raw is! Map) continue;
          final status = (raw['status'] ?? '').toString().toUpperCase();
          if (status == 'PENDING' ||
              status == 'IN_PROGRESS' ||
              status == 'OVERDUE' ||
              status == 'NOT_STARTED') {
            final title = (raw['title'] ?? 'Task').toString();
            final desc = (raw['description'] ?? '').toString().trim();
            final bodyBase = desc.isNotEmpty ? '$desc — ' : '';
            final body = '${bodyBase}Task is not completed within the day.';
            final id = _randomId();
            await _fln.zonedSchedule(
              id,
              title,
              body,
              target,
              NotificationDetails(
                android: AndroidNotificationDetails(
                  _androidChannelId,
                  _androidChannelName,
                  channelDescription: _androidChannelDesc,
                  importance: Importance.high,
                  priority: Priority.high,
                ),
                iOS: const DarwinNotificationDetails(),
              ),
              androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
              uiLocalNotificationDateInterpretation:
                  UILocalNotificationDateInterpretation.absoluteTime,
              payload: jsonEncode({
                'kind': 'daily_incomplete',
                'taskId': raw['id'],
                'status': status,
              }),
            );
            scheduledIds.add(id);
            await _appendHistory({
              'id': id,
              'title': title,
              'body': body,
              'createdAt': DateTime.now().toIso8601String(),
              'scheduledFor': target.toIso8601String(),
              'kind': 'daily_incomplete',
              'status': status,
            });
            if (pastTodayWindow && fireImmediateIfPast) {
              await showInstant(
                title: title,
                body: body,
                kind: 'daily_incomplete',
              );
            }
          }
        } catch (ie) {
          debugPrint(
            '[NotificationService] Skip task daily schedule error: $ie',
          );
        }
      }
      await _storeDailyIncompleteIds(scheduledIds);
      debugPrint(
        '[NotificationService] Scheduled ${scheduledIds.length} daily_incomplete notifications for $target (pastTodayWindow=$pastTodayWindow)',
      );
    } catch (e) {
      debugPrint('[NotificationService] daily schedule error: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null || raw.isEmpty) return [];
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .cast<Map<String, dynamic>>()
            .reversed
            .toList(); // reverse chronological
      }
      return [];
    } catch (e) {
      debugPrint('[NotificationService] fetchHistory parse error: $e');
      return [];
    }
  }

  Future<void> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefsKey);
      debugPrint('[NotificationService] History cleared');
    } catch (e) {
      debugPrint('[NotificationService] clearHistory error: $e');
    }
  }

  Future<void> replay(Map<String, dynamic> entry) async {
    await showInstant(
      title: entry['title'] ?? 'Task',
      body: entry['body'] ?? 'Replayed notification',
      kind: 'instant',
    );
  }

  int _randomId() => Random().nextInt(1 << 31);

  static String _formatOffset(Duration offset) {
    final sign = offset.isNegative ? '-' : '+';
    final abs = offset.abs();
    final hours = abs.inHours;
    final minutes = abs.inMinutes % 60;
    return '$sign${hours.toString().padLeft(2, '0')}${minutes.toString().padLeft(2, '0')}';
  }

  Future<void> _appendHistory(Map<String, dynamic> map) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      List<dynamic> list = [];
      if (raw != null && raw.isNotEmpty) {
        try {
          final decoded = jsonDecode(raw);
          if (decoded is List) list = decoded;
        } catch (_) {}
      }
      list.add(map);
      if (list.length > _maxHistory) {
        list = list.sublist(list.length - _maxHistory); // keep last
      }
      await prefs.setString(_prefsKey, jsonEncode(list));
    } catch (e) {
      debugPrint('[NotificationService] appendHistory error: $e');
    }
  }

  Future<void> _storeDailyIncompleteIds(List<int> ids) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_dailyIncompleteIdsKey, jsonEncode(ids));
    } catch (e) {
      debugPrint('[NotificationService] storeDailyIds error: $e');
    }
  }

  Future<void> _cancelPreviousDailyIncomplete() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_dailyIncompleteIdsKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          for (final id in decoded) {
            if (id is int) {
              await _fln.cancel(id);
            }
          }
        }
      }
      await prefs.remove(_dailyIncompleteIdsKey);
    } catch (e) {
      debugPrint('[NotificationService] cancelDailyIds error: $e');
    }
  }

  Future<void> _pruneDailyIncompleteHistory(tz.TZDateTime target) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null || raw.isEmpty) return;
      final decoded = jsonDecode(raw);
      if (decoded is! List) return;
      final targetDate = DateTime(target.year, target.month, target.day);
      final List pruned = [];
      for (final e in decoded) {
        if (e is Map &&
            e['kind'] == 'daily_incomplete' &&
            e['scheduledFor'] is String) {
          try {
            final sc = DateTime.parse(e['scheduledFor']);
            final scDay = DateTime(sc.year, sc.month, sc.day);
            if (scDay == targetDate) {
              // skip existing entry to avoid duplicates for same day
              continue;
            }
          } catch (_) {}
        }
        pruned.add(e);
      }
      await prefs.setString(_prefsKey, jsonEncode(pruned));
    } catch (e) {
      debugPrint('[NotificationService] pruneDailyIncompleteHistory error: $e');
    }
  }
}
