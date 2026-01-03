import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:planner/planner_app/details/event.dart';
import 'package:planner/planner_app/screen/addevent.dart';
import 'package:planner/planner_app/screen/focus.dart';
import 'package:planner/planner_app/screen/timetable.dart';
import 'package:planner/planner_app/screen/sum.dart';
import 'package:planner/planner_app/screen/todolist.dart';
import 'package:planner/planner_app/screen/ai_planner.dart';
import 'package:planner/service/firestore.dart';
import 'package:table_calendar/table_calendar.dart';

// ✅ ADD: ตัวกลาง (ไม่ต้องสร้างไฟล์ใหม่)
// Todolist จะ "ฝากวัน" ที่ลบ event ไว้ที่นี่
final Set<DateTime> pendingRemovedDaysFromTodo = <DateTime>{};

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FirestoreService _firestoreService = FirestoreService();

  int _selectedIndex = 0;

  List<Widget> _pages() => [
        _buildCalendarPage(),
        const TimetableScreen(),
        const Todolist(),
        const Center(child: Text('Sleep Time Page')),
        const FocusPage(),
        const AiPlannerPage(),
      ];

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  //Map<DateTime, List<Event>> _monthEvents = {};
  Set<DateTime> _cachedDaysWithEvents = {};

  // ✅ ADD: เปิดหน้าแก้ไข
  Future<void> _editEvent(Event event) async {
    if (FirebaseAuth.instance.currentUser == null) return;
    // ignore: unnecessary_null_comparison
    if (event.id == null || event.id.isEmpty) return;

    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddEventPage(
          selectedDate: _selectedDay,
          eventId: event.id, // ✅ ส่ง id เข้าไปเพื่อแก้ไข
        ),
      ),
    );

    if (changed == true && mounted) setState(() {});
  }

  void _deleteEvent(Event event) async {
    if (FirebaseAuth.instance.currentUser == null) return;

    try {
      await _firestoreService.deleteEvent(event.id, _selectedDay);

      final stillHasEvents =
          await _firestoreService.hasEventsOnDay(_selectedDay);

      if (!stillHasEvents) {
        final k = _dateOnly(_selectedDay);
        _cachedDaysWithEvents = {..._cachedDaysWithEvents}..remove(k);
      }

      if (mounted) setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Event deleted successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to delete event: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatSelectedDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  Widget _buildCalendarPage() {
    if (FirebaseAuth.instance.currentUser == null) {
      return const Center(child: Text("Please sign in to view your calendar."));
    }

    final eventsStream = _firestoreService.getEventsForDay(_selectedDay);

    final monthStart = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final monthEnd = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
    final daysWithEventsStream =
        _firestoreService.getEventsInRange(monthStart, monthEnd);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: StreamBuilder<Set<DateTime>>(
              stream: daysWithEventsStream,
              builder: (context, snap) {
                if (snap.hasData) _cachedDaysWithEvents = snap.data!;

                final daysWithEvents =
                    (snap.hasError || !snap.hasData)
                        ? _cachedDaysWithEvents
                        : snap.data!;

                return TableCalendar(
                  eventLoader: (day) {
                    final key = _dateOnly(day);
                    return daysWithEvents.contains(key) ? [1] : [];
                  },
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, day, events) {
                      if (events.isEmpty) return const SizedBox.shrink();
                      return Positioned(
                        bottom: 6,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                          ),
                        ),
                      );
                    },
                  ),
                  calendarStyle: CalendarStyle(
                    selectedDecoration: BoxDecoration(
                      color: Colors.pink[100],
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: Colors.blue[200],
                      shape: BoxShape.circle,
                    ),
                    defaultTextStyle:
                        const TextStyle(fontWeight: FontWeight.bold),
                    weekendTextStyle:
                        const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                    leftChevronIcon:
                        Icon(Icons.chevron_left, color: Colors.blue),
                    rightChevronIcon:
                        Icon(Icons.chevron_right, color: Colors.blue),
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
                  calendarFormat: _calendarFormat,
                  onFormatChanged: (format) =>
                      setState(() => _calendarFormat = format),
                  onPageChanged: (focusedDay) =>
                      setState(() => _focusedDay = focusedDay),
                );
              },
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              'Events on ${_formatSelectedDate(_selectedDay)}:',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Event>>(
              stream: eventsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final events = snapshot.data ?? [];
                if (events.isEmpty) {
                  return const Center(
                    child: Text("No events scheduled for this day."),
                  );
                }

                return ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];

                    return Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Text(
                          "${event.startTime.format(context)}\n${event.endTime.format(context)}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        title: Text(event.title),
                        subtitle: (event.location ?? '').trim().isNotEmpty
                            ? Text('Location: ${event.location}')
                            : null,

                        // ✅ CHANGE: มี edit + delete
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editEvent(event),
                            ),
                            IconButton(
                              icon:
                                  const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteEvent(event),
                            ),
                          ],
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final changed = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => AddEventPage(selectedDate: _selectedDay),
            ),
          );
          if (changed == true && mounted) setState(() {});
        },
        backgroundColor: Colors.blue[300],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCustomHeader() {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 40, bottom: 10),
      decoration: const BoxDecoration(color: Color(0xFF56CCF2)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Good Morning, HelloWorld',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Sumerize()),
              );
            },
            child: CircleAvatar(
              radius: 25,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  '/Users/_arytwsrjr/jecteeraoruk/planner/assets/image/yuji.jpg',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            if (index == 0 && pendingRemovedDaysFromTodo.isNotEmpty) {
              final removedDays = {...pendingRemovedDaysFromTodo};
              pendingRemovedDaysFromTodo.clear();

              final newCache = {..._cachedDaysWithEvents};
              for (final d in removedDays) {
                newCache.remove(_dateOnly(d));
              }
              _cachedDaysWithEvents = newCache;
            }

            setState(() => _selectedIndex = index);
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.table_chart_outlined), label: 'time table'),
            BottomNavigationBarItem(
                icon: Icon(Icons.list_alt_outlined), label: 'to-do list'),
            BottomNavigationBarItem(
                icon: Icon(Icons.bedtime_outlined), label: 'sleep time'),
            BottomNavigationBarItem(
                icon: Icon(Icons.mobile_off_outlined), label: 'focus'),
            BottomNavigationBarItem(
                icon: Icon(Icons.calculate_outlined), label: 'ai planner'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser == null) {
      return const Scaffold(
        body: Center(child: Text("Please sign in to access the planner.")),
      );
    }

    final pages = _pages();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100.0),
        child: _buildCustomHeader(),
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }
}
