import 'package:flutter/material.dart';

class TaskProgressBar extends StatelessWidget {
  const TaskProgressBar({super.key});

  // กำหนดข้อมูลเปอร์เซ็นต์ที่นี่ (ควรจะมาจากที่เดียวกับ Pie Chart)
  final double completePercentage = 40;

  @override
  Widget build(BuildContext context) {
    // แปลงค่าเปอร์เซ็นต์ (0-100) ให้เป็นค่าสำหรับ Progress Bar (0.0-1.0)
    final double progressValue = completePercentage / 100;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ส่วนของ Text แสดงชื่อและเปอร์เซ็นต์
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Task Progress',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${completePercentage.toStringAsFixed(0)}%', // แสดงเลข 40%
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF81C784), // สีเขียวเหมือนใน Pie Chart
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ส่วนของ Progress Bar
          // ใช้ ClipRRect เพื่อทำให้ขอบของ Progress Bar มน
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progressValue, // ค่า progress 0.4 (คือ 40%)
              minHeight: 20, // ทำให้แถบหนาขึ้น
              backgroundColor: const Color(0xFFE57373)
                  .withOpacity(0.4), // สีพื้นหลัง (Incomplete) ทำให้จางลงหน่อย
              valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF81C784)), // สีของ progress (Complete)
            ),
          ),
        ],
      ),
    );
  }
}
