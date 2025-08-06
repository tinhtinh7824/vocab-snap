import 'dart:convert';
import 'dart:io';

import 'package:app_tieng_anh_de_an/ui/main/account/edit_profile_page.dart';
import 'package:app_tieng_anh_de_an/ui/main/account/favorites_page.dart';
import 'package:app_tieng_anh_de_an/ui/main/account/help_page.dart';
import 'package:app_tieng_anh_de_an/ui/main/account/privacy_settings_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountPage extends StatefulWidget {
  final String? avatarUrl;
  final VoidCallback onAvatarChanged;

  const AccountPage({
    Key? key,
    required this.avatarUrl,
    required this.onAvatarChanged,
  }) : super(key: key);

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String? avatarUrl;

  Future<void> _uploadAvatar(File imageFile) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";

    var uri = Uri.parse("http://10.0.2.2:8000/user/upload_avatar");
    var request = http.MultipartRequest("POST", uri);
    request.headers["Authorization"] = "Bearer $token";
    request.files.add(
      await http.MultipartFile.fromPath(
        "file",
        imageFile.path,
        contentType: MediaType('image', 'jpeg'),
      ),
    );

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await prefs.setString('avatar_url', data["avatar_url"]);
        widget.onAvatarChanged(); // cập nhật lại avatar từ MainPage
        print("✅ Đã cập nhật ảnh đại diện!");
      } else {
        print("❌ Lỗi khi upload avatar: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Lỗi kết nối khi upload avatar: $e");
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);
    if (picked != null) {
      final file = File(picked.path);
      await _uploadAvatar(file);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1F1F39),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            right: 16,
          ),
          color: Colors.transparent,
          alignment: Alignment.centerLeft,
          child: Text(
            'Tài khoản',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),

      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: () {
                  _showChangeAvatarOptions(context);
                },
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          widget.avatarUrl != null &&
                                  widget.avatarUrl!.isNotEmpty
                              ? NetworkImage(widget.avatarUrl!)
                              : AssetImage('assets/images/illustration-2.png')
                                  as ImageProvider,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 15,
                        backgroundColor: Colors.blue,
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
            _buildAccountOption(context, "Ưa thích", Icons.favorite, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FavoritesPage()),
              );
            }),
            _buildAccountOption(context, "Sửa tài khoản", Icons.edit, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfilePage()),
              );
            }),
            _buildAccountOption(
              context,
              "Thiết lập và quyền riêng tư",
              Icons.settings,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PrivacySettingsPage(),
                  ),
                );
              },
            ),
            _buildAccountOption(context, "Trợ giúp", Icons.help, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HelpPage()),
              );
            }),
            _buildAccountOption(context, "Đăng xuất", Icons.logout, () {
              _logout(context);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountOption(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: TextStyle(color: Colors.white, fontSize: 18)),
      trailing: Icon(Icons.chevron_right, color: Colors.white),
      onTap: onTap,
    );
  }

  void _showChangeAvatarOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.camera),
                title: Text('Chụp ảnh mới'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo),
                title: Text('Chọn từ thư viện'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

void _logout(BuildContext context) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder:
        (context) => AlertDialog(
          title: Text("Xác nhận đăng xuất"),
          content: Text("Bạn có chắc chắn muốn đăng xuất không?"),
          actions: [
            TextButton(
              child: Text("Huỷ"),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text("Đăng xuất", style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
  );

  if (confirm == true) {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }
}
