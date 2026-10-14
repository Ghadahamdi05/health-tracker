import 'package:flutter/material.dart';
import '../models/activity.dart';

class AddActivityScreen extends StatefulWidget {
  const AddActivityScreen({super.key});

  @override
  State<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  String selectedActivity = 'Running';

  final TextEditingController durationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Activity')),

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

                  final activity = Activity(
                    name: selectedActivity,
                    duration: int.parse(durationController.text),
                  );

                  Navigator.pop(context, activity);
                },

                child: const Padding(
                  padding: EdgeInsets.all(15),

                  child: Text('SAVE ACTIVITY', style: TextStyle(fontSize: 18)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
