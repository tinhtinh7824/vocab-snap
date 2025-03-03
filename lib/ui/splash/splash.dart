import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  Future<void> _checkAppState(BuildContext context) async {
    // Kiem tra xem co kOnboardingCompleted.
    final isCompleted = await _isOnboardingCompleted();
  }

  Future<bool> _isOnboardingCompleted() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final result = prefs.getBool("kOnboardingCompleted");
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      body: SafeArea(child: _buildBodyPage()),
    );
  }

  Widget _buildBodyPage() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [_buildIconSplash(), _buildTextSplash()],
      ),
    );
  }

  Widget _buildIconSplash() {
    return Image.asset(
      "assets/images/Vector.png",
      width: 95,
      height: 80,
      fit: BoxFit.contain,
    );
  }

  Widget _buildTextSplash() {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Welcome to UpTodo",
            style: TextStyle(
              color: Colors.white.withOpacity(0.87),
              fontFamily: "Lato",
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 26),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 38),
          child: Text(
            "Bạn hãy đăng nhập hoặc tạo tài khoản mới để tiếp tục nhé!",
            style: TextStyle(
              color: Colors.white.withOpacity(0.67),
              fontFamily: "Lato",
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
