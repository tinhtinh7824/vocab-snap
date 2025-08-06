import 'package:flutter/material.dart';

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1F1F39),
      appBar: AppBar(
        title: Text("Ưa thích"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Quay lại trang tài khoản
          },
        ),
      ),
      body: Center(
        child: Text("Danh sách mục yêu thích của bạn!",
            style: TextStyle(color: Colors.white, fontSize: 18)),
      ),
    );
  }
}
