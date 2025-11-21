import 'dart:async';

import 'package:flutter/material.dart';

class Reading extends StatefulWidget {
  const Reading({super.key});
  @override
  State<Reading> createState() => _ReadingState();
}

class _ReadingState extends State<Reading> {
  // --- ส่วนจัดการสถานะของ Timer ---
  int _initialMinutes = 25;
  late Duration _totalDuration;
  late Duration _remainingDuration;
  Timer? _timer;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _totalDuration = Duration(minutes: _initialMinutes);
    _remainingDuration = _totalDuration;
  }

  // --- ฟังก์ชัน Timer ---
  void _startTimer() {
    if (_isRunning) return;
    setState(() => _isRunning = true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingDuration.inSeconds > 0) {
          _remainingDuration -= const Duration(seconds: 1);
        } else {
          _stopTimer(reset: false);
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
      if (reset) _remainingDuration = _totalDuration;
    });
  }

  void _toggleTimer() => _isRunning ? _stopTimer() : _startTimer();

  void _resetTimer() => _stopTimer(reset: true);

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes : $seconds";
  }

  // --- เพิ่ม/ลดเวลา ---
  void _increaseTime() {
    setState(() {
      _initialMinutes += 5;
      _totalDuration = Duration(minutes: _initialMinutes);
      if (!_isRunning) _remainingDuration = _totalDuration;
    });
  }

  void _decreaseTime() {
    setState(() {
      if (_initialMinutes > 1) {
        _initialMinutes -= 5;
        _totalDuration = Duration(minutes: _initialMinutes);
        if (!_isRunning) _remainingDuration = _totalDuration;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 166, 212, 237),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.music_note, color: Colors.black54),
                  onPressed: () {},
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Welcom for reading!',
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
              SizedBox(
                height: 20,
              ),
              _buildGlowEffect(),
              SizedBox(
                height: 20,
              ),
              _buildTimerControls(), // ตัวเลข + Play/Pause/Reset
              SizedBox(height: 20),
              _buildTimeAdjustButtons(), // <-- ปุ่มเพิ่ม/ลดเวลา
              SizedBox(height: 20),
              _buildDoneButton(),
            ],
          ),
        ),
      ),
    );
  }

  // --- Glow Effect ---
  Widget _buildGlowEffect() {
    return Stack(
      alignment: Alignment.center,
      children: [
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
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Reading',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 10),
            Icon(Icons.laptop_mac, size: 40, color: Colors.grey[800]),
          ],
        ),
      ],
    );
  }

  // --- ปุ่มตัวเลข + Play/Pause/Reset ---
  Widget _buildTimerControls() {
    return Column(
      children: [
        Text(
          _formatDuration(_remainingDuration),
          style: TextStyle(
            fontSize: 52,
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration:
                  BoxDecoration(shape: BoxShape.circle, color: Colors.white),
              child: IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.black54),
                  iconSize: 30,
                  onPressed: _resetTimer),
            ),
            const SizedBox(width: 40),
            Container(
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Colors.white),
              child: IconButton(
                icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow,
                    color: Colors.black87),
                iconSize: 40,
                onPressed: _toggleTimer,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- ปุ่มเพิ่ม/ลดเวลา ---
  Widget _buildTimeAdjustButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
            icon: const Icon(Icons.remove_circle, color: Colors.red, size: 36),
            onPressed: _decreaseTime),
        const SizedBox(width: 20),
        Text("$_initialMinutes min",
            style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        const SizedBox(width: 20),
        IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.green, size: 36),
            onPressed: _increaseTime),
      ],
    );
  }

  // --- ปุ่ม DONE ---
  Widget _buildDoneButton() {
    return ElevatedButton(
      onPressed: () {
        _stopTimer(reset: true);
        if (Navigator.canPop(context)) Navigator.pop(context);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        elevation: 5,
      ),
      child: const Text('DONE',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    );
  }
}
