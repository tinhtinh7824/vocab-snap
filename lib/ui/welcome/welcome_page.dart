import 'package:flutter/material.dart';
import 'package:app_tieng_anh_de_an/ui/login/login_page.dart';
import 'package:app_tieng_anh_de_an/ui/register/register_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

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
      body: Column(
        children: [
          _buildTittleAndDesc(),
          const Spacer(),
          _buildButtonLogin(context),
          _buildButtonRegister(context),
        ],
      ),
    );
  }

  Widget _buildTittleAndDesc() {
    return Container(
      margin: EdgeInsets.only(top: 58),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Chào mừng bạn!",
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
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Hãy đăng nhập hoặc đăng ký để vào ứng dụng nhé!",
              style: TextStyle(
                color: Colors.white.withOpacity(0.67),
                fontFamily: "Lato",
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonLogin(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 48,
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8875FF),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
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

  Widget _buildButtonRegister(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 48,
      padding: EdgeInsets.symmetric(horizontal: 24),
      margin: EdgeInsets.symmetric(vertical: 28),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RegisterPage()),
          );
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          side: BorderSide(width: 1, color: const Color(0xFF8875FF)),
        ),
        child: const Text(
          "TẠO TÀI KHOẢN MỚI",
          style: const TextStyle(
            fontSize: 16,
            fontFamily: "Lato",
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
