import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController waterController =
  TextEditingController();

  final TextEditingController sleepController =
  TextEditingController();

  int waterGoal = 8;
  double sleepGoal = 8;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  @override
  void dispose() {
    waterController.dispose();
    sleepController.dispose();
    super.dispose();
  }

  Future<void> _loadGoals() async {
    final prefs = SharedPreferencesAsync();

    final savedWater =
        await prefs.getInt('waterGoal') ?? 8;

    final savedSleep =
        await prefs.getDouble('sleepGoal') ?? 8.0;

    if (!mounted) return;

    setState(() {
      waterGoal = savedWater;
      sleepGoal = savedSleep;
      waterController.text = waterGoal.toString();
      sleepController.text = sleepGoal.toString();
      isLoading = false;
    });
  }

  Future<void> _saveGoals() async {
    final int? water =
    int.tryParse(waterController.text);

    final double? sleep =
    double.tryParse(sleepController.text);

    if (water == null ||
        water < 1 ||
        water > 30 ||
        sleep == null ||
        sleep <= 0 ||
        sleep > 24) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enter a valid water goal (1–30) and sleep goal (0–24).',
          ),
        ),
      );
      return;
    }

    final prefs = SharedPreferencesAsync();

    await prefs.setInt('waterGoal', water);
    await prefs.setDouble('sleepGoal', sleep);

    if (!mounted) return;

    setState(() {
      waterGoal = water;
      sleepGoal = sleep;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Goals saved successfully!'),
      ),
    );

    Navigator.pop(context, true);
  }

  Future<void> _resetGoals() async {
    final prefs = SharedPreferencesAsync();

    await prefs.setInt('waterGoal', 8);
    await prefs.setDouble('sleepGoal', 8.0);

    if (!mounted) return;

    setState(() {
      waterGoal = 8;
      sleepGoal = 8;
      waterController.text = '8';
      sleepController.text = '8';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Goals reset to default values.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(
            Icons.tune,
            size: 60,
            color: Color(0xFF167D8D),
          ),
          const SizedBox(height: 12),
          const Text(
            'Personal Goals',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Customize your daily health targets.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 30),
          _buildGoalCard(
            icon: Icons.water_drop,
            title: 'Daily Water Goal',
            description: 'Number of glasses per day',
            controller: waterController,
            suffix: 'glasses',
          ),
          const SizedBox(height: 18),
          _buildGoalCard(
            icon: Icons.bed,
            title: 'Daily Sleep Goal',
            description: 'Hours of sleep per day',
            controller: sleepController,
            suffix: 'hours',
          ),
          const SizedBox(height: 25),
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _saveGoals,
              icon: const Icon(Icons.save),
              label: const Text(
                'SAVE GOALS',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _resetGoals,
            icon: const Icon(Icons.restart_alt),
            label: const Text('Reset to Defaults'),
          ),
          const SizedBox(height: 25),
          const Text(
            'Default goals: 8 glasses of water and 8 hours of sleep.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard({
    required IconData icon,
    required String title,
    required String description,
    required TextEditingController controller,
    required String suffix,
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
          Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFF167D8D),
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration: InputDecoration(
              suffixText: suffix,
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}