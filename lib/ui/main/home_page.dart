import 'dart:convert';
import 'dart:io';

import 'package:app_tieng_anh_de_an/ui/main/review_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'upload_result_page.dart';

class HomePage extends StatefulWidget {
  final String username;
  final VoidCallback onTapSeeMore;
  final VoidCallback onTapSeeStatistics;

  const HomePage({
    Key? key,
    required this.username,
    required this.onTapSeeMore,
    required this.onTapSeeStatistics,
  }) : super(
         key: key,
       ); // thêm dòng này để nhận key

  @override
  _HomePageState createState() =>
      _HomePageState();
}

class _HomePageState
    extends State<HomePage> {
  String? _avatarUrl;
  File? _image;
  Map<String, String> wordDefinitions =
      {};
  int _targetWords = 30;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchReviewWords(); // gọi lại API khi HomePage được hiển thị
  }

  Future<void>
  _fetchReviewWords() async {
    final prefs =
        await SharedPreferences.getInstance();
    final token =
        prefs.getString("token") ?? "";

    try {
      final response = await http.get(
        Uri.parse(
          "http://10.0.2.2:8000/vocab/review_words",
        ),
        headers: {
          "Authorization":
              "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final decoded = utf8.decode(
          response.bodyBytes,
        );
        final List<dynamic> data =
            jsonDecode(decoded);

        setState(() {
          reviewWords =
              data
                  .map<
                    Map<String, String>
                  >(
                    (item) => {
                      "word":
                          item["word"],
                      "meaning":
                          item["meaning"],
                      "date":
                          item["date"],
                    },
                  )
                  .toList();
        });
      } else {
        print(
          "❌ Lỗi khi tải từ vựng: ${response.statusCode}",
        );
      }
    } catch (e) {
      print("❌ Lỗi kết nối: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _loadTargetWords();
    _loadAvatarUrl();
  }

  Future<void> _loadAvatarUrl() async {
    final prefs =
        await SharedPreferences.getInstance();
    setState(() {
      _avatarUrl = prefs.getString(
        'avatar_url',
      );
    });
  }

  Future<void>
  _loadTargetWords() async {
    final prefs =
        await SharedPreferences.getInstance();
    setState(() {
      _targetWords =
          prefs.getInt('targetWords') ??
          30;
    });
  }

  Future<void> _pickImage(
    ImageSource source,
  ) async {
    final pickedFile =
        await ImagePicker().pickImage(
          source: source,
        );
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      print(
        "⚡ Ảnh đã chọn: ${_image!.path}",
      ); // Log kiểm tra
      await _uploadImage(_image!);
    } else {
      print("❌ Không chọn ảnh nào!");
    }
  }

  Future<void> _uploadImage(
    File imageFile,
  ) async {
    print(
      "⚡ Bắt đầu gửi ảnh đến API...",
    );

    var uri = Uri.parse(
      "http://10.0.2.2:8000/yolo/predict",
    );

    var request = http.MultipartRequest(
      "POST",
      uri,
    );
    request.files.add(
      await http.MultipartFile.fromPath(
        "file",
        imageFile.path,
      ),
    );

    try {
      print(
        "⚡ Đang gửi ảnh: ${imageFile.path}",
      );

      var response =
          await request.send();
      var responseData =
          await response.stream
              .bytesToString();
      print(
        "⚡ Response Data: $responseData",
      );

      var jsonResponse = jsonDecode(
        responseData,
      );

      if (!jsonResponse.containsKey(
        "processed_image_url",
      )) {
        print(
          "❌ Lỗi: API không trả về URL ảnh!",
        );
        return;
      }

      // Nhận danh sách từ vựng nhận diện được
      Set<String> detectedWords = {};
      for (var obj
          in jsonResponse["detections"]) {
        detectedWords.add(obj['class']);
      }

      // Nhận ảnh đã nhận diện từ YOLOv10
      String detectedImageUrl =
          jsonResponse["processed_image_url"];

      print(
        "⚡ URL ảnh nhận diện: $detectedImageUrl",
      );

      // Chuyển sang trang kết quả
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (
                context,
              ) => UploadResultPage(
                detectedImageUrl:
                    detectedImageUrl,
                words:
                    detectedWords
                        .toList(),
                imageFile: imageFile,
              ),
        ),
      );
    } catch (e) {
      print("❌ Lỗi khi gửi ảnh: $e");
    }
  }

  Future<void> _fetchWordMeanings(
    Set<String> words,
  ) async {
    const dictionaryApiUrl =
        "https://api.dictionaryapi.dev/api/v2/entries/en/";
    for (String word in words) {
      try {
        var response = await http.get(
          Uri.parse(
            dictionaryApiUrl + word,
          ),
        );
        if (response.statusCode ==
            200) {
          var data = jsonDecode(
            response.body,
          );
          String meaning =
              data[0]["meanings"][0]["definitions"][0]["definition"];
          String phonetic =
              data[0]["phonetics"][0]["text"] ??
              "";

          setState(() {
            wordDefinitions[word] =
                "$phonetic → $meaning";
          });
        }
      } catch (e) {
        setState(() {
          wordDefinitions[word] =
              "Không tìm thấy nghĩa.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(),
          _buildCaptureAndUploadSection(),
          SizedBox(height: 25),
          _buildLearnedVocabularySection(
            context,
          ),
          SizedBox(height: 25),
          _buildLearningStatisticsSection(
            context,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    String avatarUrl = _avatarUrl ?? "";

    return Container(
      color: Color(0xFF3D5CFF),
      width: double.infinity,
      padding: EdgeInsets.only(
        top: 50,
        left: 16,
        right: 16,
        bottom: 20,
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment
                .spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  "Xin chào, ${widget.username}",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight:
                        FontWeight.bold,
                  ),
                  overflow:
                      TextOverflow
                          .ellipsis,
                ),
                SizedBox(height: 10),
                Text(
                  "Hãy bắt đầu học từ vựng nào!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          CircleAvatar(
            radius: 30,
            backgroundColor:
                Colors.white,
            child: ClipOval(
              child:
                  avatarUrl != null
                      ? Image.network(
                        avatarUrl!,
                        fit:
                            BoxFit
                                .cover,
                        width: 55,
                        height: 55,
                        errorBuilder: (
                          context,
                          error,
                          stackTrace,
                        ) {
                          return Image.asset(
                            'assets/images/illustration-2.png',
                            fit:
                                BoxFit
                                    .cover,
                            width: 55,
                            height: 55,
                          );
                        },
                      )
                      : Image.asset(
                        'assets/images/illustration-2.png',
                        fit:
                            BoxFit
                                .cover,
                        width: 55,
                        height: 55,
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Widget
  _buildCaptureAndUploadSection() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFEAF2FF),
        borderRadius:
            BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      padding: EdgeInsets.all(24),
      margin: EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Gửi ảnh, học ngay từ mới!',
            style: TextStyle(
              fontSize: 20,
              fontWeight:
                  FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 30),
          Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .spaceEvenly,
            children: [
              _buildAnimatedIcon(
                icon: Icons.camera_alt,
                label: 'Chụp ảnh',
                onTap:
                    () => _pickImage(
                      ImageSource
                          .camera,
                    ),
              ),
              _buildAnimatedIcon(
                icon:
                    Icons
                        .photo_camera_back,
                label: 'Chọn ảnh',
                onTap:
                    () => _pickImage(
                      ImageSource
                          .gallery,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedIcon({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          TweenAnimationBuilder(
            tween: Tween<double>(
              begin: 1.0,
              end: 1.0,
            ),
            duration: Duration(
              milliseconds: 300,
            ),
            builder: (
              context,
              scale,
              child,
            ) {
              return Listener(
                onPointerDown: (_) {
                  (context as Element)
                      .markNeedsBuild();
                },
                onPointerUp: (_) {
                  (context as Element)
                      .markNeedsBuild();
                },
                child: AnimatedScale(
                  scale: 1.0,
                  duration: Duration(
                    milliseconds: 150,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color:
                          Colors.white,
                      borderRadius:
                          BorderRadius.circular(
                            16,
                          ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors
                              .grey
                              .withOpacity(
                                0.3,
                              ),
                          blurRadius: 8,
                          offset:
                              Offset(
                                0,
                                4,
                              ),
                        ),
                      ],
                    ),
                    padding:
                        EdgeInsets.all(
                          20,
                        ),
                    child: Icon(
                      icon,
                      size: 50,
                      color:
                          Colors
                              .blueAccent,
                    ),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight:
                  FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLearnedVocabularySection(
    BuildContext context,
  ) {
    List<Map<String, String>>
    recentWords = List.from(
      reviewWords,
    );
    recentWords.sort(
      (a, b) => b["date"]!.compareTo(
        a["date"]!,
      ),
    );
    recentWords =
        recentWords.take(3).toList();

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 16,
          ),
          child: Text(
            'Những từ vựng đã học',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 10),
        Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(
            horizontal: 16,
          ),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFF2F2F3E),
            borderRadius:
                BorderRadius.circular(
                  16,
                ),
            boxShadow: [
              BoxShadow(
                color: Colors.white
                    .withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 1,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
              // Kiểm tra nếu có từ vựng để hiển thị
              if (recentWords
                  .isNotEmpty)
                ...recentWords.map(
                  (wordData) => Padding(
                    padding:
                        EdgeInsets.symmetric(
                          vertical: 4,
                        ),
                    child: Text(
                      "${wordData['word']} ${wordData['meaning']}",
                      style: TextStyle(
                        color:
                            Colors
                                .white,
                        fontSize: 16,
                        fontFamily:
                            "NotoSansIPA",
                      ),
                    ),
                  ),
                )
              else
                // Nếu không có từ vựng nào
                Center(
                  child: Text(
                    "Chưa có từ vựng đã học.",
                    style: TextStyle(
                      color:
                          Colors
                              .white70,
                      fontSize: 16,
                    ),
                  ),
                ),

              SizedBox(height: 10),

              // Nút "Xem thêm"
              GestureDetector(
                onTap: () {
                  widget.onTapSeeMore();
                },
                child: Center(
                  child: Text(
                    'Xem thêm',
                    style: TextStyle(
                      color:
                          Colors.blue,
                      fontSize: 16,
                      fontWeight:
                          FontWeight
                              .bold,
                      decoration:
                          TextDecoration
                              .underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget
  _buildLearningStatisticsSection(
    BuildContext context,
  ) {
    Map<
      String,
      List<Map<String, String>>
    >
    groupedWords = {};
    for (var wordData in reviewWords) {
      groupedWords
          .putIfAbsent(
            wordData["date"]!,
            () => [],
          )
          .add(wordData);
    }

    List<String> dates =
        groupedWords.keys.toList();
    dates.sort(
      (a, b) => b.compareTo(a),
    );

    List<String> displayedDates =
        dates.length > 2
            ? dates.sublist(0, 2)
            : dates;

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 16,
          ),
          child: Text(
            'Thống kê quá trình học',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 10),

        Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(
            horizontal: 16,
          ),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFF2F2F3E),
            borderRadius:
                BorderRadius.circular(
                  16,
                ),
            boxShadow: [
              BoxShadow(
                color: Colors.white
                    .withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 1,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              if (displayedDates
                  .isNotEmpty)
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,
                  children:
                      displayedDates.map((
                        date,
                      ) {
                        int
                        learnedWords =
                            groupedWords[date]!
                                .length;
                        return Expanded(
                          child: Padding(
                            padding:
                                EdgeInsets.symmetric(
                                  horizontal:
                                      5,
                                ),
                            child: _buildStatCard(
                              date,
                              learnedWords,
                            ),
                          ),
                        );
                      }).toList(),
                )
              else
                Center(
                  child: Text(
                    "Chưa có dữ liệu thống kê.",
                    style: TextStyle(
                      color:
                          Colors
                              .white70,
                      fontSize: 16,
                    ),
                  ),
                ),

              SizedBox(height: 10),

              GestureDetector(
                onTap: () {
                  widget
                      .onTapSeeStatistics();
                },
                child: Center(
                  child: Text(
                    'Xem thêm',
                    style: TextStyle(
                      color:
                          Colors.blue,
                      fontSize: 16,
                      fontWeight:
                          FontWeight
                              .bold,
                      decoration:
                          TextDecoration
                              .underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  ///  Widget tạo từng thẻ thống kê
  Widget _buildStatCard(
    String date,
    int learnedWords,
  ) {
    int targetWords =
        _targetWords; // Mục tiêu mặc định mỗi ngày

    return Container(
      margin: EdgeInsets.only(
        bottom: 10,
      ),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFD3E5FF),
        borderRadius:
            BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 1,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'Ngày ${_formatDate(date)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight:
                  FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 5),
          LinearProgressIndicator(
            value:
                learnedWords /
                targetWords,
            backgroundColor:
                Colors.white,
            valueColor:
                AlwaysStoppedAnimation<
                  Color
                >(
                  learnedWords >=
                          targetWords
                      ? Colors.green
                      : Colors.blue,
                ),
          ),
          SizedBox(height: 5),
          Text(
            'Số từ vựng đã học',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          Text(
            '$learnedWords / $targetWords',
            style: TextStyle(
              fontSize: 14,
              fontWeight:
                  FontWeight.bold,
              color:
                  learnedWords >=
                          targetWords
                      ? Colors.green
                      : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDate(String date) {
  try {
    final parts = date.split("-");
    if (parts.length == 3) {
      return "${parts[2]}/${parts[1]}/${parts[0]}";
    }
  } catch (_) {}
  return date;
}
