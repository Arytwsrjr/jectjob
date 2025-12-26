// ... (ส่วนหัวของไฟล์ event.dart)
import 'package:flutter/material.dart';

class Event {
  // เพิ่ม field 'id' เพื่อเก็บ Document ID (สำคัญสำหรับการดึงข้อมูล)
  final String id;
  final String title;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String? location;
  final String type;

  Event({
    required this.id, // <--- เพิ่ม id ที่นี่
    required this.title,
    required this.startTime,
    required this.endTime,
    this.location, // <--- ไม่ต้องใส่ required ที่นี่เพราะเป็น String?
    this.type = "personal",
  });

  // ************ toMap() เหมือนที่คุณให้มา (แต่แก้ endHoue เป็น endHour) ************
  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "startHour": startTime.hour,
      "startMinute": startTime.minute,
      "endHour": endTime.hour, // แก้ไขแล้ว
      "endMinute": endTime.minute,
      "location": location,
      "type": type,
    };
  }

  // ************ Factory Constructor สำหรับแปลงข้อมูลจาก Firestore ************
  factory Event.fromMap(Map<String, dynamic> data, String id) {
    // ดึงค่าตัวเลข Hour/Minute ออกมา
    final int startHour = data['startHour'] ?? 0;
    final int startMinute = data['startMinute'] ?? 0;
    final int endHour = data['endHour'] ?? 0; // ใช้ endHour ที่แก้ไขแล้ว
    final int endMinute = data['endMinute'] ?? 0;

    return Event(
      id: id,
      title: data['title'] ?? 'No Title',
      startTime: TimeOfDay(
          hour: startHour, minute: startMinute), // แปลงกลับเป็น TimeOfDay
      endTime:
          TimeOfDay(hour: endHour, minute: endMinute), // แปลงกลับเป็น TimeOfDay
      location: data['location'] as String?,

      type: (data['type']?? 'personal').toString(),
    );
  }
}
