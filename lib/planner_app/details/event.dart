import 'package:flutter/material.dart';

class Event {
  final String title;
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  Event({
    required this.title,
    required this.startTime,
    required this.endTime,
  });
}
