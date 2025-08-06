import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static Future<String?> fetchAvatarUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) return null;

    final response = await http.get(
      Uri.parse("http://10.0.2.2:8000/user/me"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["avatar_url"];
    } else {
      print("❌ Lỗi lấy avatar: ${response.statusCode}");
      return null;
    }
  }
}
