import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  bool _passwordChanged = false;

  Future<void> _changePassword() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await http.post(
      Uri.parse('http://localhost:8000/user/change_password'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'old_password': _oldPasswordController.text,
        'new_password': _newPasswordController.text,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        _passwordChanged = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✅ Mật khẩu đã được thay đổi thành công!"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      final error = jsonDecode(response.body)['detail'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Lỗi: $error"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1F1F39),
      appBar: AppBar(
        title: Text("Đổi mật khẩu"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _usernameController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Tên tài khoản",
                filled: true,
                fillColor: Colors.white10,
                labelStyle: TextStyle(color: Colors.white70),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _oldPasswordController,
              obscureText: true,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Mật khẩu cũ",
                filled: true,
                fillColor: Colors.white10,
                labelStyle: TextStyle(color: Colors.white70),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Mật khẩu mới",
                filled: true,
                fillColor: Colors.white10,
                labelStyle: TextStyle(color: Colors.white70),
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF8875FF),
                ),
                child: Text("Đổi mật khẩu"),
              ),
            ),
            if (_passwordChanged)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Center(
                  child: Text(
                    "✅ Mật khẩu đã được thay đổi thành công!",
                    style: TextStyle(color: Colors.greenAccent),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
