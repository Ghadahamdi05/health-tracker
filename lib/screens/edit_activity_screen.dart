import 'package:flutter/material.dart';
import '../models/activity.dart';

class EditActivityScreen extends StatefulWidget {
  final Activity activity;

  const EditActivityScreen({super.key, required this.activity});

  @override
  State<EditActivityScreen> createState() => _EditActivityScreenState();
}

class _EditActivityScreenState extends State<EditActivityScreen> {
  late String selectedActivity;
  late TextEditingController durationController;

  @override
  void initState() {
    super.initState();

    selectedActivity = widget.activity.name;

    durationController = TextEditingController(
      text: widget.activity.duration.toString(),
    );
  }

  @override
  void dispose() {
    durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Activity')),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              'Activity',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              initialValue: selectedActivity,

              decoration: const InputDecoration(border: OutlineInputBorder()),

              items: const [
                DropdownMenuItem(value: 'Running', child: Text('Running')),

                DropdownMenuItem(value: 'Walking', child: Text('Walking')),

                DropdownMenuItem(value: 'Cycling', child: Text('Cycling')),

                DropdownMenuItem(value: 'Swimming', child: Text('Swimming')),

                DropdownMenuItem(value: 'Gym', child: Text('Gym')),

                DropdownMenuItem(value: 'Yoga', child: Text('Yoga')),
              ],

              onChanged: (value) {
                setState(() {
                  selectedActivity = value!;
                });
              },
            ),

            const SizedBox(height: 30),

            const Text(
              'Duration (minutes)',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: durationController,

              keyboardType: TextInputType.number,

              decoration: const InputDecoration(
                hintText: 'Example: 30',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: () {
                  if (durationController.text.isEmpty) {
                    return;
                  }

                  final int? duration = int.tryParse(durationController.text);

                  if (duration == null || duration <= 0) {
                    return;
                  }

                  final updatedActivity = Activity(
                    name: selectedActivity,
                    duration: duration,
                  );

                  Navigator.pop(context, updatedActivity);
                },

                child: const Padding(
                  padding: EdgeInsets.all(15),

                  child: Text('SAVE CHANGES', style: TextStyle(fontSize: 18)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
