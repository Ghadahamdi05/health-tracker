import 'package:flutter/material.dart';

class DayDetailsScreen extends StatelessWidget {
  final String date;
  final dynamic data;

  const DayDetailsScreen({
    super.key,
    required this.date,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final int water = data['water'] ?? 0;

    final double sleep =
    (data['sleep'] ?? 0).toDouble();

    final List activities =
        data['activities'] ?? [];

    final int progress = _calculateProgress(
      water,
      sleep,
      activities,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Day Details'),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // Date
          Text(
            _formatDate(date),
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Your daily health summary',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF6B7280),
            ),
          ),

          const SizedBox(height: 25),

          // Progress Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F4F5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Text(
                  "Today's Progress",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),

                const SizedBox(height: 15),

                Text(
                  '$progress%',
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF167D8D),
                  ),
                ),

                const SizedBox(height: 12),

                LinearProgressIndicator(
                  value: progress / 100,
                  minHeight: 10,
                  borderRadius:
                  BorderRadius.circular(10),
                  backgroundColor: Colors.white,
                  valueColor:
                  const AlwaysStoppedAnimation<Color>(
                    Color(0xFF167D8D),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Water
          _buildInfoCard(
            icon: Icons.water_drop,
            title: 'Water',
            value: '$water / 8 glasses',
          ),

          const SizedBox(height: 12),

          // Sleep
          _buildInfoCard(
            icon: Icons.bed,
            title: 'Sleep',
            value:
            '${sleep.toStringAsFixed(1)} / 8 hours',
          ),

          const SizedBox(height: 25),

          const Text(
            'Activities',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),

          const SizedBox(height: 12),

          if (activities.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'No activities recorded.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            ),

          ...activities.map((activity) {
            final String name =
                activity['name'] ?? '';

            final int duration =
                activity['duration'] ?? 0;

            return Container(
              margin: const EdgeInsets.only(
                bottom: 10,
              ),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color:
                    Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    _getActivityIcon(name),
                    color:
                    const Color(0xFF167D8D),
                    size: 30,
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight:
                        FontWeight.bold,
                        color:
                        Color(0xFF1F2937),
                      ),
                    ),
                  ),

                  Text(
                    '$duration min',
                    style: const TextStyle(
                      fontSize: 15,
                      color:
                      Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color:
            Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F4F5),
              borderRadius:
              BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF167D8D),
              size: 28,
            ),
          ),

          const SizedBox(width: 15),

          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),

          const Spacer(),

          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  int _calculateProgress(
      int water,
      double sleep,
      List activities,
      ) {
    final int waterProgress =
    ((water / 8) * 33).round();

    final int sleepProgress =
    ((sleep / 8) * 33).round();

    final int activityProgress =
    activities.isNotEmpty ? 34 : 0;

    return (waterProgress +
        sleepProgress +
        activityProgress)
        .clamp(0, 100);
  }

  IconData _getActivityIcon(
      String activityName,
      ) {
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

  String _formatDate(String date) {
    final parts = date.split('-');

    if (parts.length != 3) {
      return date;
    }

    final year = parts[0];
    final month = int.parse(parts[1]);
    final day = int.parse(parts[2]);

    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[month - 1]} $day, $year';
  }
}