import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UploadResultPage extends StatefulWidget {
  final String detectedImageUrl;
  final List<String> words;
  final File imageFile;

  UploadResultPage({
    this.detectedImageUrl = "http://10.0.2.2:8010/static/detected_image.jpg",
    required this.words,
    required this.imageFile,
  });

  @override
  _UploadResultPageState createState() => _UploadResultPageState();
}

class _UploadResultPageState extends State<UploadResultPage> {
  Map<String, String> wordDefinitions = {};
  Map<String, String> wordExamples = {};
  Set<String> _selectedWords = {};

  final FlutterTts flutterTts = FlutterTts();

  Future<void> _speak(String word) async {
    List<dynamic> languages = await flutterTts.getLanguages;

    if (languages.contains("en-US")) {
      await flutterTts.setLanguage("en-US");
    } else {
      print("⚠️ Thiết bị không hỗ trợ ngôn ngữ en-US!");
      return;
    }

    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.45);
    await flutterTts.speak(word);
  }

  @override
  void initState() {
    super.initState();

    flutterTts.getLanguages.then((langs) {
      print("📢 Hệ thống hỗ trợ các ngôn ngữ: $langs");
    });

    _fetchWordMeanings();
  }

  // Gọi API từ điển để lấy phiên âm & nghĩa đơn giản Tiếng Việt
  Future<void> _fetchWordMeanings() async {
    const dictionaryApiUrl = "https://api.dictionaryapi.dev/api/v2/entries/en/";
    const translateApiUrl =
        "https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=vi&dt=t&q=";
    String example = "";
    for (String word in widget.words) {
      try {
        var response = await http.get(Uri.parse(dictionaryApiUrl + word));

        if (response.statusCode == 200) {
          var data = jsonDecode(utf8.decode(response.bodyBytes));

          if (data.isNotEmpty && data[0].containsKey("meanings")) {
            String phonetic = data[0]["phonetic"] ?? "";
            String englishMeaning = "";

            // Lấy nghĩa đơn giản nhất (ưu tiên danh từ nếu có)
            for (var meaning in data[0]["meanings"]) {
              if (meaning["partOfSpeech"] == "noun" &&
                  meaning["definitions"].isNotEmpty) {
                englishMeaning = meaning["definitions"][0]["definition"];
                example =
                    meaning["definitions"][0]["example"] ?? ""; // ✅ gán giá trị
                break;
              }
            }

            // Nếu không tìm thấy danh từ, lấy nghĩa đầu tiên có thể
            if (englishMeaning.isEmpty && data[0]["meanings"].isNotEmpty) {
              englishMeaning =
                  data[0]["meanings"][0]["definitions"][0]["definition"];
              example =
                  data[0]["meanings"][0]["definitions"][0]["example"] ?? "";
            }

            // Dịch nghĩa sang Tiếng Việt nhưng chỉ lấy TỪ NGẮN GỌN
            var translationResponse = await http.get(
              Uri.parse(
                translateApiUrl + Uri.encodeComponent(word),
              ), // chỉ dịch từ gốc
            );

            String vietnameseMeaning = word; // Mặc định nếu không dịch được

            if (translationResponse.statusCode == 200) {
              var translationData = jsonDecode(translationResponse.body);
              vietnameseMeaning =
                  translationData[0][0][0]; // 🔥 Chỉ lấy nghĩa ngắn gọn
            }

            setState(() {
              wordDefinitions[word] = "$phonetic → ${vietnameseMeaning.trim()}";
              // Hiển thị nghĩa đơn giản
              wordExamples[word] = example;
            });
          } else {
            setState(() {
              wordDefinitions[word] = "Không tìm thấy nghĩa.";
            });
          }
        } else {
          setState(() {
            wordDefinitions[word] = "Không tìm thấy nghĩa.";
          });
        }
      } catch (e) {
        setState(() {
          wordDefinitions[word] = "Lỗi khi lấy dữ liệu.";
        });
      }
    }
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token'); // 🔥 Phải lưu token vào đây khi đăng nhập
  }

  // Lưu từ vựng vào mục ôn tập theo ngày hiện tại
  Future<void> _saveToReview() async {
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    List<Map<String, dynamic>> wordsToSave =
        _selectedWords.map((word) {
          return {
            "word": word,
            "meaning": wordDefinitions[word] ?? "Đang tải...",
            "example": wordExamples[word] ?? "This is a ${word}.",
            "date": today,
          };
        }).toList();

    final url = Uri.parse("http://10.0.2.2:8000/vocab/save_words");
    final token = await getToken(); // 🔑 Lấy từ storage/shared preferences

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(wordsToSave),
    );

    if (response.statusCode == 200) {
      print("✅ Đã lưu từ vựng vào server!");
    } else {
      print("❌ Lỗi khi lưu từ: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1F1F39),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Kết quả nhận diện',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Ảnh đã nhận diện từ YOLOv10
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                widget.detectedImageUrl +
                    "?t=${DateTime.now().millisecondsSinceEpoch}", // 🔥 Tránh cache ảnh cũ
                height: 250,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 20),

            // Tiêu đề danh sách từ vựng
            Text(
              "Từ vựng nhận diện được:",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),

            // Danh sách từ vựng và nghĩa với checkbox để chọn từ cần lưu
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: widget.words.length,
              itemBuilder: (context, index) {
                String word = widget.words[index];
                return CheckboxListTile(
                  value: _selectedWords.contains(word),
                  onChanged: (bool? selected) {
                    setState(() {
                      if (selected == true) {
                        _selectedWords.add(word);
                      } else {
                        _selectedWords.remove(word);
                      }
                    });
                  },
                  activeColor: Colors.green,
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          word,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: "NotoSansIPA",
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.volume_up, color: Colors.white),
                        onPressed: () => _speak(word),
                      ),
                    ],
                  ),

                  subtitle: Text(
                    wordDefinitions[word] ?? "Đang tải...",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      fontFamily: "NotoSansIPA",
                    ),
                  ),
                  controlAffinity:
                      ListTileControlAffinity
                          .leading, // Hiển thị checkbox bên trái
                );
              },
            ),

            SizedBox(height: 20),

            // Nút lưu từ vựng vào danh sách ôn tập
            ElevatedButton(
              onPressed: () {
                if (_selectedWords.isNotEmpty) {
                  _saveToReview();
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _selectedWords.isNotEmpty
                        ? Colors.blueAccent
                        : Colors.grey, // Nút xám nếu chưa chọn từ nào
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Lưu vào ôn tập",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
