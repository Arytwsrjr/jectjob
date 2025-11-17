import 'package:flutter/material.dart'; // ต้อง import เพื่อใช้ TimeOfDay

class Event {
  final String title;
  final TimeOfDay time;

  Event({required this.title, required this.time});

  @override
  String toString() => title;
}
