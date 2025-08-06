import 'dart:convert';

import 'package:app_tieng_anh_de_an/ui/main/main_page.dart';
import 'package:app_tieng_anh_de_an/ui/register/register_page.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  var _autoValidateMode = AutovalidateMode.disabled;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedUsername();
  }

  Future<void> _loadSavedUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('username');
    if (savedUsername != null) {
      _usernameController.text = savedUsername;
    }
  }

  Future<void> _onHandleLoginSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2:8000/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": _usernameController.text,
          "password": _passwordController.text,
        }),
      );

      final decodedBody = utf8.decode(response.bodyBytes);
      final data = jsonDecode(decodedBody);

      if (response.statusCode == 200) {
        final token = data["access_token"]; // Lấy token từ server trả về
        final username = _usernameController.text;

        print("🔐 Token nhận được: $token");

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('username', username);

        // Gọi API /user/profile để lấy avatar_url
        final profileResponse = await http.get(
          Uri.parse("http://10.0.2.2:8000/user/profile"),
          headers: {"Authorization": "Bearer $token"},
        );

        print("📥 /user/profile status: ${profileResponse.statusCode}");
        print("📥 /user/profile body: ${profileResponse.body}");

        if (profileResponse.statusCode == 200) {
          final profileData = jsonDecode(
            utf8.decode(profileResponse.bodyBytes),
          );
          final avatarUrl = profileData["avatar_url"] ?? "";
          await prefs.setString('avatar_url', avatarUrl); // Lưu avatar_url
        } else {
          print("❌ Không thể lấy thông tin avatar");
        }

        // Chuyển sang trang chính
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainPage()),
        );
      } else {
        _showErrorDialog(data["detail"] ?? "Đăng nhập thất bại");
      }
    } catch (e) {
      _showErrorDialog("Không thể kết nối đến máy chủ.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      final GoogleSignInAccount? account = await GoogleSignIn().signIn();

      if (account == null) {
        print("❌ Người dùng huỷ đăng nhập Google");
        return;
      }

      print("✅ Đăng nhập Google thành công: ${account.email}");

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', account.email);
      await prefs.setString('avatar_url', account.photoUrl ?? "");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainPage()),
      );
    } catch (e) {
      print("❌ Lỗi khi đăng nhập bằng Google: $e");
      _showErrorDialog("Không thể đăng nhập bằng Google\nLỗi: $e");
    }
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
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
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
              _buildFormLogin(),
              _buildOrSplitDivider(),
              _buildSocialLogin(),
              _buildHaveNotAccount(context),
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
        "ĐĂNG NHẬP",
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

  Widget _buildFormLogin() {
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
            _buildLoginButton(),
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
            controller: _usernameController,
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

  Widget _buildLoginButton() {
    return Container(
      width: double.infinity,
      height: 48,
      margin: EdgeInsets.only(top: 70),
      child: ElevatedButton(
        onPressed: _onHandleLoginSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8875FF),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          disabledBackgroundColor: Color(0xFF8687E7).withOpacity(0.5),
        ),
        child: const Text(
          "ĐĂNG NHẬP",
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

  Widget _buildSocialLogin() {
    return Column(children: [_buildSocialGoogleLogin()]);
  }

  Widget _buildSocialGoogleLogin() {
    return Container(
      width: double.infinity,
      height: 48,
      padding: EdgeInsets.symmetric(horizontal: 24),
      margin: EdgeInsets.symmetric(vertical: 28),
      child: ElevatedButton(
        onPressed: _handleGoogleSignIn,
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
                "Đăng nhập bằng Google",
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
}

Widget _buildHaveNotAccount(BuildContext context) {
  return Container(
    alignment: Alignment.center,
    child: RichText(
      text: TextSpan(
        text: "Chưa có tài khoản? ",
        style: const TextStyle(
          fontSize: 12,
          fontFamily: "Lato",
          color: Color(0xFF979797),
        ),
        children: [
          TextSpan(
            text: "Đăng ký",
            style: const TextStyle(
              fontSize: 12,
              fontFamily: "Lato",
              color: Colors.white,
            ),
            recognizer:
                TapGestureRecognizer()
                  ..onTap = () {
                    _goToRegisterPage(context);
                  },
          ),
        ],
      ),
    ),
  );
}

void _goToRegisterPage(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => RegisterPage()),
  );
}
