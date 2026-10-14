import 'package:flutter/material.dart';
import '../services/storage_services.dart';
import 'day_details.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  Map<String, dynamic> history = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    await StorageService.debugHistory();
    final savedHistory = await StorageService.getAllHistory();

    print('HISTORY RECEIVED BY SCREEN: $savedHistory');

    if (!mounted) return;

    setState(() {
      history = savedHistory;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : history.isEmpty
          ? const Center(
              child: Text(
                'No history yet.',
                style: TextStyle(fontSize: 18, color: Color(0xFF6B7280)),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: history.entries.map((entry) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DayDetailsScreen(
                          date: entry.key,
                          data: entry.value,
                        ),
                      ),
                    );
                  },
                  child: _buildDayCard(entry.key, entry.value),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildDayCard(String date, dynamic data) {
    final int water = data['water'] ?? 0;

    final double sleep = (data['sleep'] ?? 0).toDouble();

    final List activities = data['activities'] ?? [];

    final int progress = _calculateProgress(water, sleep, activities);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          // Date
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Color(0xFF167D8D)),
              const SizedBox(width: 10),
              Text(
                date,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const Spacer(),
              Text(
                '$progress%',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF167D8D),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Water
          _buildInfoRow(
            icon: Icons.water_drop,
            title: 'Water',
            value: '$water / 8 glasses',
          ),

          const SizedBox(height: 12),

          // Sleep
          _buildInfoRow(
            icon: Icons.bed,
            title: 'Sleep',
            value: '${sleep.toStringAsFixed(1)} / 8 hours',
          ),

          const SizedBox(height: 12),

          // Activities
          _buildInfoRow(
            icon: Icons.fitness_center,
            title: 'Activities',
            value: '${activities.length} activities',
          ),

          const SizedBox(height: 15),

          LinearProgressIndicator(
            value: progress / 100,
            minHeight: 8,
            borderRadius: BorderRadius.circular(10),
            backgroundColor: const Color(0xFFE6F4F5),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF167D8D)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF167D8D), size: 24),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontSize: 15, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }

  int _calculateProgress(int water, double sleep, List activities) {
    final int waterProgress = ((water / 8) * 33).round();

    final int sleepProgress = ((sleep / 8) * 33).round();

    final int activityProgress = activities.isNotEmpty ? 34 : 0;

    return (waterProgress + sleepProgress + activityProgress).clamp(0, 100);
  }
}
