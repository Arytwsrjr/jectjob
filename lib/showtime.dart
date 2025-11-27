import 'package:flutter/material.dart';

import 'planner_app/details/detail.dart';

Future<Task?> showAddTaskDialog(BuildContext context) async {
  TextEditingController titleController = TextEditingController();
  TimeOfDay? selectedTime;

  return showDialog<Task>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Add Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Task Title'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              child: Text(selectedTime == null
                  ? 'Pick Time'
                  : selectedTime!.format(context)),
              onPressed: () async {
                TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (picked != null) {
                  selectedTime = picked;
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text('Add'),
            onPressed: () {
              if (titleController.text.isNotEmpty && selectedTime != null) {
                Navigator.pop(
                  context,
                  Task(title: titleController.text, time: selectedTime!),
                );
              }
            },
          ),
        ],
      );
    },
  );
}
