import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  var _autoValidateMode = AutovalidateMode.disabled;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _onHandleRegisterSubmit() async {
    if (_autoValidateMode == AutovalidateMode.disabled) {
      setState(() {
        _autoValidateMode = AutovalidateMode.always;
      });
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final String username = _usernameController.text.trim();
    final String password = _passwordController.text;

    print("🔥 Sending Register Request...");
    print("📧 Username: $username");
    print("🔑 Password: $password");

    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2:8000/auth/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      );

      final decodedBody = utf8.decode(response.bodyBytes);
      final data = jsonDecode(decodedBody);

      print("📩 Server Response: ${response.statusCode}");
      print("📩 Response Body: $data");

      if (response.statusCode == 201) {
        _showSuccessDialog("Đăng ký thành công! Hãy đăng nhập.");
      } else {
        _showErrorDialog(data["detail"] ?? "Đăng ký thất bại");
      }
    } catch (e) {
      print("❌ Error: $e");
      _showErrorDialog("Không thể kết nối đến máy chủ.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.85),
          content: Text(
            message,
            style: TextStyle(
              color: Colors.black.withOpacity(0.87),
              fontFamily: "Lato",
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // đóng dialog
                Navigator.pop(
                  context,
                ); // quay lại LoginPage (nếu dùng push từ login → register)
                // Nếu bạn dùng Navigator.push thì đoạn trên là đủ.
                // Nếu dùng Navigator.pushReplacement thì cần dùng Navigator.push để mở lại LoginPage.
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.85),
          content: Text(
            message,
            style: TextStyle(
              color: Colors.black.withOpacity(0.87),
              fontFamily: "Lato",
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios_new_outlined,
            size: 28,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPageTitle(),
              SizedBox(height: 53),
              _buildFormRegister(),
              _buildOrSplitDivider(),
              _buildSocialRegister(),
              _buildHaveAccount(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageTitle() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20).copyWith(top: 40),
      child: Text(
        "ĐĂNG KÝ",
        style: TextStyle(
          color: Colors.white.withOpacity(0.87),
          fontFamily: "Lato",
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildFormRegister() {
    return Form(
      key: _formKey,
      autovalidateMode: _autoValidateMode,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUsernameField(),
            SizedBox(height: 25),
            _buildPasswordField(),
            SizedBox(height: 25),
            _buildConfirmPasswordField(),
            _buildRegisterButton(),
          ],
        ),
      ),
    );
  }

  Column _buildUsernameField() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Tên đăng nhập",
          style: TextStyle(
            color: Colors.white.withOpacity(0.87),
            fontFamily: "Lato",
            fontSize: 16,
          ),
        ),

        Container(
          margin: EdgeInsets.only(top: 8),
          child: TextFormField(
            controller: _usernameController, // ← THÊM DÒNG NÀY
            decoration: InputDecoration(
              hintText: "Hãy nhập tên tài khoản",
              hintStyle: TextStyle(
                color: Color(0xFF535353),
                fontFamily: "Lato",
                fontSize: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              fillColor: Color(0xFF1D1D1D),
              filled: true,
            ),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return "Yêu cầu nhập email";
              }

              final bool emailValid = RegExp(
                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
              ).hasMatch(value);
              if (!emailValid) {
                return "Email không hợp lệ!";
              }
              return null;
            },
            style: TextStyle(
              color: Colors.white,
              fontFamily: "Lato",
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Column _buildPasswordField() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Mật khẩu",
          style: TextStyle(
            color: Colors.white.withOpacity(0.87),
            fontFamily: "Lato",
            fontSize: 16,
          ),
        ),

        Container(
          margin: EdgeInsets.only(top: 8),
          child: TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              hintText: "Hãy nhập mật khẩu",
              hintStyle: TextStyle(
                color: Color(0xFF535353),
                fontFamily: "Lato",
                fontSize: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              fillColor: Color(0xFF1D1D1D),
              filled: true,
            ),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return "Mật khẩu không thể trống.";
              }
              if (value.length < 6) {
                return "Mật khẩu phải từ 6 kí tự trở lên";
              }
              return null;
            },
            style: TextStyle(
              color: Colors.white,
              fontFamily: "Lato",
              fontSize: 16,
            ),
            obscureText: true,
          ),
        ),
      ],
    );
  }

  Column _buildConfirmPasswordField() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Xác nhận mật khẩu",
          style: TextStyle(
            color: Colors.white.withOpacity(0.87),
            fontFamily: "Lato",
            fontSize: 16,
          ),
        ),

        Container(
          margin: EdgeInsets.only(top: 8),
          child: TextFormField(
            decoration: InputDecoration(
              hintText: "Hãy nhập lại mật khẩu",
              hintStyle: TextStyle(
                color: Color(0xFF535353),
                fontFamily: "Lato",
                fontSize: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              fillColor: Color(0xFF1D1D1D),
              filled: true,
            ),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return "Xác nhận mật khẩu không thể trống.";
              }
              if (value != _passwordController.text) {
                return "Mật khẩu không khớp.";
              }
              return null;
            },
            style: TextStyle(
              color: Colors.white,
              fontFamily: "Lato",
              fontSize: 16,
            ),
            obscureText: true,
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return Container(
      width: double.infinity,
      height: 48,
      margin: EdgeInsets.only(top: 70),
      child: ElevatedButton(
        onPressed: _onHandleRegisterSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8875FF),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          disabledBackgroundColor: Color(0xFF8687E7).withOpacity(0.5),
        ),
        child: const Text(
          "ĐĂNG KÝ",
          style: const TextStyle(
            fontSize: 16,
            fontFamily: "Lato",
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildOrSplitDivider() {
    return Container(
      margin: EdgeInsets.only(top: 45, bottom: 40),
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              width: double.infinity,
              color: Color(0xFF979797),
            ),
          ),
          const Text(
            "Hoặc",
            style: const TextStyle(
              fontSize: 16,
              fontFamily: "Lato",
              color: Color(0xFF979797),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              width: double.infinity,
              color: Color(0xFF979797),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialRegister() {
    return Column(children: [_buildSocialGoogleLogin()]);
  }

  Widget _buildSocialGoogleLogin() {
    return Container(
      width: double.infinity,
      height: 48,
      padding: EdgeInsets.symmetric(horizontal: 24),
      margin: EdgeInsets.symmetric(vertical: 28),
      child: ElevatedButton(
        onPressed: () {
          // Xu ly sau
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          side: BorderSide(width: 1, color: const Color(0xFF8875FF)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/google.png",
              width: 24,
              height: 24,
              fit: BoxFit.contain,
            ),
            Container(
              margin: EdgeInsets.only(left: 10),
              child: const Text(
                "Đăng ký bằng Google",
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: "Lato",
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHaveAccount(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: RichText(
        text: TextSpan(
          text: "Đã có tài khoản? ",
          style: const TextStyle(
            fontSize: 12,
            fontFamily: "Lato",
            color: Color(0xFF979797),
          ),
          children: [
            TextSpan(
              text: "Đăng nhập",
              style: const TextStyle(
                fontSize: 12,
                fontFamily: "Lato",
                color: Colors.white,
              ),
              recognizer:
                  TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.pop(context);
                    },
            ),
          ],
        ),
      ),
    );
  }
}
