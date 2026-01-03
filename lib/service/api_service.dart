// api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // iOS Simulator: "http://127.0.0.1:8000"
  // Android Emulator: "http://10.0.2.2:8000"
  // เครื่องจริง: "http://192.168.x.x:8000"
  static const String baseUrl = "http://127.0.0.1:8000";

  Future<Map<String, dynamic>> generatePlan({
    required String subject,
    required int difficulty,
    required DateTime deadline,
    required int daysLeft,
    String? uid,

    bool useChapterMode = false,
    int totalChapters = 0,
    int completedChapters = 0,
  }) async {
    final url = Uri.parse("$baseUrl/plan");

    final body = {
      "uid": uid,
      "subject": subject,
      "difficulty": difficulty,
      "deadline": deadline.toIso8601String(),
      "daysLeft": daysLeft,
      "useChapterMode": useChapterMode,
      "totalChapters": totalChapters,
      "completedChapters": completedChapters,
    };

    try {
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw Exception("Server Error: ${res.statusCode} ${res.body}");
      }

      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (e) {
      throw Exception("เชื่อมต่อ API ไม่ได้: $e");
    }
  }
}
