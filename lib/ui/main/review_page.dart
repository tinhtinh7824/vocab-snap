import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'flashcard_page.dart';
import 'mini_quiz_page.dart';

// Danh sách ôn tập toàn cục
List<Map<String, String>> reviewWords = [];

class ReviewPage extends StatefulWidget {
  final String? avatarUrl;
  const ReviewPage({Key? key, this.avatarUrl}) : super(key: key);

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  String selectedLevelFilter = "Tất cả";
  String searchQuery = "";
  String? avatarUrl;

  final FlutterTts flutterTts = FlutterTts();

  Future<void> _speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(text);
  }

  @override
  void initState() {
    super.initState();
    _fetchReviewWordsFromAPI();
    _loadAvatarUrl();
  }

  Future<void> _loadAvatarUrl() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      avatarUrl = prefs.getString("avatar_url");
    });
  }

  Future<void> _fetchReviewWordsFromAPI() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";

    try {
      final response = await http.get(
        Uri.parse("http://10.0.2.2:8000/vocab/review_words"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        final List<dynamic> data = jsonDecode(decoded);

        setState(() {
          final Map<String, Map<String, String>> uniqueWordsMap = {};

          for (var item in data) {
            String word = item["word"];
            String date = item["date"];
            if (!uniqueWordsMap.containsKey(word) ||
                date.compareTo(uniqueWordsMap[word]!["date"]!) > 0) {
              uniqueWordsMap[word] = {
                "word": word,
                "meaning": item["meaning"] as String,
                "example": item["example"] as String? ?? "",
                "date": date,
                "level": item["level"].toString(),
              };
            }
          }

          reviewWords = uniqueWordsMap.values.toList();
        });
      } else {
        print("❌ Lỗi khi tải từ vựng: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Lỗi kết nối: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<Map<String, String>>> groupedWords = {};
    for (var wordData in reviewWords) {
      groupedWords.putIfAbsent(wordData["date"]!, () => []).add(wordData);
    }

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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ôn tập từ vựng',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              CircleAvatar(
                backgroundImage:
                    (widget.avatarUrl ?? "").trim().isNotEmpty
                        ? NetworkImage(widget.avatarUrl!)
                        : AssetImage('assets/images/illustration-2.png')
                            as ImageProvider,
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 15),

            // Học flashcard + mini quiz
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FlashcardPage(words: reviewWords),
                          ),
                        );
                      },
                      icon: Icon(Icons.style),
                      label: Text("Flashcard"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF4C5AFE),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        textStyle: TextStyle(fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 5,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MiniQuizPage(words: reviewWords),
                          ),
                        );
                      },
                      icon: Icon(Icons.quiz),
                      label: Text("Kiểm tra"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrangeAccent,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        textStyle: TextStyle(fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 15),

            // Từ vựng đã nhận diện
            Text(
              'Từ vựng đã nhận diện',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),

            // Bộ lọc: tất cả, đang học, đã thành thạo
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children:
                  ["Tất cả", "Đang học", "Đã thành thạo"].map((filter) {
                    final isSelected = selectedLevelFilter == filter;
                    return ChoiceChip(
                      label: Text(
                        filter,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: Color(0xFF4C5AFE),
                      backgroundColor: Colors.grey.shade700,
                      shape: StadiumBorder(),
                      onSelected: (_) {
                        setState(() {
                          selectedLevelFilter = filter;
                        });
                      },
                    );
                  }).toList(),
            ),
            SizedBox(height: 10),

            // Thanh tìm kiếm
            _buildSearchBox(),

            // Danh sách từ vựng
            Expanded(child: _buildVocabularyList(groupedWords)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBox() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.white70),
          SizedBox(width: 5),
          Expanded(
            child: TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm từ vựng',
                hintStyle: TextStyle(color: Colors.white70),
                border: InputBorder.none,
              ),
              onChanged: (query) {
                setState(() {
                  searchQuery = query.toLowerCase();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVocabularyList(
    Map<String, List<Map<String, String>>> groupedWords,
  ) {
    List<String> sortedDates = groupedWords.keys.toList();
    sortedDates.sort((a, b) => b.compareTo(a));

    return Expanded(
      child:
          groupedWords.isEmpty
              ? Center(
                child: Text(
                  "Chưa có từ vựng để ôn tập.",
                  style: TextStyle(color: Colors.white70, fontSize: 18),
                ),
              )
              : ListView(
                children:
                    sortedDates.map((date) {
                      final words =
                          groupedWords[date]!.where((wordData) {
                            final word = wordData["word"]!.toLowerCase();
                            final level =
                                int.tryParse(wordData["level"] ?? "0") ?? 0;

                            bool matchesSearch = word.contains(searchQuery);
                            bool matchesFilter =
                                selectedLevelFilter == "Tất cả" ||
                                (selectedLevelFilter == "Đang học" &&
                                    level == 1) ||
                                (selectedLevelFilter == "Đã thành thạo" &&
                                    level == 2);

                            return matchesSearch && matchesFilter;
                          }).toList();

                      return words.isNotEmpty
                          ? _buildVocabularySection(date, words)
                          : SizedBox.shrink();
                    }).toList(),
              ),
    );
  }

  Widget _buildVocabularySection(String date, List<Map<String, String>> words) {
    String formattedDate = date;
    try {
      final parts = date.split("-");
      if (parts.length == 3) {
        formattedDate = "${parts[2]}/${parts[1]}/${parts[0]}";
      }
    } catch (_) {}

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            formattedDate,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                words.map((wordData) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      wordData["word"]!,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "NotoSansIPA",
                                      ),
                                    ),
                                    SizedBox(height: 3),
                                    Text(
                                      wordData["meaning"]!,
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                        fontStyle: FontStyle.italic,
                                        fontFamily: "NotoSansIPA",
                                      ),
                                    ),
                                    if ((wordData["example"] ?? "")
                                        .isNotEmpty) ...[
                                      SizedBox(height: 3),
                                      Text(
                                        'Ví dụ: ${wordData["example"]!}',
                                        style: TextStyle(
                                          color: Colors.blue[200],
                                          fontSize: 13,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.volume_up,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  _speak(wordData["word"]!);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  String _getLevelLabel(String? levelStr) {
    int level = int.tryParse(levelStr ?? "1") ?? 1;
    switch (level) {
      case 1:
        return "Đang học";
      case 2:
        return "Đã thành thạo";
      default:
        return "Đang học"; // fallback
    }
  }
}
