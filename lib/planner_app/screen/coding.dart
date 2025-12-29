import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Coding extends StatefulWidget {
  const Coding({super.key});

  @override
  State<Coding> createState() => _CodingState();
}

class _SongItem {
  final String name;
  final String url;
  _SongItem({required this.name, required this.url});
}

class _CodingState extends State<Coding> with WidgetsBindingObserver {
  final String _category = "coding";

  bool get _canDone {
    if (_sessionStartAt == null) return false;
    return _elapsedNow() >= _targetDuration;
  }

  bool get _canExit => _sessionStartAt == null;

  // ✅ target time (นาที)
  int _initialMinutes = 25;
  Duration get _targetDuration => Duration(seconds: _initialMinutes);

  // ✅ session time (เวลาจริง)
  DateTime? _sessionStartAt;
  DateTime? _activeStartAt;
  Duration _accumulated = Duration.zero;
  bool _isRunning = false;
  Timer? _ticker;

  // ✅ กัน SnackBar เด้งซ้ำ + กันชนตอน dialog เปิด (เผื่ออนาคต)
  bool _targetNotified = false;
  bool _dialogOpen = false;

  // 🎵 Firestore + Audio
  final CollectionReference _songCollection =
      FirebaseFirestore.instance.collection('songs');
  final AudioPlayer _player = AudioPlayer();
  List<_SongItem> _songs = [];

  // ===== SharedPreferences keys (coding) =====
  static const _kRunning = 'coding_running';
  static const _kInitialMinutes = 'coding_initial_minutes';
  static const _kSessionStartMs = 'coding_session_start_ms';
  static const _kActiveStartMs = 'coding_active_start_ms';
  static const _kAccumulatedSec = 'coding_accumulated_sec';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSongsAndPreparePlaylist();
    _restoreSession();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    _player.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _persistSession();
    }
    super.didChangeAppLifecycleState(state);
  }

  // =========================
  // REAL TIME CALC
  // =========================
  Duration _elapsedNow() {
    if (_activeStartAt != null && _isRunning) {
      final now = DateTime.now();
      return _accumulated + now.difference(_activeStartAt!);
    }
    return _accumulated;
  }

  Duration _remainingNow() => _targetDuration - _elapsedNow();

  String _formatMMSS(Duration d) {
    final totalSec = d.inSeconds.abs();
    final m = (totalSec ~/ 60).toString().padLeft(2, '0');
    final s = (totalSec % 60).toString().padLeft(2, '0');
    return "$m : $s";
  }

  String _displayTimerText() {
    final rem = _remainingNow();
    if (rem.inSeconds >= 0) return _formatMMSS(rem);
    return "+ ${_formatMMSS(rem)}";
  }

  // =========================
  // TIMER CONTROL (RUN/PAUSE)
  // =========================
  void _startTimer() {
    if (_isRunning) return;

    final now = DateTime.now();
    setState(() {
      _isRunning = true;
      _sessionStartAt ??= now;
      _activeStartAt = now;
    });

    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;

      setState(() {});

      if (!_targetNotified && _remainingNow().inSeconds <= 0 && !_dialogOpen) {
        _targetNotified = true;
        ScaffoldMessenger.maybeOf(context)
          ?..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Target reached! You can keep coding 👩‍💻'),
            ),
          );
      }
    });

    _persistSession();
  }

  void _pauseTimer() {
    if (!_isRunning) return;

    final now = DateTime.now();
    setState(() {
      _isRunning = false;
      if (_activeStartAt != null) {
        _accumulated += now.difference(_activeStartAt!);
      }
      _activeStartAt = null;
    });

    _ticker?.cancel();
    _persistSession();
  }

  void _toggleTimer() => _isRunning ? _pauseTimer() : _startTimer();

  void _resetTimer() {
    _ticker?.cancel();
    setState(() {
      _isRunning = false;
      _sessionStartAt = null;
      _activeStartAt = null;
      _accumulated = Duration.zero;
      _targetNotified = false;
    });
    _clearPersisted();
  }

  void _increaseTime() {
    setState(() => _initialMinutes += 5);
    _persistSession();
  }

  void _decreaseTime() {
    setState(() {
      if (_initialMinutes > 5) _initialMinutes -= 5;
    });
    _persistSession();
  }

  // =========================
  // DONE / SAVE (เก็บแค่เวลา)
  // =========================
  Future<void> _onDonePressed() async {
    if (_sessionStartAt == null) return;
    if (!_canDone) return;

    if (_isRunning) _pauseTimer();

    final now = DateTime.now();
    final duration = _elapsedNow();

    try {
      await _saveCodingSession(
        startTime: _sessionStartAt!,
        endTime: now,
        duration: duration,
      );

      if (!mounted) return;

      _resetTimer();
      ScaffoldMessenger.maybeOf(context)
          ?.showSnackBar(const SnackBar(content: Text("Save Success!")));
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text("Save failed: $e")),
      );
    }
  }

  Future<void> _saveCodingSession({
    required DateTime startTime,
    required DateTime endTime,
    required Duration duration,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception("User not signed in");

    final ref = FirebaseFirestore.instance
        .collection('timer')
        .doc(uid)
        .collection('coding_sessions')
        .doc();

    await ref.set({
      'category': _category,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'durationSeconds': duration.inSeconds,
      'plannedMinutes': _initialMinutes,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // =========================
  // PERSIST / RESTORE
  // =========================
  Future<void> _persistSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kRunning, _isRunning);
    await prefs.setInt(_kInitialMinutes, _initialMinutes);
    await prefs.setInt(_kAccumulatedSec, _accumulated.inSeconds);

    if (_sessionStartAt != null) {
      await prefs.setInt(
          _kSessionStartMs, _sessionStartAt!.millisecondsSinceEpoch);
    } else {
      await prefs.remove(_kSessionStartMs);
    }

    if (_activeStartAt != null) {
      await prefs.setInt(_kActiveStartMs, _activeStartAt!.millisecondsSinceEpoch);
    } else {
      await prefs.remove(_kActiveStartMs);
    }
  }

  Future<void> _restoreSession() async {
    final prefs = await SharedPreferences.getInstance();

    final running = prefs.getBool(_kRunning) ?? false;
    final initMin = prefs.getInt(_kInitialMinutes) ?? 25;
    final accSec = prefs.getInt(_kAccumulatedSec) ?? 0;

    final startMs = prefs.getInt(_kSessionStartMs);
    final activeMs = prefs.getInt(_kActiveStartMs);

    setState(() {
      _initialMinutes = initMin;
      _accumulated = Duration(seconds: accSec);
      _sessionStartAt =
          startMs != null ? DateTime.fromMillisecondsSinceEpoch(startMs) : null;
      _activeStartAt =
          activeMs != null ? DateTime.fromMillisecondsSinceEpoch(activeMs) : null;
      _isRunning = running;

      _targetNotified = (_remainingNow().inSeconds <= 0);
    });

    if (_isRunning && _activeStartAt != null) {
      final now = DateTime.now();
      final extra = now.difference(_activeStartAt!);
      setState(() {
        _accumulated += extra;
        _activeStartAt = now;
      });

      _ticker?.cancel();
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() {});
      });
    }
  }

  Future<void> _clearPersisted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kRunning);
    await prefs.remove(_kInitialMinutes);
    await prefs.remove(_kSessionStartMs);
    await prefs.remove(_kActiveStartMs);
    await prefs.remove(_kAccumulatedSec);
  }

  // =========================
  // MUSIC
  // =========================
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

  Widget _buildMiniPlayerBar() {
    return StreamBuilder<int?>(
      stream: _player.currentIndexStream,
      builder: (context, snapIndex) {
        final idx = snapIndex.data ?? 0;

        final songName = (_songs.isNotEmpty && idx >= 0 && idx < _songs.length)
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

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 226, 162),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  const SizedBox(height: 70),
                  Text(
                    'Welcome for coding!',
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
                  _buildButtonsRow(),
                ],
              ),
            ),
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
              'Coding',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Icon(Icons.code, size: 40, color: Colors.grey[800]),
          ],
        ),
      ],
    );
  }

  Widget _buildTimerControls() {
    return Column(
      children: [
        Text(
          _displayTimerText(),
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
        const SizedBox(height: 6),
        Text(
          "Elapsed: ${_formatMMSS(_elapsedNow())}",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
              child: IconButton(
                icon: const Icon(Icons.refresh, color: Colors.black54),
                iconSize: 30,
                onPressed: _resetTimer,
              ),
            ),
            const SizedBox(width: 40),
            Container(
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
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

  Widget _buildButtonsRow() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _canDone ? _onDonePressed : null,
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
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _canExit ? () => Navigator.of(context).pop(true) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
              elevation: 5,
            ),
            child: const Text(
              'Exit',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
