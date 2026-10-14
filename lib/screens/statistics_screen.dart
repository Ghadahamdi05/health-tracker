import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/storage_services.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _DayStats {
  final DateTime date;
  final int water;
  final double sleep;
  final int activities;

  const _DayStats({
    required this.date,
    required this.water,
    required this.sleep,
    required this.activities,
  });

  String get dayLabel {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  bool isLoading = true;

  double averageWater = 0;
  double averageSleep = 0;
  int totalActivities = 0;
  int totalWorkoutMinutes = 0;
  int waterGoal = 8;
  double sleepGoal = 8.0;

  List<_DayStats> weeklyStats = [];
  bool hasHistory = false;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _loadStatistics() async {
    final history = await StorageService.getAllHistory();
    final prefs = SharedPreferencesAsync();
    final savedWaterGoal = await prefs.getInt('waterGoal') ?? 8;
    final savedSleepGoal = await prefs.getDouble('sleepGoal') ?? 8.0;

    double waterTotal = 0;
    double sleepTotal = 0;
    int activityTotal = 0;
    int workoutTotal = 0;

    for (final dayValue in history.values) {
      final Map day = dayValue is Map ? dayValue : {};
      final int water = (day['water'] as num?)?.toInt() ?? 0;
      final double sleep = (day['sleep'] as num?)?.toDouble() ?? 0;
      final List activities = day['activities'] is List
          ? day['activities'] as List
          : [];

      waterTotal += water;
      sleepTotal += sleep;
      activityTotal += activities.length;

      for (final activityValue in activities) {
        if (activityValue is Map) {
          workoutTotal += ((activityValue['duration'] as num?)?.toInt() ?? 0);
        }
      }
    }

    final now = DateTime.now();
    final List<_DayStats> lastSevenDays = [];

    // Build the chart from the last seven calendar days, oldest to newest.
    for (int i = 6; i >= 0; i--) {
      final date = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: i));
      final Map day = history[_dateKey(date)] is Map
          ? history[_dateKey(date)] as Map
          : {};
      final List activities = day['activities'] is List
          ? day['activities'] as List
          : [];

      lastSevenDays.add(
        _DayStats(
          date: date,
          water: (day['water'] as num?)?.toInt() ?? 0,
          sleep: (day['sleep'] as num?)?.toDouble() ?? 0,
          activities: activities.length,
        ),
      );
    }

    if (!mounted) return;

    setState(() {
      hasHistory = history.isNotEmpty;
      averageWater = history.isEmpty ? 0 : waterTotal / history.length;
      averageSleep = history.isEmpty ? 0 : sleepTotal / history.length;
      totalActivities = activityTotal;
      totalWorkoutMinutes = workoutTotal;
      waterGoal = savedWaterGoal;
      sleepGoal = savedSleepGoal;
      weeklyStats = lastSevenDays;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : !hasHistory
          ? const Center(
              child: Text(
                'No statistics yet.',
                style: TextStyle(fontSize: 18, color: Color(0xFF6B7280)),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Your Statistics 📊',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'A summary of your health progress.',
                  style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      child: _statCard(
                        icon: Icons.water_drop,
                        title: 'Avg. Water',
                        value: averageWater.toStringAsFixed(1),
                        unit: 'glasses / day',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _statCard(
                        icon: Icons.bed,
                        title: 'Avg. Sleep',
                        value: averageSleep.toStringAsFixed(1),
                        unit: 'hours / day',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _statCard(
                        icon: Icons.fitness_center,
                        title: 'Activities',
                        value: '$totalActivities',
                        unit: 'activities',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _statCard(
                        icon: Icons.timer,
                        title: 'Workout',
                        value: '$totalWorkoutMinutes',
                        unit: 'minutes',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                const Text(
                  'Last 7 Days',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Your daily progress based on saved records.',
                  style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 16),
                _weeklyChart(
                  title: 'Water Intake 💧',
                  unit: 'glasses',
                  color: const Color(0xFF167D8D),
                  values: weeklyStats
                      .map((day) => day.water.toDouble())
                      .toList(),
                  labels: weeklyStats.map((day) => day.dayLabel).toList(),
                  valueLabel: (value) => value.toInt().toString(),
                  goalValue: waterGoal.toDouble(),
                  goalLabel: 'Daily goal: $waterGoal glasses',
                ),
                const SizedBox(height: 16),
                _weeklyChart(
                  title: 'Sleep Hours 🌙',
                  unit: 'hours',
                  color: const Color(0xFF7C6BC4),
                  values: weeklyStats.map((day) => day.sleep).toList(),
                  labels: weeklyStats.map((day) => day.dayLabel).toList(),
                  valueLabel: (value) => value.toStringAsFixed(1),
                  goalValue: sleepGoal,
                  goalLabel:
                      'Daily goal: ${sleepGoal.toStringAsFixed(1)} hours',
                ),
                const SizedBox(height: 16),
                _weeklyChart(
                  title: 'Activities 🏃',
                  unit: 'activities',
                  color: const Color(0xFFE59A45),
                  values: weeklyStats
                      .map((day) => day.activities.toDouble())
                      .toList(),
                  labels: weeklyStats.map((day) => day.dayLabel).toList(),
                  valueLabel: (value) => value.toInt().toString(),
                ),
                const SizedBox(height: 16),
                _weeklyGoalSummary(),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F4F5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Keep Going! 💪',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getMessage(),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _weeklyChart({
    required String title,
    required String unit,
    required Color color,
    required List<double> values,
    required List<String> labels,
    required String Function(double) valueLabel,
    double? goalValue,
    String? goalLabel,
  }) {
    final double maxValue = values.isEmpty
        ? 1
        : values.reduce((a, b) => a > b ? a : b);
    final double chartMax = goalValue != null && goalValue > maxValue
        ? goalValue
        : maxValue;
    final double scaleMax = chartMax <= 0 ? 1 : chartMax;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            goalLabel ?? 'Daily $unit',
            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 145,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(values.length, (index) {
                final value = values[index];
                final double barHeight = value <= 0
                    ? 3
                    : (value / scaleMax) * 88;
                final bool reachedGoal =
                    goalValue != null && value >= goalValue;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          valueLabel(value),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          height: barHeight,
                          decoration: BoxDecoration(
                            color: goalValue == null
                                ? color.withOpacity(value <= 0 ? 0.25 : 0.9)
                                : reachedGoal
                                ? const Color(0xFF2E9D70)
                                : color.withOpacity(value <= 0 ? 0.25 : 0.9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          labels[index],
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _weeklyGoalSummary() {
    final int waterDays = weeklyStats
        .where((day) => day.water >= waterGoal)
        .length;
    final int sleepDays = weeklyStats
        .where((day) => day.sleep >= sleepGoal)
        .length;

    int bestScore = -1;
    final List<_DayStats> bestDays = [];
    for (final day in weeklyStats) {
      final int score =
          (day.water >= waterGoal ? 1 : 0) + (day.sleep >= sleepGoal ? 1 : 0);
      if (score > bestScore) {
        bestScore = score;
        bestDays
          ..clear()
          ..add(day);
      } else if (score == bestScore) {
        bestDays.add(day);
      }
    }

    String bestDayText;
    if (weeklyStats.every((day) => day.water == 0 && day.sleep == 0)) {
      bestDayText = 'No water or sleep records yet';
    } else if (bestScore == 0) {
      bestDayText = 'No daily goals reached yet';
    } else if (bestDays.length == 1) {
      final date = bestDays.first.date;
      bestDayText = '${bestDays.first.dayLabel}, ${date.day}/${date.month}';
    } else {
      bestDayText = 'Tie: ${bestDays.map((day) => day.dayLabel).join(', ')}';
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F4F5),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weekly Goal Summary 🎯',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 14),
          _goalSummaryRow(
            icon: Icons.water_drop,
            label: 'Water goal reached',
            value: '$waterDays / 7 days',
          ),
          const SizedBox(height: 10),
          _goalSummaryRow(
            icon: Icons.bed,
            label: 'Sleep goal reached',
            value: '$sleepDays / 7 days',
          ),
          const Divider(height: 24),
          const Text(
            'Best day for reaching goals',
            style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 4),
          Text(
            bestDayText,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF167D8D),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Best day is based on meeting your water and sleep goals.',
            style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  Widget _goalSummaryRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF167D8D), size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, color: Color(0xFF374151)),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String title,
    required String value,
    required String unit,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF167D8D), size: 30),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 15, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          Text(
            unit,
            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  String _getMessage() {
    if (averageSleep >= 7 && averageWater >= 6 && totalActivities > 0) {
      return 'Excellent! You are doing a great job taking care of yourself.';
    }

    if (averageSleep >= 6 || averageWater >= 5 || totalActivities > 0) {
      return 'Good progress! Keep building healthy habits every day.';
    }

    return 'Start tracking your water, sleep and activities to see your progress here.';
  }
}
