import 'package:flutter/material.dart';
import 'package:planner/planner_app/screen/focus.dart';
import 'package:planner/planner_app/screen/sum.dart';
import 'package:table_calendar/table_calendar.dart';

import '../details/event.dart'; // หรือ 'package:planner/screens/details/event.dart'

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // --- ขั้นตอนที่ 2: เพิ่ม State สำหรับติดตาม Tab ที่เลือก ---
  int _selectedIndex = 0;

  final Map<DateTime, List<Event>> _events = {};

  List<Event> _getEventsForDay(DateTime day) {
    DateTime normalizedDay = DateTime.utc(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  void _showAddEventDialog() async {
    // ... (โค้ดส่วนนี้เหมือนเดิม ไม่มีการเปลี่ยนแปลง)
    final titleController = TextEditingController();
    TimeOfDay? selectedTime;

    if (_selectedDay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a day first')),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Event'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(hintText: 'Event Title'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(selectedTime == null
                          ? 'No time selected'
                          : 'Time: ${selectedTime!.format(context)}'),
                      TextButton(
                        onPressed: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (picked != null) {
                            setDialogState(() => selectedTime = picked);
                          }
                        },
                        child: const Text('Select Time'),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (titleController.text.isEmpty || selectedTime == null) {
                      return;
                    }

                    final newEvent = Event(
                      title: titleController.text,
                      time: selectedTime!,
                    );

                    final normalizedDay = DateTime.utc(_selectedDay!.year,
                        _selectedDay!.month, _selectedDay!.day);

                    setState(() {
                      if (_events[normalizedDay] != null) {
                        _events[normalizedDay]!.add(newEvent);
                      } else {
                        _events[normalizedDay] = [newEvent];
                      }
                      _events[normalizedDay]!.sort((a, b) {
                        final aDateTime =
                            DateTime(0, 0, 0, a.time.hour, a.time.minute);
                        final bDateTime =
                            DateTime(0, 0, 0, b.time.hour, b.time.minute);
                        return aDateTime.compareTo(bDateTime);
                      });
                    });

                    Navigator.of(context).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Widget สำหรับสร้างหน้าปฏิทิน (แยกออกมาเพื่อความเรียบร้อย)
  Widget _buildCalendarPage() {
    return Column(
      children: [
        // --- ปรับปรุงสไตล์ของ TableCalendar ให้เหมือนในรูป ---
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TableCalendar(
            calendarStyle: CalendarStyle(
              // สไตล์ของวันที่ถูกเลือก
              selectedDecoration: BoxDecoration(
                color: Colors.pink[100],
                shape: BoxShape.circle,
              ),
              // สไตล์ของวันนี้
              todayDecoration: BoxDecoration(
                color: Colors.blue[200],
                shape: BoxShape.circle,
              ),
              defaultTextStyle: const TextStyle(fontWeight: FontWeight.bold),
              weekendTextStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle:
                  TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              leftChevronIcon: Icon(Icons.chevron_left, color: Colors.blue),
              rightChevronIcon: Icon(Icons.chevron_right, color: Colors.blue),
            ),
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: _getEventsForDay,
          ),
        ),
        const Divider(),
        Expanded(
          child: ListView.builder(
            itemCount: _selectedDay != null
                ? _getEventsForDay(_selectedDay!).length
                : 0,
            itemBuilder: (context, index) {
              final event = _getEventsForDay(_selectedDay!)[index];
              return Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: ListTile(
                  leading: Text(event.time.format(context),
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  title: Text(event.title),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // สร้าง List ของหน้าต่างๆ ที่จะแสดงผลตาม Tab ที่เลือก
  // ตอนนี้หน้าอื่นๆ จะเป็นแค่ Placeholder
  List<Widget> _pages() => [
        _buildCalendarPage(), // หน้าปฏิทินคือหน้าแรก (index 0)
        const Center(child: Text('Time table')),
        const Center(child: Text('To-do List Page')),
        const Center(child: Text('Sleep Time Page')),
        const FocusPage(),
        const Center(child: Text('AI Planner Page')),
      ];

  @override
  Widget build(BuildContext context) {
    // ดึง list ของ pages มาใช้
    final pages = _pages();

    return Scaffold(
      backgroundColor: Colors.grey[50], // สีพื้นหลังอ่อนๆ
      // --- เปลี่ยน AppBar เป็น Custom Header แบบในรูป ---
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100.0),
        child: _buildCustomHeader(),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEventDialog,
        backgroundColor: Colors.blue[300],
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),

      // แสดงผลหน้าตาม _selectedIndex
      body: pages[_selectedIndex],

      // --- ขั้นตอนที่ 1: สร้าง Custom Bottom Navigation Bar ---
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildCustomHeader() {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 40, bottom: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF56CCF2),
        // ถ้าต้องการ header โค้งๆ สามารถใช้ CustomClipper ได้
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Good Morning, LEXJEED',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          GestureDetector(
              // 3. ใส่โค้ด Navigation ใน onTap
              onTap: () {
                print(
                    'Profile picture tapped!'); // สำหรับเช็คใน console ว่ากดได้
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Sumerize()),
                );
              },
              child: CircleAvatar(
                radius: 25,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  // Placeholder
                  child: Image.asset(
                      '/Users/_arytwsrjr/jecteeraoruk/planner/assets/image/yuji.jpg'),
                ),
              ))
        ],
      ),
    );
  }

  // Widget สำหรับสร้าง Bottom Navigation Bar
  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        //boxShadow: [
        // BoxShadow(
        //   color: Colors.grey.withOpacity(0.2),
        //   spreadRadius: 5,
        //   blurRadius: 10,
        // ),
        //],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          // --- ขั้นตอนที่ 3 & 4: กำหนดไอคอนและสไตล์ ---
          type: BottomNavigationBarType.fixed, // ทำให้เห็น label ทั้งหมด
          backgroundColor: Colors.transparent, // ทำให้สีของ Container แสดงผล
          elevation: 0, // เอาเงาของ BottomNavBar ออก
          selectedItemColor: Colors.blue, // สีของไอคอนและข้อความที่เลือก
          unselectedItemColor:
              Colors.grey, // สีของไอคอนและข้อความที่ยังไม่เลือก
          showUnselectedLabels: true, // แสดงข้อความของ Tab ที่ยังไม่เลือก
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.table_chart_outlined),
              label: 'time table',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt_outlined),
              label: 'to-do list',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bedtime_outlined),
              label: 'sleep time',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.mobile_off_outlined), // ไอคอนใกล้เคียง
              label: 'focus',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calculate_outlined),
              label: 'ai planner',
            ),
          ],
        ),
      ),
    );
  }
}
