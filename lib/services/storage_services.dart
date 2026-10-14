import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/activity.dart';

class StorageService {
  static const String historyKey = 'dailyHistory';

  static final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  // تنظيم عمليات الحفظ حتى لا تتداخل
  static Future<void> _pendingSave = Future<void>.value();

  // تاريخ اليوم بصيغة yyyy-MM-dd
  static String _getTodayDate() {
    final now = DateTime.now();

    return '${now.year}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  // قراءة جميع الأيام المحفوظة
  static Future<Map<String, dynamic>> _getHistory() async {
    final savedData = await _prefs.getString(historyKey);

    if (savedData == null || savedData.isEmpty) {
      return {};
    }

    final decoded = jsonDecode(savedData);

    if (decoded is! Map) {
      return {};
    }

    return Map<String, dynamic>.from(decoded);
  }

  // حفظ جميع الأيام دون حذف الأيام السابقة
  static Future<void> _saveHistory(Map<String, dynamic> history) async {
    await _prefs.setString(historyKey, jsonEncode(history));
  }

  // إنشاء سجل اليوم إذا لم يكن موجودًا
  static Map<String, dynamic> _getOrCreateToday(Map<String, dynamic> history) {
    final today = _getTodayDate();
    final existing = history[today];

    final Map<String, dynamic> dayData = existing is Map
        ? Map<String, dynamic>.from(existing)
        : <String, dynamic>{};

    dayData.putIfAbsent('water', () => 0);
    dayData.putIfAbsent('sleep', () => 0.0);
    dayData.putIfAbsent('activities', () => []);

    history[today] = dayData;

    return dayData;
  }

  // تحديث بيانات اليوم مع تنظيم عمليات الحفظ
  static Future<void> _updateToday(
    void Function(Map<String, dynamic> dayData) update,
  ) {
    final operation = _pendingSave.then((_) async {
      final history = await _getHistory();
      final todayData = _getOrCreateToday(history);

      update(todayData);

      await _saveHistory(history);
    });

    // السماح للعمليات التالية بالانتظار حتى تنتهي العملية الحالية
    _pendingSave = operation.then<void>(
      (_) {},
      onError: (Object error, StackTrace stackTrace) {},
    );

    return operation;
  }

  // =========================
  // WATER
  // =========================

  static Future<void> saveWater(int waterCount) {
    return _updateToday((dayData) {
      dayData['water'] = waterCount;
    });
  }

  static Future<int> getWater() async {
    final history = await _getHistory();
    final dayData = history[_getTodayDate()];

    if (dayData is! Map) return 0;

    return (dayData['water'] as num?)?.toInt() ?? 0;
  }

  // =========================
  // SLEEP
  // =========================

  static Future<void> saveSleep(double sleepHours) {
    return _updateToday((dayData) {
      dayData['sleep'] = sleepHours;
    });
  }

  static Future<double> getSleep() async {
    final history = await _getHistory();
    final dayData = history[_getTodayDate()];

    if (dayData is! Map) return 0.0;

    return (dayData['sleep'] as num?)?.toDouble() ?? 0.0;
  }

  // =========================
  // ACTIVITIES
  // =========================

  static Future<void> saveActivities(List<Activity> activities) {
    return _updateToday((dayData) {
      dayData['activities'] = activities.map((activity) {
        return {'name': activity.name, 'duration': activity.duration};
      }).toList();
    });
  }

  static Future<List<Activity>> getActivities() async {
    final history = await _getHistory();
    final dayData = history[_getTodayDate()];

    if (dayData is! Map) return [];

    final List activities = dayData['activities'] ?? [];

    return activities.map((item) {
      return Activity(
        name: item['name'],
        duration: (item['duration'] as num).toInt(),
      );
    }).toList();
  }

  // =========================
  // HISTORY
  // =========================

  static Future<Map<String, dynamic>> getAllHistory() async {
    final history = await _getHistory();

    final sortedEntries = history.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    return Map<String, dynamic>.fromEntries(sortedEntries);
  }

  // طباعة السجلات المحفوظة في Console
  static Future<void> debugHistory() async {
    final savedData = await _prefs.getString(historyKey);

    print('===== SAVED HISTORY =====');
    print(savedData ?? 'No history data found');
    print('=========================');
  }
}
