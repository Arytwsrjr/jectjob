// ai_planner_page.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:planner/service/firestore.dart';
import 'package:planner/service/api_service.dart';

class AiPlannerPage extends StatefulWidget {
  const AiPlannerPage({super.key});

  @override
  State<AiPlannerPage> createState() => _AiPlannerPageState();
}

class _AiPlannerPageState extends State<AiPlannerPage> {
  final FirestoreService _fs = FirestoreService();
  final ApiService _apiService = ApiService();

  late final Stream<List<String>> _subjectsStream;

  @override
  void initState() {
    super.initState();
    _subjectsStream = _fs.getSubjectsFromEvents();
  }

  int _daysLeft(DateTime deadline) {
    final now = DateTime.now();
    final d0 = DateTime(now.year, now.month, now.day);
    final d1 = DateTime(deadline.year, deadline.month, deadline.day);
    return d1.difference(d0).inDays;
  }

  Future<void> _openPlanSheet() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("กรุณา Login ก่อน")));
      return;
    }

    String? selectedSubject;
    DateTime? selectedDeadline;
    int userDifficulty = 3;

    bool useChapterMode = false;
    int totalChapters = 0;
    int completedChapters = 0;

    List<DateTime> deadlines = [];
    bool loadingDeadlines = false;
    bool submitting = false;

    Future<void> loadDeadlines(
      BuildContext sheetCtx,
      String subject,
      void Function(VoidCallback fn) setModalState,
    ) async {
      setModalState(() {
        loadingDeadlines = true;
        deadlines = [];
        selectedDeadline = null;
      });

      try {
        final res = await _fs.getDeadlinesForSubjectFromTodos(subject);
        if (!sheetCtx.mounted) return;

        setModalState(() {
          deadlines = res;
          selectedDeadline = res.isNotEmpty ? res.first : null;
        });
      } finally {
        if (sheetCtx.mounted) {
          setModalState(() => loadingDeadlines = false);
        }
      }
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            int remainingChapters =
                (totalChapters - completedChapters).clamp(0, 999);

            int days =
                selectedDeadline != null ? _daysLeft(selectedDeadline!) : 1;
            if (days <= 0) days = 1;

            double chaptersPerDay = days > 0
                ? remainingChapters / days
                : remainingChapters.toDouble();

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
              ),
              child: StreamBuilder<List<String>>(
                stream: _subjectsStream,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(12),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final subjects = snap.data ?? [];

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header + Switch
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Let's plan",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              const Text("เพิ่มจำนวนบท",
                                  style: TextStyle(fontSize: 12)),
                              Switch(
                                value: useChapterMode,
                                onChanged: (val) =>
                                    setModalState(() => useChapterMode = val),
                              ),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 10),

                      // 1. เลือกวิชา
                      DropdownButtonFormField<String>(
                        value: selectedSubject,
                        items: subjects
                            .map((s) =>
                                DropdownMenuItem(value: s, child: Text(s)))
                            .toList(),
                        onChanged: submitting
                            ? null
                            : (v) async {
                                if (v == null) return;
                                setModalState(() => selectedSubject = v);
                                await loadDeadlines(sheetCtx, v, setModalState);
                              },
                        decoration: const InputDecoration(
                          labelText: "วิชา",
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // 2. เลือก Deadline
                      DropdownButtonFormField<DateTime>(
                        value: selectedDeadline,
                        items: deadlines
                            .map(
                              (d) => DropdownMenuItem(
                                value: d,
                                child: Text(DateFormat('d MMM yyyy').format(d)),
                              ),
                            )
                            .toList(),
                        onChanged: submitting
                            ? null
                            : (v) => setModalState(() => selectedDeadline = v),
                        decoration: const InputDecoration(
                          labelText: "Deadline",
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        ),
                      ),
                      if (selectedDeadline != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 5, bottom: 5),
                          child: Text(
                            "เหลืออีก ${_daysLeft(selectedDeadline!)} วัน",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),

                      const Divider(),

                      // --- ส่วนช่องกรอกบท ---
                      if (useChapterMode) ...[
                        const Text(
                          "จำนวนบทเรียน",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  labelText: "ทั้งหมด",
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (v) => setModalState(
                                  () => totalChapters = int.tryParse(v) ?? 0,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  labelText: "เสร็จแล้ว",
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (v) => setModalState(
                                  () =>
                                      completedChapters = int.tryParse(v) ?? 0,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (totalChapters > 0)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Text(
                              "ต้องอ่าน $remainingChapters บท ใน $days วัน "
                              "(≈ ${chaptersPerDay.toStringAsFixed(1)} บท/วัน)",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        const SizedBox(height: 10),
                      ],

                      // --- Slider ความยาก ---
                      const Text(
                        "ระดับความยาก (1–5)",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Slider(
                              value: userDifficulty.toDouble(),
                              min: 1,
                              max: 5,
                              divisions: 4,
                              label: userDifficulty.toString(),
                              onChanged: submitting
                                  ? null
                                  : (v) => setModalState(
                                        () => userDifficulty = v.round(),
                                      ),
                            ),
                          ),
                          Container(
                            width: 40,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue[100],
                            ),
                            child: Text(
                              "$userDifficulty",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),

                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed:
                                  submitting ? null : () => Navigator.pop(ctx),
                              child: const Text("Cancel"),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: submitting
                                  ? null
                                  : () async {
                                      if (selectedSubject == null ||
                                          selectedDeadline == null) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Row(
                                              children: const [
                                                Icon(Icons.warning,
                                                    color: Colors.white),
                                                SizedBox(width: 8),
                                                Text(
                                                    "กรุณาเลือกวิชาและ Deadline"),
                                              ],
                                            ),
                                            behavior: SnackBarBehavior.floating,
                                            backgroundColor: Colors.redAccent,
                                            margin: EdgeInsets.only(
                                              bottom: MediaQuery.of(context)
                                                      .size
                                                      .height -
                                                  150,
                                              left: 20,
                                              right: 20,
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      if (useChapterMode &&
                                          totalChapters <= 0) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Row(
                                              children: const [
                                                Icon(Icons.warning,
                                                    color: Colors.white),
                                                SizedBox(width: 8),
                                                Text("กรุณากรอกจำนวนบทเรียน"),
                                              ],
                                            ),
                                            behavior: SnackBarBehavior.floating,
                                            backgroundColor: Colors.orange,
                                            margin: EdgeInsets.only(
                                              bottom: MediaQuery.of(context)
                                                      .size
                                                      .height -
                                                  150,
                                              left: 20,
                                              right: 20,
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      setModalState(() => submitting = true);

                                      try {
                                        final safeDaysLeft =
                                            _daysLeft(selectedDeadline!);
                                        final result =
                                            await _apiService.generatePlan(
                                          uid: uid,
                                          subject: selectedSubject!,
                                          difficulty: userDifficulty,
                                          deadline: selectedDeadline!,
                                          daysLeft: safeDaysLeft <= 0
                                              ? 1
                                              : safeDaysLeft,
                                          useChapterMode: useChapterMode,
                                          totalChapters: totalChapters,
                                          completedChapters: completedChapters,
                                        );

                                        if (!mounted) return;
                                        Navigator.pop(ctx);

                                        showDialog(
                                          context: context,
                                          builder: (dialogCtx) => AlertDialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            title: Row(
                                              children: const [
                                                Icon(Icons.lightbulb,
                                                    color: Colors.amber),
                                                SizedBox(width: 8),
                                                Text("AI แนะนำ"),
                                              ],
                                            ),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "วิชา: ${result['subject']}",
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                if (useChapterMode &&
                                                    totalChapters > 0) ...[
                                                  Text(
                                                    "จำนวนบท: ${(totalChapters - completedChapters).clamp(0, 999)} บท",
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                  if (result[
                                                          'chapters_per_day'] !=
                                                      null)
                                                    Text(
                                                      "≈ ${result['chapters_per_day']} บท/วัน",
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                  const SizedBox(height: 6),
                                                ],
                                                Text(
                                                  "ความยาก: Level $userDifficulty",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  "ควรใช้เวลาอ่าน:",
                                                  style: TextStyle(
                                                    color: Colors.grey[700],
                                                  ),
                                                ),
                                                Text(
                                                  "${result['recommended_hours']} ชม./วัน",
                                                  style: const TextStyle(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.blue,
                                                  ),
                                                ),
                                                if (result['base_hours'] !=
                                                    null) ...[
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    "Base (จากโมเดล): ${result['base_hours']} ชม./วัน",
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                ],
                                                if (result['chapter_hours'] !=
                                                    null) ...[
                                                  Text(
                                                    "ตามจำนวนบท (สูตรทฤษฎี): ${result['chapter_hours']} ชม./วัน",
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                ],
                                                const SizedBox(height: 12),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(12),
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: Text(
                                                    "${result['message']}",
                                                    style: TextStyle(
                                                      color: Colors.blue[900],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(dialogCtx)
                                                        .pop(),
                                                child: const Text(
                                                  "OK",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      } catch (e) {
                                        if (!mounted) return;
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text("Error: $e"),
                                          ),
                                        );
                                      } finally {
                                        if (sheetCtx.mounted) {
                                          setModalState(
                                            () => submitting = false,
                                          );
                                        }
                                      }
                                    },
                              child: submitting
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text("Generate Plan"),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _openPlanSheet,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text("Let's plan"),
            ),
          ),
        ),
      ),
    );
  }
}
