import 'package:flutter/material.dart';

import 'models/activity.dart';
import 'screens/add_activity.dart';
import 'screens/edit_activity_screen.dart';
import 'screens/history_screen.dart';
import 'screens/statistics_screen.dart';
import 'widgets/water_card.dart';
import 'widgets/sleep_card.dart';
import 'services/storage_services.dart';
import 'screens/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HealthFitnessApp());
}

class HealthFitnessApp extends StatelessWidget {
  const HealthFitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Health & Fitness Tracker',

      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),

        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF167D8D)),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF167D8D),
          foregroundColor: Colors.white,
          elevation: 0,
        ),

        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF167D8D),
          foregroundColor: Colors.white,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF167D8D),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        inputDecorationTheme: const InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF167D8D), width: 2),
          ),
        ),
      ),

      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Activity> activities = [];

  int waterCount = 0;

  double sleepHours = 0;

  bool isLoading = true;
  int waterGoal = 8;
  double sleepGoal = 8.0;

  @override
  void initState() {
    super.initState();

    _loadData();
  }

  Future<void> _loadData() async {
    final savedWater = await StorageService.getWater();
    final savedSleep = await StorageService.getSleep();
    final savedActivities = await StorageService.getActivities();

    final prefs = SharedPreferencesAsync();

    final savedWaterGoal = await prefs.getInt('waterGoal') ?? 8;

    final savedSleepGoal = await prefs.getDouble('sleepGoal') ?? 8.0;

    if (!mounted) return;

    setState(() {
      waterCount = savedWater;
      sleepHours = savedSleep;

      waterGoal = savedWaterGoal;
      sleepGoal = savedSleepGoal;

      activities
        ..clear()
        ..addAll(savedActivities);

      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Health & Fitness',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            },
            icon: const Icon(Icons.history),
          ),

          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StatisticsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.bar_chart),
          ),
          IconButton(
            onPressed: () async {
              await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );

              if (mounted) {
                await _loadData();
              }
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),

          children: [
            // =========================
            // Welcome Section
            // =========================
            const Text(
              'Good Morning! 👋',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Take care of your health, one day at a time.',
              style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
            ),

            const SizedBox(height: 25),

            // =========================
            // Progress Card
            // =========================
            _buildProgressCard(),

            const SizedBox(height: 20),

            // =========================
            // Water
            // =========================
            WaterCard(
              waterCount: waterCount,
              waterGoal: waterGoal,
              onAddWater: () async {
                if (waterCount < waterGoal) {
                  setState(() {
                    waterCount++;
                  });

                  await StorageService.saveWater(waterCount);
                }
              },
            ),

            const SizedBox(height: 15),

            // =========================
            // Sleep
            // =========================
            SleepCard(
              sleepHours: sleepHours,
              sleepGoal: sleepGoal,
              onAddSleep: _showSleepDialog,
            ),

            const SizedBox(height: 25),

            // =========================
            // Activities Header
            // =========================
            Row(
              children: [
                const Expanded(
                  child: Text(
                    "Today's Activities",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),

                Text(
                  '${activities.length}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF167D8D),
                  ),
                ),

                const SizedBox(width: 5),

                const Text(
                  'activities',
                  style: TextStyle(color: Color(0xFF6B7280)),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // =========================
            // Activities
            // =========================
            if (activities.isEmpty)
              _buildEmptyActivities()
            else
              ...activities.asMap().entries.map((entry) {
                final int index = entry.key;

                final Activity activity = entry.value;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),

                  child: Dismissible(
                    key: ValueKey(
                      '${activity.name}_${activity.duration}_$index',
                    ),

                    direction: DismissDirection.endToStart,

                    background: Container(
                      alignment: Alignment.centerRight,

                      padding: const EdgeInsets.only(right: 20),

                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(15),
                      ),

                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),

                    onDismissed: (direction) async {
                      setState(() {
                        activities.removeAt(index);
                      });

                      await StorageService.saveActivities(activities);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Activity deleted')),
                      );
                    },

                    child: GestureDetector(
                      onTap: () async {
                        final Activity? updatedActivity =
                            await Navigator.push<Activity>(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditActivityScreen(activity: activity),
                              ),
                            );

                        if (updatedActivity != null) {
                          setState(() {
                            activities[index] = updatedActivity;
                          });

                          await StorageService.saveActivities(activities);
                        }
                      },

                      child: _activityCard(
                        icon: _getActivityIcon(activity.name),

                        title: activity.name,

                        subtitle: '${activity.duration} minutes',
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),

      // =========================
      // Add Activity Button
      // =========================
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final Activity? newActivity = await Navigator.push<Activity>(
            context,
            MaterialPageRoute(builder: (context) => const AddActivityScreen()),
          );

          if (newActivity != null) {
            setState(() {
              activities.add(newActivity);
            });

            await StorageService.saveActivities(activities);
          }
        },

        child: const Icon(Icons.add, size: 30),
      ),
    );
  }

  // =====================================================
  // Progress Card
  // =====================================================

  Widget _buildProgressCard() {
    final progress = _calculateProgress();

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        color: const Color(0xFFE6F4F5),

        borderRadius: BorderRadius.circular(22),
      ),

      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      "Today's Progress",
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),

                    SizedBox(height: 5),

                    Text(
                      'Keep going! 💪',
                      style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),

              Text(
                '$progress%',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF167D8D),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),

            child: LinearProgressIndicator(
              value: progress / 100,

              minHeight: 12,

              backgroundColor: Colors.white,

              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF167D8D),
              ),
            ),
          ),

          const SizedBox(height: 18),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,

            children: [
              _progressItem(
                Icons.water_drop,
                '$waterCount/$waterGoal',
                'Water',
              ),

              _progressItem(
                Icons.bed,
                '${sleepHours.toStringAsFixed(1)}/${sleepGoal.toStringAsFixed(1)}',
                'Sleep',
              ),

              _progressItem(
                Icons.fitness_center,
                '${activities.length}',
                'Activities',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =====================================================
  // Progress Item
  // =====================================================

  Widget _progressItem(IconData icon, String value, String title) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF167D8D), size: 25),

        const SizedBox(height: 5),

        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF1F2937),
          ),
        ),

        Text(
          title,
          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }

  // =====================================================
  // Empty Activities
  // =====================================================

  Widget _buildEmptyActivities() {
    return Container(
      padding: const EdgeInsets.all(30),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),

            blurRadius: 8,

            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Column(
        children: [
          const Icon(Icons.directions_run, size: 50, color: Color(0xFF167D8D)),

          const SizedBox(height: 12),

          const Text(
            'No activities yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Tap + to add your first activity.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // Activity Card
  // =====================================================

  Widget _activityCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),

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

      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(11),

            decoration: BoxDecoration(
              color: const Color(0xFFE6F4F5),

              borderRadius: BorderRadius.circular(13),
            ),

            child: Icon(icon, size: 30, color: const Color(0xFF167D8D)),
          ),

          const SizedBox(width: 15),

          Expanded(
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
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),

          const Icon(Icons.edit_outlined, size: 20, color: Color(0xFF9CA3AF)),
        ],
      ),
    );
  }

  // =====================================================
  // Sleep Dialog
  // =====================================================

  void _showSleepDialog() {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text('Add Sleep'),

          content: TextField(
            controller: controller,

            keyboardType: const TextInputType.numberWithOptions(decimal: true),

            decoration: const InputDecoration(
              labelText: 'Hours of sleep',

              hintText: 'Example: 7.5',

              border: OutlineInputBorder(),
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text('CANCEL'),
            ),

            ElevatedButton(
              onPressed: () async {
                final double? hours = double.tryParse(controller.text);

                if (hours != null && hours >= 0 && hours <= 24) {
                  setState(() {
                    sleepHours = hours;
                  });

                  await StorageService.saveSleep(hours);

                  Navigator.pop(context);
                }
              },

              child: const Text('SAVE'),
            ),
          ],
        );
      },
    );
  }

  // =====================================================
  // Progress Calculation
  // =====================================================

  int _calculateProgress() {
    final int waterProgress = ((waterCount / waterGoal) * 33).round();

    final int sleepProgress = ((sleepHours / sleepGoal) * 33).round();

    final int activityProgress = activities.isNotEmpty ? 34 : 0;

    return (waterProgress + sleepProgress + activityProgress).clamp(0, 100);
  }

  // =====================================================
  // Activity Icons
  // =====================================================

  IconData _getActivityIcon(String activityName) {
    switch (activityName) {
      case 'Running':
        return Icons.directions_run;

      case 'Walking':
        return Icons.directions_walk;

      case 'Cycling':
        return Icons.directions_bike;

      case 'Swimming':
        return Icons.pool;

      case 'Gym':
        return Icons.fitness_center;

      case 'Yoga':
        return Icons.self_improvement;

      default:
        return Icons.sports;
    }
  }
}
