import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'account_page.dart';
import 'home_page.dart';
import 'review_page.dart';
import 'statistics_page.dart';
import 'upload_result_page.dart';

String? _username;

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String? _avatarUrl;
  int _currentPage = 0;
  File? _selectedImage;
  List<String> _recognizedWords = [];

  /// Chọn ảnh từ máy ảnh hoặc thư viện
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });

      print("⚡ Ảnh đã chọn: ${_selectedImage!.path}");
      await _processImage(_selectedImage!); // Gửi ảnh ngay sau khi chọn
    } else {
      print("❌ Không chọn ảnh nào!");
    }
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _avatarUrl = prefs.getString('avatar_url');
      _username = prefs.getString('username') ?? "";
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  /// Resize ảnh để tối ưu tải lên server
  Future<File> resizeImage(File file, {int maxWidth = 640}) async {
    final rawImage = img.decodeImage(await file.readAsBytes())!;
    final resizedImage = img.copyResize(rawImage, width: maxWidth);

    final tempDir = await getTemporaryDirectory();
    final resizedFilePath =
        '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

    final resizedFile = File(resizedFilePath);
    await resizedFile.writeAsBytes(img.encodeJpg(resizedImage, quality: 85));
    return resizedFile;
  }

  /// Gửi ảnh lên server YOLO để nhận diện từ vựng
  static Future<List<String>> sendImageToServer(File image) async {
    var uri = Uri.parse("http://10.0.2.2:7860/predict"); // Thay bằng IP của bạn
    var request = http.MultipartRequest("POST", uri);
    request.files.add(await http.MultipartFile.fromPath("file", image.path));

    try {
      var response = await request.send().timeout(Duration(seconds: 10));
      var responseData = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseData);

      List<String> detectedWords = [];
      if (jsonResponse["detections"] != null) {
        for (var obj in jsonResponse["detections"]) {
          detectedWords.add(obj['class']);
        }
      }
      return detectedWords;
    } on TimeoutException {
      throw Exception("Server quá tải, hãy thử lại sau!");
    } catch (e) {
      throw Exception("Lỗi khi kết nối: $e");
    }
  }

  /// Xử lý ảnh và chuyển trang sau khi nhận diện từ vựng
  /// Gửi ảnh lên server YOLO và xử lý phản hồi
  Future<void> _processImage(File imageFile) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    var uri = Uri.parse("http://10.0.2.2:8010/predict");

    var request = http.MultipartRequest("POST", uri);
    request.files.add(
      await http.MultipartFile.fromPath("file", imageFile.path),
    );

    try {
      print("⚡ Đang gửi ảnh: ${imageFile.path}");

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      print("⚡ Response Data: $responseData");

      var jsonResponse = jsonDecode(responseData);

      // Kiểm tra nếu API không trả về ảnh nhận diện
      if (!jsonResponse.containsKey("processed_image_url")) {
        print("❌ Lỗi: API không trả về URL ảnh!");
        Navigator.pop(context);
        return;
      }

      // Nhận danh sách từ vựng nhận diện được
      Set<String> detectedWords = {};
      for (var obj in jsonResponse["detections"]) {
        detectedWords.add(obj['class']);
      }

      // Nhận ảnh đã nhận diện từ YOLOv10
      String detectedImageUrl = jsonResponse["processed_image_url"];

      print("⚡ URL ảnh nhận diện: $detectedImageUrl");

      Navigator.pop(context); // Đóng loading khi xong

      // Chuyển sang trang kết quả
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => UploadResultPage(
                detectedImageUrl: detectedImageUrl,
                words: detectedWords.toList(),
                imageFile: imageFile,
              ),
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: Text("Lỗi"),
              content: Text("Lỗi khi gửi ảnh: $e"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("OK"),
                ),
              ],
            ),
      );
    }
  }

  /// Hiển thị hộp thoại chọn ảnh từ camera hoặc thư viện
  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Chụp ảnh'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo),
                title: Text('Chọn ảnh từ thư viện'),
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

  @override
  Widget build(BuildContext context) {
    List<Widget> _pages = [
      HomePage(
        key: ValueKey(
          DateTime.now(),
        ), // 👈 ép rebuild HomePage mỗi lần chọn lại
        username: _username ?? "", // 👈 Truyền username thật ở đây
        onTapSeeMore: () {
          setState(() {
            _currentPage = 1;
          });
        },
        onTapSeeStatistics: () {
          setState(() {
            _currentPage = 3;
          });
        },
      ),
      ReviewPage(key: ValueKey(DateTime.now()), avatarUrl: _avatarUrl),
      Container(color: Colors.yellow),
      StatisticsPage(key: ValueKey(DateTime.now()), avatarUrl: _avatarUrl),
      AccountPage(
        key: ValueKey(DateTime.now()), // ép rebuild lại
        avatarUrl: _avatarUrl,
        onAvatarChanged: _loadUserInfo,
      ),
    ];

    return Scaffold(
      backgroundColor: Color(0xFF1F1F39),
      body: _pages[_currentPage],
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8,
        color: Color(0xFF363636),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, "Trang chủ", 0),
            _buildNavItem(Icons.book, "Ôn tập", 1),
            SizedBox(width: 40), // Khoảng cách cho FloatingActionButton
            _buildNavItem(Icons.bar_chart, "Thống kê", 3),
            _buildNavItem(Icons.person, "Tài khoản", 4),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showImageSourceDialog,
        backgroundColor: Color(0xFF8687E7),
        child: Icon(Icons.camera_alt, size: 30, color: Colors.white),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  /// Widget tạo item menu dưới cùng
  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = _currentPage == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentPage = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 24,
            color: isSelected ? Color(0xFF8687E7) : Colors.white,
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Color(0xFF8687E7) : Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
