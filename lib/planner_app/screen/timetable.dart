import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  _TimetableScreenState createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  final _subjectController = TextEditingController();
  final _codeController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  //String? _selectedDay;

  String get _formattedDate => DateFormat('EEEE').format(_selectedDate);
//ถอยกลับมา
  void _previousDay() {
    setState(() {
      _selectedDate = _selectedDate.subtract(Duration(days: 1));
    });
  }

//กดวันต่อไป
  void _nextDay() {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: 1));
    });
  }

  //เลือกเวลา
  Future<void> _selectTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

//save วิชานั้น
  Future<void> _saveSubject() async {
    final user = FirebaseAuth.instance.currentUser;
    final subject = _subjectController.text;
    final code = _codeController.text;
    final start = _startTime != null
        ? '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}'
        : null;

    final end = _endTime != null
        ? '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}'
        : null;

    if (subject.isNotEmpty &&
        code.isNotEmpty &&
        start != null &&
        end != null &&
        user != null) {
      await FirebaseFirestore.instance.collection('subjects').add({
        'subject': subject,
        'code': code,
        'day': _formattedDate,
        'start': start,
        'end': end,
        'uid': user.uid,
        'color': Colors
            .primaries[DateTime.now().second % Colors.primaries.length].value,
      });

      _subjectController.clear();
      _codeController.clear();
      setState(() {
        _startTime = null;
        _endTime = null;
      });
      Navigator.pop(context);
    }
  }

//หน้ารายละเีอยดเพิ่มวิชา
  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add Subject"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _subjectController,
                decoration: InputDecoration(labelText: "Subject Name"),
              ),
              TextField(
                controller: _codeController,
                decoration: InputDecoration(labelText: "Subject Code"),
              ),
              SizedBox(height: 16),
              ListTile(
                title: Text(_startTime == null
                    ? "Select Start Time"
                    : "Start: ${_startTime!.format(context)}"),
                trailing: IconButton(
                  icon: Icon(Icons.access_time),
                  onPressed: () => _selectTime(true),
                ),
              ),
              ListTile(
                title: Text(_endTime == null
                    ? "Select End Time"
                    : "End: ${_endTime!.format(context)}"),
                trailing: IconButton(
                  icon: Icon(Icons.access_time),
                  onPressed: () => _selectTime(false),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: _saveSubject,
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

//ลบข้อมูลวันนันทั้งหมด
  Future<void> _resetDaySubjects() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset This Day'),
        content: Text(
            'Are you sure you want to delete all subjects for $_formattedDate?'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: Text('Delete All', style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('subjects')
        .where('uid', isEqualTo: user.uid)
        .where('day', isEqualTo: _formattedDate)
        .get();

    final batch = FirebaseFirestore.instance.batch();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('All subjects for $_formattedDate have been deleted.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Timetable',
            style: TextStyle(color: const Color.fromARGB(221, 255, 255, 255))),
        backgroundColor: const Color.fromARGB(255, 210, 210, 210),
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_forever, color: Colors.redAccent),
            onPressed: _resetDaySubjects,
            tooltip: 'Reset this day',
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(25),
            bottomRight: Radius.circular(25),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: _previousDay,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _formattedDate.toUpperCase(),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward_ios),
                  onPressed: _nextDay,
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('subjects')
                  .where('day', isEqualTo: _formattedDate)
                  .where('uid', isEqualTo: user?.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final entries = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return TimetableEntry(
                    startTime: data['start']?.toString() ?? '00:00',
                    endTime: data['end']?.toString() ?? '00:00',
                    subjectCode: data['code']?.toString() ?? 'No Code',
                    details: data['subject']?.toString() ?? 'No Subject',
                    color: Color((data['color'] ?? Colors.grey) as int),
                  );
                }).toList();

                // แยกก่อนเที่ยงและหลังเที่ยง
                final morningEntries = entries.where((e) {
                  final hour = _parseHour(e.startTime);
                  return hour < 12;
                }).toList();

                final afternoonEntries = entries.where((e) {
                  final hour = _parseHour(e.startTime);
                  return hour >= 12;
                }).toList();

                // เรียงเวลา
                morningEntries.sort((a, b) =>
                    _parseHour(a.startTime).compareTo(_parseHour(b.startTime)));
                afternoonEntries.sort((a, b) =>
                    _parseHour(a.startTime).compareTo(_parseHour(b.startTime)));

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  children: [
                    _buildTimeSlot(entries: morningEntries),
                    SizedBox(height: 16),
                    _buildLunchSlot(),
                    SizedBox(height: 16),
                    _buildTimeSlot(entries: afternoonEntries),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildTimeSlot({required List<TimetableEntry> entries}) {
    return Column(
      children: entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 80,
                child: Column(
                  children: [
                    SizedBox(height: 25),
                    Text(
                      '${entry.startTime}\n-\n${entry.endTime}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 20),
                    decoration: BoxDecoration(
                      color: entry.color,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(2, 2),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.details,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          entry.subjectCode,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLunchSlot() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.pink[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          'LUNCH',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
        ),
      ),
    );
  }
}

class TimetableEntry {
  final String startTime;
  final String endTime;
  final String subjectCode;
  final String details;
  final Color color;

  TimetableEntry({
    required this.startTime,
    required this.endTime,
    required this.subjectCode,
    required this.details,
    required this.color,
  });
}

//ฟังก์ชัน เวลาในรูปแบบ "HH:mm" และคืนค่าเป็นชั่วโมง (ใช้สำหรับการเรียงลำดับเวลา)
int _parseHour(String timeStr) {
  try {
    final format = DateFormat('HH:mm');
    final dateTime = format.parse(timeStr);
    return dateTime.hour;
  } catch (e) {
    return 0;
  }
}
