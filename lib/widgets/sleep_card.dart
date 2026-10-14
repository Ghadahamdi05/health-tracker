import 'package:flutter/material.dart';

class SleepCard extends StatelessWidget {
  final double sleepHours;
  final VoidCallback onAddSleep;
  final double sleepGoal;

  const SleepCard({
    super.key,
    required this.sleepHours,
    required this.onAddSleep,
    required this.sleepGoal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F4F5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF167D8D),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.bed, color: Colors.white, size: 30),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sleep',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  '${sleepHours.toStringAsFixed(1)} / 8 hours',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: onAddSleep,
            icon: const Icon(
              Icons.add_circle,
              color: Color(0xFF167D8D),
              size: 35,
            ),
          ),
        ],
      ),
    );
  }
}
