import 'package:flutter/material.dart';

class PrivacySettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1F1F39),
      appBar: AppBar(
        title: Text("Thiết lập & Quyền riêng tư"),
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Cài đặt quyền riêng tư của bạn",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              _buildPrivacyOption(
                "Chia sẻ dữ liệu với ứng dụng",
                "Cho phép chia sẻ thông tin với các ứng dụng bên thứ ba",
                false,
              ),
              _buildPrivacyOption(
                "Cho phép chia sẻ thông tin vị trí",
                "Chia sẻ vị trí của bạn cho các dịch vụ bên ngoài",
                true,
              ),
              _buildPrivacyOption(
                "Hiển thị thông tin công khai",
                "Hiển thị thông tin cá nhân của bạn công khai",
                false,
              ),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  // Tạo một lựa chọn cài đặt quyền riêng tư
  Widget _buildPrivacyOption(
    String title,
    String description,
    bool initialValue,
  ) {
    return Card(
      color: Color(0xFFD3E5FF), // Màu nền của card
      margin: EdgeInsets.only(bottom: 16), // Khoảng cách dưới mỗi card
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            SizedBox(height: 8),
            Switch(
              value: initialValue,
              onChanged: (value) {
                // Xử lý thay đổi quyền riêng tư ở đây
                print("$title changed to $value");
              },
              activeColor: Colors.green,
              inactiveTrackColor: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  // Thêm nút lưu và quay lại
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            // Lưu cài đặt và quay lại
            Navigator.pop(context); // Quay lại trang trước
          },
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text("Lưu cài đặt", style: TextStyle(fontSize: 16)),
        ),
        SizedBox(height: 20),
        TextButton(
          onPressed: () {
            // Xử lý xóa tài khoản ở đây
            showDialog(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: Text(
                      "Xóa tài khoản",
                      style: TextStyle(color: Colors.red),
                    ),
                    content: Text("Bạn chắc chắn muốn xóa tài khoản của mình?"),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Đóng dialog
                        },
                        child: Text(
                          "Hủy",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Xử lý xóa tài khoản ở đây
                          Navigator.pop(context); // Đóng dialog
                        },
                        child: Text("Xóa", style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
            );
          },
          child: Text("Xóa tài khoản", style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}
