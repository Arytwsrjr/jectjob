import 'dart:async';

import 'package:flutter/material.dart';

class Coding extends StatefulWidget {
  const Coding({super.key});
  @override
  State<Coding> createState() => _CodingState();
}

class _CodingState extends State<Coding> {
  // --- ส่วนจัดการสถานะของ Timer ---
  static const int _initialMinutes = 25;
  static const Duration _totalDuration = Duration(minutes: _initialMinutes);

  late Duration _remainingDuration;
  Timer? _timer;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    // เริ่มต้นเวลาที่เหลือให้เท่ากับเวลาทั้งหมด
    _remainingDuration = _totalDuration;
  }

  void _startTimer() {
    if (_isRunning) return; // ถ้ากำลังทำงานอยู่แล้ว ก็ไม่ต้องทำอะไร

    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingDuration.inSeconds > 0) {
          _remainingDuration = _remainingDuration - const Duration(seconds: 1);
        } else {
          _stopTimer(reset: false); // หยุดเมื่อเวลาหมด
          // สามารถเพิ่มโค้ดแจ้งเตือนตรงนี้ได้ เช่น เสียง หรือ dialog
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Focus session complete! 🎉')),
          );
        }
      });
    });
  }

  void _stopTimer({bool reset = false}) {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      if (reset) {
        _remainingDuration = _totalDuration;
      }
    });
  }

  void _toggleTimer() {
    if (_isRunning) {
      _stopTimer();
    } else {
      _startTimer();
    }
  }

  void _resetTimer() {
    _stopTimer(reset: true);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes : $seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            children: [
              // ไอคอนมุมขวาบน (ในรูปเหมือนรถเข็น)
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.music_note, color: Colors.black54),
                  onPressed: () {
                    // ทำอะไรบางอย่างเมื่อกด
                  },
                ),
              ),

              const SizedBox(height: 40),

              // ข้อความ "Dive deep, stay focused!"
              Text(
                'Dive deep,\nstay focused!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // ส่วนวงกลมเรืองแสงตรงกลาง
              _buildGlowEffect(),

              const Spacer(),

              // ปุ่มควบคุม
              _buildTimerControls(),

              const SizedBox(height: 20),

              // ปุ่ม DONE
              _buildDoneButton(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlowEffect() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // วงกลมที่เป็นแสงเรืองๆ ด้านหลัง
        Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Colors.white.withOpacity(0.6),
                Colors.white.withOpacity(0.0),
              ],
              stops: const [0.4, 1.0],
            ),
          ),
        ),
        // ข้อความและไอคอนด้านใน
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Coding',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Icon(
              Icons.laptop_mac,
              size: 40,
              color: Colors.grey[800],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimerControls() {
    return Column(
      children: [
        // ตัวเลขเวลา
        Text(
          _formatDuration(_remainingDuration),
          style: TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                blurRadius: 5.0,
                color: Colors.black.withOpacity(0.2),
                offset: const Offset(1, 1),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        // ปุ่ม Reset และ Play/Pause
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ปุ่ม Reset
            Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: IconButton(
                icon: const Icon(Icons.refresh, color: Colors.black54),
                iconSize: 30,
                onPressed: _resetTimer,
              ),
            ),
            const SizedBox(width: 40),
            // ปุ่ม Play/Pause
            Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: IconButton(
                icon: Icon(
                  _isRunning ? Icons.pause : Icons.play_arrow,
                  color: Colors.black87,
                ),
                iconSize: 40,
                onPressed: _toggleTimer,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDoneButton() {
    return ElevatedButton(
      onPressed: () {
        _stopTimer(reset: true);
        // สามารถเพิ่มโค้ดให้กลับไปหน้าก่อนหน้าได้
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
        elevation: 5,
      ),
      child: const Text(
        'DONE',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
