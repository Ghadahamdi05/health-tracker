import 'activity.dart';

class DailyRecord {
  final String date;
  final int waterCount;
  final double sleepHours;
  final List<Activity> activities;

  DailyRecord({
    required this.date,
    required this.waterCount,
    required this.sleepHours,
    required this.activities,
  });
}