import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class Exercise extends StatefulWidget {
  const Exercise({super.key});
  @override
  State<Exercise> createState() => _ExerciseState();
}

class _SongItem{
  final String name;
  final String url;

  _SongItem({required this.name, required this.url});
}

class _ExerciseState extends State<Exercise> {
  final String _category = "exercise";
  // --- ส่วนจัดการสถานะของ Timer ---
  int _initialMinutes = 25;
  late Duration _totalDuration;
  late Duration _remainingDuration;
  Timer? _timer;
  bool _isRunning = false;

  final CollectionReference _songCollection = FirebaseFirestore.instance.collection('songs');
  final AudioPlayer _player = AudioPlayer();
  List<_SongItem>_songs = [];

  @override
  void initState() {
    super.initState();
    _totalDuration = Duration(minutes: _initialMinutes);
    _remainingDuration = _totalDuration;

    _loadSongsAndPreparePlaylist();
  }

  @override
  void dispose(){
    _timer?.cancel();
    _player.dispose();
    super.dispose();
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

  // ---------- MUSIC ----------
  Future<void> _loadSongsAndPreparePlaylist() async {
    try {
      final snap =
          await _songCollection.where('category', isEqualTo: _category).get();

      _songs = snap.docs
          .map((d) {
            final data = d.data() as Map<String, dynamic>;
            return _SongItem(
              name: (data['name'] ?? 'Unknown').toString(),
              url: (data['url'] ?? '').toString(),
            );
          })
          .where((s) => s.url.trim().isNotEmpty)
          .toList();

      if (_songs.isEmpty) {
        if (mounted) setState(() {});
        return;
      }

      final playlist = ConcatenatingAudioSource(
        children: _songs.map((s) => AudioSource.uri(Uri.parse(s.url))).toList(),
      );

      await _player.setAudioSource(
        playlist,
        initialIndex: 0,
        initialPosition: Duration.zero,
      );

      if (mounted) setState(() {});
    } catch (e) {
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text("Load songs failed: $e")),
      );
    }
  }

  Future<void> _togglePlayPause() async {
    if (_songs.isEmpty) return;
    try {
      _player.playing ? await _player.pause() : await _player.play();
    } catch (_) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(content: Text("Cannot play this song")),
      );
    }
  }

  Future<void> _nextSong() async {
    if (_songs.isEmpty) return;
    if (_player.hasNext) {
      await _player.seekToNext();
      await _player.play();
    }
  }

  Future<void> _prevSong() async {
    if (_songs.isEmpty) return;
    if (_player.hasPrevious) {
      await _player.seekToPrevious();
      await _player.play();
    } else {
      await _player.seek(Duration.zero);
    }
  }

  // ---------- MINI PLAYER ----------
  Widget _buildMiniPlayerBar() {
    return StreamBuilder<int?>(
      stream: _player.currentIndexStream,
      builder: (context, snapIndex) {
        final idx = snapIndex.data ?? 0;

        final songName =
            (_songs.isNotEmpty && idx >= 0 && idx < _songs.length)
                ? _songs[idx].name
                : "No songs";

        return StreamBuilder<PlayerState>(
          stream: _player.playerStateStream,
          builder: (context, snapState) {
            final playing = snapState.data?.playing ?? false;

            return Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.88),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                    color: Colors.black.withOpacity(0.25),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.music_note, color: Colors.white70, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      songName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _songs.isEmpty ? null : _prevSong,
                    icon: const Icon(Icons.skip_previous, color: Colors.white),
                  ),
                  IconButton(
                    onPressed: _songs.isEmpty ? null : _togglePlayPause,
                    icon: Icon(
                      playing ? Icons.pause_circle : Icons.play_circle,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  IconButton(
                    onPressed: _songs.isEmpty ? null : _nextSong,
                    icon: const Icon(Icons.skip_next, color: Colors.white),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 226, 162),

      // ✅ ใช้ Stack เพื่อให้ mini player ลอยด้านบน
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  const SizedBox(height: 70), // ✅ เว้นที่ให้แถบด้านบน

                  Text(
                    'Welcome for Exercise!',
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
                  const SizedBox(height: 20),

                  _buildGlowEffect(),
                  const SizedBox(height: 20),

                  _buildTimerControls(),
                  const SizedBox(height: 20),

                  _buildTimeAdjustButtons(),
                  const SizedBox(height: 20),

                  _buildDoneButton(),
                ],
              ),
            ),

            // ✅ แถบเพลงลอยด้านบน (Dynamic Island)
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 8, left: 20, right: 20),
                child: _buildMiniPlayerBar(),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
              'Exercise',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Icon(Icons.menu_book, size: 40, color: Colors.grey[800]),
          ],
        ),
      ],
    );
  }

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
                  const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
              child: IconButton(
                icon: const Icon(Icons.refresh, color: Colors.black54),
                iconSize: 30,
                onPressed: _resetTimer,
              ),
            ),
            const SizedBox(width: 40),
            Container(
              decoration:
                  const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
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

  Widget _buildTimeAdjustButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle, color: Colors.red, size: 36),
          onPressed: _decreaseTime,
        ),
        const SizedBox(width: 20),
        Text(
          "$_initialMinutes min",
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 20),
        IconButton(
          icon: const Icon(Icons.add_circle, color: Colors.green, size: 36),
          onPressed: _increaseTime,
        ),
      ],
    );
  }

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
      child: const Text(
        'DONE',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}