import 'package:flutter/material.dart';
import 'package:planner/planner_app/screen/coding.dart';
import 'package:planner/planner_app/screen/reading.dart';

// --- เราจะเปลี่ยนชื่อ Class จาก Focus เป็น FocusPage ---
// --- เพื่อหลีกเลี่ยงการซ้ำซ้อนกับ Class ชื่อ Focus ที่มีอยู่แล้วใน Flutter ---
class FocusPage extends StatelessWidget {
  const FocusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(
      // backgroundColor: Colors.yellow,
      //  elevation: 0,
      // title: Text('Focus Mode'),
      //  centerTitle: true,
      //  leading: IconButton(
      //   icon: const Icon(Icons.arrow_back),
      //   onPressed: () {},
      // ),
      //  ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ส่วน Header ที่เป็นพื้นหลังสีฟ้าโค้งๆ
            // _buildHeader(context),
            SizedBox(
              height: 20,
            ),
            // ส่วนเนื้อหาหลัก
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Activities',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  _buildActivitiesSection(context),
                  const SizedBox(height: 30),
                  const Text(
                    'Recent',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  _buildRecentSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget สำหรับสร้าง Header
  //Widget _buildHeader(BuildContext context) {
  // return SizedBox(
  //   height: 220, // ความสูงของพื้นที่ Header ทั้งหมด
  //   child: Stack(
  //     children: [
  //       // พื้นหลังสีฟ้าทรงโค้ง
  //       ClipPath(
  //         clipper: HeaderClipper(),
  //         child: Container(
  //           height: 200, // ความสูงของส่วนที่เป็นสี
  //           color: const Color(0xFF56CCF2),
  //         ),
  //       ),
  //        // ปุ่ม Back และ ไอคอนด้านขวา
  //       SafeArea(
  //         child: Padding(
  //           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               // ปุ่ม Back
  //               Container(
  //                 padding:
  //                     const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  //                 decoration: BoxDecoration(
  //                   color: Colors.black.withOpacity(0.1),
  //                   borderRadius: BorderRadius.circular(20),
  //                 ),
  //                 child: const Row(
  //                   children: [
  //                     Icon(Icons.arrow_back_ios,
  //                         size: 14, color: Colors.black54),
  //                     SizedBox(width: 4),
  //                     Text('Back', style: TextStyle(color: Colors.black54)),
  //                   ],
  //                 ),
  //               ),
  //               // ไอคอนด้านขวา
  //               const Icon(Icons.queue_music,
  //                   size: 28, color: Colors.black87),
  //             ],
  //           ),
  //         ),
  //       ),
  // ข้อความ "Focus Mode"
  //       Positioned(
  //        top: 120,
  //        left: 20,
  //        child: Text(
  //          'Focus Mode',
  //          style: TextStyle(
  //            fontSize: 36,
  //            fontWeight: FontWeight.bold,
  //            color: Colors.grey[800],
  //          ),
  //        ),
  //      ),
  //    ],
  //  ),
  // );
  //}

  // Widget สำหรับสร้างส่วน "Activities" ที่เป็นแนวนอน
  Widget _buildActivitiesSection(BuildContext context) {
    return SizedBox(
      height: 150,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Coding(),
                  ));
            },
            child: _activityCard(
                '💻', 'Coding', '2.5 hrs', 'ALL TIME', const Color(0xFFFDEBB9)),
          ),
          const SizedBox(width: 15),
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Reading(),
                  ));
            },
            child: _activityCard(
                '📖', 'Reading', '3 hrs', 'ALL TIME', const Color(0xFF6DD5FA)),
          ),
          const SizedBox(width: 15),
          _activityCard(
              '🛏️', 'Sleeping', '8 hrs', 'ALL TIME', const Color(0xFFF7C5CC)),
          const SizedBox(width: 15),
          _activityCard(
              '💪🏻', 'Exercise', '30 m', 'ALL TIME', Color(0xFFC5E1A5)),
        ],
      ),
    );
  }

  // Widget ต้นแบบสำหรับ Activity Card
  Widget _activityCard(String icon, String title, String duration,
      String timeFrame, Color color) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const Spacer(),
          Text(title,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(duration,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black.withOpacity(0.7))),
          Text(timeFrame,
              style: TextStyle(
                  fontSize: 12, color: Colors.black.withOpacity(0.5))),
        ],
      ),
    );
  }

  // Widget สำหรับสร้างส่วน "Recent"
  Widget _buildRecentSection() {
    return Column(
      children: [
        _recentItem(
            'Coding', 'Today at 10 PM', '2.5 hrs', const Color(0xFFFDBF60)),
        const SizedBox(height: 12),
        _recentItem(
            'Exercise', 'Today at 5 PM', '50 mins', const Color(0xFFA8E6CF)),
        const SizedBox(height: 12),
        _recentItem(
            'Reading', 'Today at 7 AM', '1 hrs', const Color(0xFF6DD5FA)),
        const SizedBox(height: 12),
        _recentItem(
            'Reading', 'Yesterday at 8 PM', '2 hrs', const Color(0xFF6DD5FA)),
      ],
    );
  }

  // Widget ต้นแบบสำหรับ Recent Item
  Widget _recentItem(
      String title, String time, String duration, Color titleColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                    color: titleColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
            ],
          ),
          Text(
            duration,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

// Class สำหรับวาดรูปทรงโค้งของ Header
class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 50); // เริ่มจากซ้ายล่าง (เยื้องขึ้นมา 50)

    // สร้างจุดควบคุมสำหรับความโค้ง
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2.25, size.height - 30);

    // วาดเส้นโค้งเส้นแรก
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    // สร้างจุดควบคุมสำหรับความโค้งเส้นที่สอง
    var secondControlPoint =
        Offset(size.width - (size.width / 3.25), size.height - 65);
    var secondEndPoint = Offset(size.width, size.height - 40);

    // วาดเส้นโค้งเส้นที่สอง
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, 0); // ลากเส้นไปที่มุมขวาบน
    path.close(); // ปิด Path
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
