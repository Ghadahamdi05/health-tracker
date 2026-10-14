import 'package:flutter/material.dart';

class WaterCard extends StatelessWidget {
  final int waterCount;
  final VoidCallback onAddWater;
  final int waterGoal;

  const WaterCard({
    super.key,
    required this.waterCount,
    required this.waterGoal,
    required this.onAddWater,
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
            child: const Icon(Icons.water_drop, color: Colors.white, size: 30),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Water Intake',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  '$waterCount / 8 glasses',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: onAddWater,
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
