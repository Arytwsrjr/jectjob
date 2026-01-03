// ==============================
// lib/service/firestore.dart
// (โค้ดเต็ม เวอร์ชัน "แก้น้อยที่สุด" + ใช้งานได้จริง)
// ==============================
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:planner/planner_app/details/event.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String _getDateId(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  String? get _currentUid => FirebaseAuth.instance.currentUser?.uid;

  // =========================
  // Event Methods
  // =========================

  Future<void> addEvent(DateTime date, Event event,
      {bool addToTodo = true}) async {
    final uid = _currentUid;
    if (uid == null) throw Exception("User is not signed in.");

    final dateId = _getDateId(date);
    final dayOnly = _dayOnly(date);

    final eventRef = _db
        .collection('users')
        .doc(uid)
        .collection('events')
        .doc(dateId)
        .collection('daily_events')
        .doc();

    final eventId = eventRef.id;
    final eventMap = event.toMap();

    int _asInt(dynamic v, int fallback) {
      if (v == null) return fallback;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return fallback;
    }

    final endHour = _asInt(eventMap['endHour'], 23);
    final endMinute = _asInt(eventMap['endMinute'], 59);

    final todoDeadline = DateTime(
      dayOnly.year,
      dayOnly.month,
      dayOnly.day,
      endHour,
      endMinute,
    );

    final batch = _db.batch();

    // ✅ event เก็บ type ตาม eventMap ได้เลย
    batch.set(eventRef, {
      ...eventMap,
      'uid': uid,
      'date': Timestamp.fromDate(dayOnly),
      'todoId': addToTodo ? eventId : null,
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (addToTodo) {
      final todoRef =
          _db.collection('users').doc(uid).collection('todos').doc(eventId);

      // ✅ เปลี่ยนให้น้อยที่สุด:
      // - เก็บ type เป็น subject/personal/other (เอามาจาก event)
      // - เพิ่ม kind:'event' เพื่อยังรู้ว่า todo นี้ผูก event (ใช้ตอน deleteTodo)
      batch.set(todoRef, {
        'title': eventMap['title'] ?? 'Event',
        'isCompleted': false,
        'createdAt': FieldValue.serverTimestamp(),
        'deadline': Timestamp.fromDate(todoDeadline),

        'type': (eventMap['type'] ?? 'personal').toString(), // ✅ NEW
        'kind': 'event', // ✅ NEW (แทนการเช็ค type=='event')

        'eventId': eventId,
        'eventDate': Timestamp.fromDate(dayOnly),
        'eventDateId': dateId,
      });
    }

    await batch.commit();
  }

  Stream<List<Event>> getEventsForDay(DateTime date) {
    final uid = _currentUid;
    if (uid == null) return Stream.value([]);

    final dateId = _getDateId(date);

    return _db
        .collection('users')
        .doc(uid)
        .collection('events')
        .doc(dateId)
        .collection('daily_events')
        .orderBy('startHour')
        .orderBy('startMinute')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Event.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<bool> hasEventsOnDay(DateTime date) async {
    final uid = _currentUid;
    if (uid == null) return false;

    final dateId = _getDateId(date);

    final snap = await _db
        .collection('users')
        .doc(uid)
        .collection('events')
        .doc(dateId)
        .collection('daily_events')
        .limit(1)
        .get();

    return snap.docs.isNotEmpty;
  }

  Future<void> updateEvent({
    required DateTime date,
    required String eventId,
    required String title,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    String? location,

    // ✅ NEW
    required String type, // subject/personal/other
  }) async {
    final uid = _currentUid;
    if (uid == null) throw Exception("User is not signed in.");

    final dayOnly = _dayOnly(date);
    final dateId = _getDateId(dayOnly);

    final eventRef = _db
        .collection('users')
        .doc(uid)
        .collection('events')
        .doc(dateId)
        .collection('daily_events')
        .doc(eventId);

    final snap = await eventRef.get();
    if (!snap.exists) throw Exception("Event not found");

    final data = snap.data() as Map<String, dynamic>;
    final todoId = data['todoId'] as String?;

    final safeType = type.trim().isEmpty ? 'personal' : type.trim();

    final eventUpdate = <String, dynamic>{
      'title': title,
      'startHour': startTime.hour,
      'startMinute': startTime.minute,
      'endHour': endTime.hour,
      'endMinute': endTime.minute,
      'location': (location == null || location.trim().isEmpty)
          ? null
          : location.trim(),

      'type': safeType, // ✅ NEW

      'updatedAt': FieldValue.serverTimestamp(),
    };

    final todoDeadline = DateTime(
      dayOnly.year,
      dayOnly.month,
      dayOnly.day,
      endTime.hour,
      endTime.minute,
    );

    final batch = _db.batch();
    batch.update(eventRef, eventUpdate);

    if (todoId != null && todoId.isNotEmpty) {
      final todoRef =
          _db.collection('users').doc(uid).collection('todos').doc(todoId);

      batch.update(todoRef, {
        'title': title,
        'deadline': Timestamp.fromDate(todoDeadline),

        'type': safeType, // ✅ NEW

        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  Future<void> deleteEvent(String eventId, DateTime date) async {
    final uid = _currentUid;
    if (uid == null) throw Exception("User is not signed in.");

    final dayOnly = _dayOnly(date);
    final dateId = _getDateId(dayOnly);

    final eventRef = _db
        .collection('users')
        .doc(uid)
        .collection('events')
        .doc(dateId)
        .collection('daily_events')
        .doc(eventId);

    final eventSnap = await eventRef.get();
    if (!eventSnap.exists) return;

    final data = eventSnap.data() as Map<String, dynamic>;
    final todoId = data['todoId'] as String?;

    final batch = _db.batch();
    batch.delete(eventRef);

    if (todoId != null && todoId.isNotEmpty) {
      final todoRef =
          _db.collection('users').doc(uid).collection('todos').doc(todoId);
      batch.delete(todoRef);

      final dupTodos = await _db
          .collection('users')
          .doc(uid)
          .collection('todos')
          .where('eventId', isEqualTo: todoId)
          .get();

      for (final d in dupTodos.docs) {
        batch.delete(d.reference);
      }
    }

    await batch.commit();
  }

  // =========================
  // To-Do Methods
  // =========================

  Future<void> addTodo(String title, DateTime deadline) async {
    final uid = _currentUid;
    if (uid == null) throw Exception("User is not signed in.");

    await _db.collection('users').doc(uid).collection('todos').add({
      'title': title,
      'isCompleted': false,
      'createdAt': FieldValue.serverTimestamp(),
      'deadline': Timestamp.fromDate(deadline),
      'type': 'todo', // (todo ปกติของเดิม)
      'kind': 'todo', // ✅ เพิ่มกันสับสน (ไม่จำเป็นแต่ช่วยให้ deleteTodo ง่าย)
    });
  }

  Stream<QuerySnapshot> getTodosStreamForMonth(DateTime month) {
    final uid = _currentUid;
    if (uid == null) return Stream.empty();

    final startOfMonth = DateTime(month.year, month.month, 1);
    final startOfNextMonth = DateTime(month.year, month.month + 1, 1);

    return _db
        .collection('users')
        .doc(uid)
        .collection('todos')
        .where('deadline',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('deadline', isLessThan: Timestamp.fromDate(startOfNextMonth))
        .orderBy('deadline', descending: false)
        .snapshots();
  }

  Future<void> updateTodoStatus(String todoId, bool isCompleted) async {
    final uid = _currentUid;
    if (uid == null) throw Exception("User is not signed in.");

    await _db
        .collection('users')
        .doc(uid)
        .collection('todos')
        .doc(todoId)
        .update({'isCompleted': isCompleted});
  }

  /// ✅ คืน "วันที่ของ event" กลับไปให้หน้า Calendar เอา dot ออกได้
  Future<DateTime?> deleteTodo(String todoId) async {
    final uid = _currentUid;
    if (uid == null) throw Exception("User is not signed in.");

    final todosCol = _db.collection('users').doc(uid).collection('todos');
    final todoRef = todosCol.doc(todoId);

    final snap = await todoRef.get();
    if (!snap.exists) return null;

    final data = snap.data() as Map<String, dynamic>;

    // ✅ เปลี่ยนจากเช็ค type == 'event' -> เช็ค kind == 'event'
    final kind = (data['kind'] ?? 'todo') as String;

    final eventId = (data['eventId'] as String?) ?? todoId;
    final eventDateTs = data['eventDate'] as Timestamp?;

    final batch = _db.batch();

    // ลบ todo ที่กดลบ
    batch.delete(todoRef);

    // เก็บกวาด todo ซ้ำ
    final dupTodos = await todosCol.where('eventId', isEqualTo: eventId).get();
    for (final d in dupTodos.docs) {
      batch.delete(d.reference);
    }

    DateTime? deletedEventDay;

    // ถ้าเป็น todo ที่ผูก event -> ลบ event ด้วย
    if (kind == 'event') {
      // เอาวันจาก eventDate ก่อน
      if (eventDateTs != null) {
        deletedEventDay = _dayOnly(eventDateTs.toDate());
      }

      // ถ้าไม่มี eventDateTs แต่มี eventDateId -> ใช้ eventDateId
      final eventDateId = (data['eventDateId'] as String?)?.trim();
      final dateId = deletedEventDay != null
          ? _getDateId(deletedEventDay) //!
          : (eventDateId?.isNotEmpty == true ? eventDateId! : null);

      if (dateId != null) {
        final eventRef = _db
            .collection('users')
            .doc(uid)
            .collection('events')
            .doc(dateId)
            .collection('daily_events')
            .doc(eventId);

        batch.delete(eventRef);
      }
    }

    await batch.commit();
    return deletedEventDay;
  }

  // =========================
  // Dot Marker (events)
  // =========================

  Stream<Set<DateTime>> getEventsInRange(DateTime start, DateTime end) {
    final uid = _currentUid;
    if (uid == null) return Stream.value(<DateTime>{});

    final startDay = _dayOnly(start);
    final endDay = _dayOnly(end);

    return _db
        .collectionGroup('daily_events')
        .where('uid', isEqualTo: uid)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDay))
        .where('date', isLessThan: Timestamp.fromDate(endDay))
        .snapshots()
        .map((snapshot) {
      final days = <DateTime>{};

      for (final doc in snapshot.docs) {
        final data = doc.data();
        //as Map<String, dynamic>;
        final ts = data['date'] as Timestamp?;
        if (ts == null) continue;

        final d = ts.toDate();
        days.add(DateTime(d.year, d.month, d.day));
      }

      return days;
    });
  }

  Stream<List<String>> getSubjectsFromEvents() {
    final uid = _currentUid;
    if (uid == null) return Stream.value([]);

    return _db
        .collectionGroup('daily_events')
        .where('uid', isEqualTo: uid)
        .where('type', isEqualTo: 'subject')
        .snapshots()
        .map((snap) {
      final set = <String>{};
      for (final doc in snap.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final title = (data['title'] ?? '').toString().trim();
        if (title.isNotEmpty) set.add(title);
      }
      final list = set.toList()..sort();
      return list;
    });
  }

  Future<List<DateTime>> getDeadlinesForSubjectFromTodos(String subject) async {
    final uid = _currentUid;
    if (uid == null) return [];

    final now = DateTime.now();

    final snap = await _db
        .collection('users')
        .doc(uid)
        .collection('todos')
        .where('type', isEqualTo: 'subject')
        .get();

    final deadlines = <DateTime>[];

    for (final doc in snap.docs) {
      final data = doc.data();
      final title = (data['title'] ?? '').toString().trim();
      final kind = (data['kind'] ?? '').toString();

      if (kind == 'event' && title == subject) {
        final ts = data['deadline'] as Timestamp?;
        final d = ts?.toDate();
        if (d != null && !d.isBefore(now)) deadlines.add(d);
      }
    }

    deadlines.sort();
    return deadlines;
  }
}
