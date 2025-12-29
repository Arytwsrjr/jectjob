import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // <-- เพิ่ม import นี้สำหรับจัดรูปแบบวันที่
import 'package:planner/service/firestore.dart';
import 'package:planner/planner_app/screen/home.dart';


class Todolist extends StatefulWidget {
  const Todolist({super.key});

  @override
  State<Todolist> createState() => _TodolistState();
}

class _TodolistState extends State<Todolist> {
  final FirestoreService _firestoreService = FirestoreService();

  // --- 1. เพิ่ม State สำหรับเก็บเดือนที่กำลังแสดงผล ---
  late DateTime _displayedMonth;

  @override
  void initState() {
    super.initState();
    // กำหนดให้เดือนเริ่มต้นเป็นเดือนปัจจุบัน
    _displayedMonth = DateTime.now();
  }

  // --- 2. สร้างฟังก์ชันสำหรับเปลี่ยนเดือน ---
  void _goToPreviousMonth() {
    setState(() {
      _displayedMonth =
          DateTime(_displayedMonth.year, _displayedMonth.month - 1, 1);
    });
  }

  void _goToNextMonth() {
    setState(() {
      _displayedMonth =
          DateTime(_displayedMonth.year, _displayedMonth.month + 1, 1);
    });
  }

Future<void> _deleteTodoAndNotifyParent(String todoId) async {
  try {
    final deletedEventDay = await _firestoreService.deleteTodo(todoId);

    if (deletedEventDay != null) {
      pendingRemovedDaysFromTodo.add(DateTime(
        deletedEventDay.year,
        deletedEventDay.month,
        deletedEventDay.day,
      ));
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Deleted successfully")),
    );
    setState(() {});
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Deleted failed: $e")),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  backgroundColor: const Color.fromARGB(255, 244, 227, 137),
  elevation: 0,
  title: const Text('To-Do List'),
  centerTitle: true,
  automaticallyImplyLeading: false, // ✅ สำคัญ: ไม่ต้องมีปุ่ม back
),

      body: Column(
        children: [
          // --- 3. เปลี่ยนส่วนแสดงเดือนให้เป็นแบบไดนามิก ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _goToPreviousMonth,
                ),
                Text(
                  // ใช้ intl เพื่อแสดงชื่อเดือนและปีให้สวยงาม
                  DateFormat('MMMM yyyy').format(_displayedMonth),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _goToNextMonth,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // --- 4. แก้ไข StreamBuilder ให้ใช้เมธอดใหม่ ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // ใช้ stream ใหม่ที่กรองข้อมูลตามเดือน
              stream: _firestoreService.getTodosStreamForMonth(_displayedMonth),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Something went wrong: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'ไม่มีกิจกรรมในเดือนนี้',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                final todos = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: todos.length,
                  itemBuilder: (context, index) {
                    final todoDoc = todos[index];
                    final docID = todoDoc.id;
                    final todoData = todoDoc.data() as Map<String, dynamic>;

                    final String title = todoData['title'];
                    final bool isCompleted = todoData['isCompleted'];
                    // --- 5. ดึงข้อมูล deadline มาใช้ ---
                    final DateTime deadline =
                        (todoData['deadline'] as Timestamp).toDate();
                    (todoData['type'] ?? 'todo').toString();

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color:
                            isCompleted ? Colors.grey.shade300 : Colors.amber,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        onTap: () {
                          _firestoreService.updateTodoStatus(
                              docID, !isCompleted);
                        },
                        leading: isCompleted
                            ? const Icon(Icons.check_circle,
                                color: Colors.black)
                            : const Icon(Icons.circle_outlined,
                                color: Colors.white),
                        title: Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        
                        // --- 6. แสดงผล deadline ---
                        subtitle: Text(
                          // จัดรูปแบบวันที่ให้สวยงาม
                          'Deadline: ${DateFormat('d MMMM yyyy').format(deadline)}',
                          style: TextStyle(
                            color: isCompleted
                                ? Colors.black54
                                : Colors.red.shade700,
                            fontSize: 13,
                          ),
                        ),
                        trailing: IconButton(
  icon: const Icon(Icons.delete_outline),
  onPressed: () => _deleteTodoAndNotifyParent(docID),
),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
