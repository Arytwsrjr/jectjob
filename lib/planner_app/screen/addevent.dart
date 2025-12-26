import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:planner/service/firestore.dart';
import '../details/event.dart';

String formatDate(DateTime date) {
  return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
}

class AddEventPage extends StatefulWidget {
  final DateTime selectedDate;
  final String? eventId; // ถ้ามี = โหมดแก้ไข

  const AddEventPage({
    super.key,
    required this.selectedDate,
    this.eventId,
  });

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  bool _addToTodoList = false; // ใช้ตอน Add อย่างเดียว
  bool _loadingEdit = false;

  // ✅ NEW: type state (ห้ามอยู่ใน Widget)
  String _eventType = "personal"; // เปลี่ยนเป็น "other" ได้ถ้าไม่ชอบ personal

  bool get _isEdit => widget.eventId != null && widget.eventId!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    if (_isEdit) _loadEventForEdit();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  int _asInt(dynamic v, int fallback) {
    if (v == null) return fallback;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return fallback;
  }

  Future<void> _loadEventForEdit() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _loadingEdit = true);

    try {
      final dateId = formatDate(widget.selectedDate);
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('events')
          .doc(dateId)
          .collection('daily_events')
          .doc(widget.eventId)
          .get();

      if (!doc.exists) return;

      final data = doc.data() as Map<String, dynamic>;

      _titleController.text = (data['title'] ?? '').toString();
      _locationController.text = (data['location'] ?? '').toString();

      _startTime = TimeOfDay(
        hour: _asInt(data['startHour'], 0),
        minute: _asInt(data['startMinute'], 0),
      );

      _endTime = TimeOfDay(
        hour: _asInt(data['endHour'], 0),
        minute: _asInt(data['endMinute'], 0),
      );

      // ✅ NEW: โหลด type ของ event (กัน null ด้วย fallback)
      _eventType = (data['type'] ?? 'personal').toString();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Load event failed: $e")),
      );
    } finally {
      if (mounted) setState(() => _loadingEdit = false);
    }
  }

  Future<void> pickStartTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );
    if (time != null) setState(() => _startTime = time);
  }

  Future<void> pickEndTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _endTime ?? TimeOfDay.now(),
    );
    if (time != null) setState(() => _endTime = time);
  }

  // ✅ type chip UI
  Color _typeBg(String t, bool selected) {
    if (!selected) return const Color(0xFFF2F2F2);
    switch (t) {
      case "subject":
        return const Color(0xFFDCEBFF); // ฟ้าพาสเทล
      case "personal":
        return const Color(0xFFFFE3EC); // ชมพูพาสเทล
      case "other":
        return const Color(0xFFE8F7E6); // เขียวพาสเทล
      default:
        return const Color(0xFFEFEFEF);
    }
  }

  Color _typeText(String t, bool selected) {
    if (!selected) return Colors.black54;
    switch (t) {
      case "subject":
        return const Color(0xFF1E4E8C);
      case "personal":
        return const Color(0xFF8A2F55);
      case "other":
        return const Color(0xFF1F6B3A);
      default:
        return Colors.black87;
    }
  }

  String _typeLabel(String t) {
    switch (t) {
      case "subject":
        return "Subject";
      case "personal":
        return "Personal";
      case "other":
        return "Other";
      default:
        return t;
    }
  }

  Widget _typeChoice(String value) {
    final selected = _eventType == value;
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () => setState(() => _eventType = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: _typeBg(value, selected),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? _typeText(value, selected) : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Text(
          _typeLabel(value),
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: _typeText(value, selected),
          ),
        ),
      ),
    );
  }

  Future<void> saveEvent() async {
    if (_titleController.text.trim().isEmpty ||
        _startTime == null ||
        _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all required fields")),
      );
      return;
    }

    try {
      // ✅ EDIT MODE
      if (_isEdit) {
        await _firestoreService.updateEvent(
          date: widget.selectedDate,
          eventId: widget.eventId!,
          title: _titleController.text.trim(),
          startTime: _startTime!,
          endTime: _endTime!,
          location: _locationController.text.trim().isEmpty
              ? null
              : _locationController.text.trim(),
          type: _eventType, // ✅ NEW
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Event updated successfully"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
        return;
      }

      // ✅ ADD MODE
      final newEvent = Event(
        title: _titleController.text.trim(),
        startTime: _startTime!,
        endTime: _endTime!,
        location: _locationController.text.trim().isNotEmpty
            ? _locationController.text.trim()
            : null,
        id: '',
        type: _eventType, // ✅ NEW
      );

      await _firestoreService.addEvent(
        widget.selectedDate,
        newEvent,
        addToTodo: _addToTodoList,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Event saved successfully" +
                (_addToTodoList ? " and added to To-Do List." : ""),
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to save: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? "Edit Event" : "Add Event"),
        backgroundColor: const Color.fromARGB(255, 205, 170, 225),
      ),
      body: _loadingEdit
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Container(
                    width: 220,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 203, 163, 210),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.only(left: 18, top: 8, bottom: 8),
                    child: Text(
                      "Date: ${formatDate(widget.selectedDate)}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: "Event title",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ✅ NEW: type selector (3 options)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Type",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _typeChoice("subject"),
                      _typeChoice("personal"),
                      _typeChoice("other"),
                    ],
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(
                        Icons.location_on_rounded,
                        color: Color.fromARGB(255, 60, 73, 44),
                      ),
                      hintText: "Location",
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (!_isEdit)
                    CheckboxListTile(
                      title: const Text("Add to To-Do List"),
                      value: _addToTodoList,
                      onChanged: (v) =>
                          setState(() => _addToTodoList = v ?? false),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),

                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _startTime == null
                            ? "Start : --:--"
                            : "Start : ${_startTime!.format(context)}",
                        style: const TextStyle(fontSize: 16),
                      ),
                      ElevatedButton(
                        onPressed: pickStartTime,
                        child: const Text("Pick Start"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _endTime == null
                            ? "End : --:--"
                            : "End : ${_endTime!.format(context)}",
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
                      onPressed: saveEvent,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 168, 209, 243),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 14,
                        ),
                      ),
                      child: Text(
                        _isEdit ? "Update" : "Save",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
