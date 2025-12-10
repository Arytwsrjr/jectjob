import 'package:flutter/material.dart';

import '../details/event.dart';

String formatDate(DateTime date) {
  return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
}

class AddEventPage extends StatefulWidget {
  final DateTime selectedDate;

  const AddEventPage({super.key, required this.selectedDate});

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final TextEditingController _titleController = TextEditingController();
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  Future<void> pickStartTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() => _startTime = time);
    }
  }

  Future<void> pickEndTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() => _endTime = time);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Event"),
        backgroundColor: const Color.fromARGB(255, 205, 170, 225),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 20,
            ),
            Container(
              width: 200,
              decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 203, 163, 210),
                  borderRadius: BorderRadius.circular(10)),
              padding: EdgeInsets.only(left: 18),
              child: Text(
                "Date: ${formatDate(widget.selectedDate)}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 30),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: "Event title",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 30),
            Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.location_on_rounded,
                        color: const Color.fromARGB(255, 60, 73, 44),
                      ),
                      hintText: "Location"),
                )
              ],
            ),
            SizedBox(
              height: 50,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _startTime == null
                      ? "Start : --:--"
                      : "Time: ${_startTime!.format(context)}",
                  style: const TextStyle(fontSize: 16),
                ),
                ElevatedButton(
                  onPressed: pickStartTime,
                  child: const Text("Start"),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _endTime == null
                      ? "End: --:--"
                      : "End: ${_endTime!.format(context)}",
                  style: const TextStyle(fontSize: 16),
                ),
                ElevatedButton(
                  onPressed: pickEndTime,
                  child: const Text("Pick End"),
                ),
              ],
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (_titleController.text.isEmpty ||
                      _startTime == null ||
                      _endTime == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please fill all fields"),
                      ),
                    );
                    return;
                  }

                  final newEvent = Event(
                    title: _titleController.text,
                    startTime: _startTime!,
                    endTime: _endTime!,
                  );

                  Navigator.pop(context, newEvent);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 168, 209, 243),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 14,
                  ),
                ),
                child: const Text(
                  "Save",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
