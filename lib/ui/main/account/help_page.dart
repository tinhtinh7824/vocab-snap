import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1F1F39),
      appBar: AppBar(
        title: Text("Trợ giúp"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Quay lại trang tài khoản
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildFaqItem(
              "1. Làm sao để thay đổi mật khẩu?",
              "Bạn có thể thay đổi mật khẩu từ phần 'Cài đặt' trong ứng dụng.",
            ),
            _buildFaqItem(
              "2. Làm thế nào để thêm từ vựng mới?",
              "Bạn có thể thêm từ vựng từ trang chính bằng cách nhấn vào biểu tượng 'Thêm từ'.",
            ),
            _buildFaqItem(
              "3. Làm sao để xóa từ vựng?",
              "Chọn từ vựng bạn muốn xóa, sau đó nhấn vào nút 'Xóa' ở góc trên bên phải.",
            ),
            _buildFaqItem(
              "4. Tôi có thể liên hệ hỗ trợ ở đâu?",
              "Nếu bạn gặp phải bất kỳ sự cố nào, vui lòng liên hệ với chúng tôi qua email hỗ trợ: support@example.com.",
            ),
            _buildFaqItem(
              "5. Làm sao để khôi phục tài khoản?",
              "Bạn có thể khôi phục tài khoản qua phần 'Quên mật khẩu' trên trang đăng nhập.",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFFD3E5FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(answer, style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
