import 'dart:convert';

import 'package:http/http.dart' as http;

class ReviewService {
  static Future<void> saveWordsBatch({
    required List<Map<String, String>> words,
    required String token,
  }) async {
    final url = Uri.parse("http://10.0.2.2:8000/review/save");

    for (var word in words) {
      try {
        final response = await http.post(
          url,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: jsonEncode(word),
        );

        if (response.statusCode == 200) {
          print("✅ Lưu thành công: ${word['word']}");
        } else {
          print("❌ Lỗi khi lưu ${word['word']}: ${response.body}");
        }
      } catch (e) {
        print("❌ Lỗi kết nối khi lưu ${word['word']}: $e");
      }
    }
  }
}
