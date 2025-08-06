import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Đảm bảo import thư viện

class MiniQuizPage extends StatefulWidget {
  final List<Map<String, String>> words;

  const MiniQuizPage({Key? key, required this.words}) : super(key: key);

  @override
  _MiniQuizPageState createState() => _MiniQuizPageState();
}

class _MiniQuizPageState extends State<MiniQuizPage> {
  int currentQuestion = 0;
  int score = 0;
  bool showResult = false;
  bool answered = false;
  bool isCorrect = false;
  int timeLeft = 30;
  Timer? timer;
  TextEditingController _textController = TextEditingController();

  late List<Map<String, String>> quizWords;
  late List<String> currentOptions;
  late String correctAnswer;
  late String currentMode; // "choice" hoặc "fill"
  String? selectedAnswer;

  @override
  void initState() {
    super.initState();

    // Lọc bỏ những từ không có nghĩa hợp lệ
    final validWords =
        widget.words.where((w) {
          final meaning = w["meaning"]?.split("→").last.trim().toLowerCase();
          return meaning != null &&
              meaning.isNotEmpty &&
              meaning != "không tìm thấy nghĩa.";
        }).toList();

    // Tách từ đang học và đã học
    List<Map<String, String>> learningWords =
        validWords.where((w) => w["level"] == "1").toList();
    List<Map<String, String>> masteredWords =
        validWords.where((w) => w["level"] != "1").toList();

    // Shuffle cả 2
    learningWords.shuffle();
    masteredWords.shuffle();

    // Ưu tiên từ đang học, nếu chưa đủ thì thêm từ đã học, tổng tối đa 10 từ
    quizWords = (learningWords + masteredWords).take(10).toList();

    quizWords.shuffle();
    _startNewQuestion();
  }

  void _startNewQuestion() {
    if (currentQuestion >= quizWords.length) {
      _saveQuizHistory(); // Lưu kết quả bài kiểm tra khi hoàn tất
      setState(() => showResult = true);
      return;
    }

    setState(() {
      answered = false;
      timeLeft = 30;
      _textController.clear();
      selectedAnswer = null;

      final current = quizWords[currentQuestion];
      currentMode = Random().nextBool() ? "choice" : "fill";

      correctAnswer =
          currentMode == "choice"
              ? current["meaning"]?.split("→").last.trim() ?? ""
              : current["word"]?.trim() ?? "";

      if (currentMode == "choice") {
        final otherMeanings =
            widget.words
                .map((e) => e["meaning"]?.split("→").last.trim())
                .where((m) => m != null && m != correctAnswer)
                .toList()
              ..shuffle();

        currentOptions = [
          correctAnswer,
          ...otherMeanings.take(3).cast<String>(),
        ]..shuffle();
      }

      _startTimer();
    });
  }

  void _startTimer() {
    timer?.cancel();
    timer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() {
        timeLeft--;
        if (timeLeft <= 0) {
          _checkAnswer(null);
        }
      });
    });
  }

  void _checkAnswer(String? answer) {
    if (answered) return;

    timer?.cancel();
    isCorrect =
        (answer?.trim().toLowerCase() ?? "") ==
        correctAnswer.trim().toLowerCase();

    if (isCorrect) score++;

    setState(() {
      answered = true;
      selectedAnswer = answer;
    });
  }

  void _nextQuestion() {
    setState(() {
      currentQuestion++;
    });
    _startNewQuestion();
  }

  // Lưu lịch sử bài kiểm tra
  Future<void> _saveQuizHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateFormat(
      'yyyy-MM-dd',
    ).format(DateTime.now()); // Lấy ngày giờ hiện tại

    // Cấu trúc dữ liệu cần lưu
    Map<String, dynamic> quizHistory = {
      "score": score,
      "total_questions": quizWords.length,
      "correct_answers": score,
      "quiz_date": now,
    };

    // Lưu vào SharedPreferences (Lưu lịch sử vào thiết bị của người dùng)
    List<String> oldHistory = prefs.getStringList("quiz_history") ?? [];
    oldHistory.add(jsonEncode(quizHistory));
    await prefs.setStringList("quiz_history", oldHistory);

    // Lưu vào cơ sở dữ liệu (Backend API)
    final token = await getToken(); // Lấy token từ SharedPreferences
    final url = Uri.parse(
      "http://10.0.2.2:8000/quiz_history/save_stats",
    ); // URL API của bạn
    final response = await http.post(
      url,
      headers: {
        "Content-Type":
            "application/json", // Đảm bảo Content-Type là application/json
        "Authorization": "Bearer $token", // Gửi token xác thực người dùng
      },
      body: jsonEncode(quizHistory), // Gửi dữ liệu quiz dưới dạng JSON body
    );

    if (response.statusCode == 200) {
      print("✅ Lưu kết quả bài kiểm tra thành công!");
    } else {
      print("❌ Lỗi khi lưu kết quả: ${response.body}");
    }
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token'); // Lấy token từ SharedPreferences
  }

  @override
  void dispose() {
    timer?.cancel();
    _textController.dispose();
    super.dispose();
  }

  Color? _getOptionColor(String option) {
    if (!answered) return Colors.grey.shade800;
    if (option == correctAnswer) return Colors.green;
    if (option != correctAnswer && option == selectedAnswer) return Colors.red;
    return Colors.grey.shade800;
  }

  @override
  Widget build(BuildContext context) {
    if (showResult) {
      return Scaffold(
        backgroundColor: Color(0xFF1F1F39),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "🎉 Hoàn thành bài kiểm tra!",
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
              SizedBox(height: 20),
              Text(
                "Điểm số: $score / ${quizWords.length}",
                style: TextStyle(color: Colors.white70, fontSize: 20),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Quay lại"),
              ),
            ],
          ),
        ),
      );
    }

    final current = quizWords[currentQuestion];
    final word = current["word"] ?? "";
    final vietnameseMeaning = current["meaning"]?.split("→").last.trim() ?? "";
    final questionText = currentMode == "choice" ? word : vietnameseMeaning;

    return Scaffold(
      backgroundColor: Color(0xFF1F1F39),
      appBar: AppBar(
        backgroundColor: Color(0xFF1F1F39),
        elevation: 0,
        automaticallyImplyLeading: false, // tắt tự động
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () async {
            final shouldExit = await showDialog<bool>(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: Text("Xác nhận"),
                    content: Text(
                      "Bạn có chắc chắn muốn thoát khỏi bài kiểm tra?",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text("Ở lại"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text("Thoát"),
                      ),
                    ],
                  ),
            );

            if (shouldExit == true) {
              Navigator.pop(context);
            }
          },
        ),

        title: Text(
          "Câu ${currentQuestion + 1}/${quizWords.length}",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          Center(
            child: Container(
              margin: EdgeInsets.only(right: 16),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orangeAccent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "$timeLeft giây",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),

      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              questionText,
              style: TextStyle(
                fontSize: 26,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              currentMode == "choice"
                  ? "Chọn nghĩa đúng của từ"
                  : "Điền nghĩa tiếng Anh",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            SizedBox(height: 20),

            if (currentMode == "choice")
              ...currentOptions.map(
                (opt) => GestureDetector(
                  onTap: () => _checkAnswer(opt),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(vertical: 6),
                    padding: EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _getOptionColor(opt),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      opt,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),

            if (currentMode == "fill")
              Column(
                children: [
                  TextField(
                    controller: _textController,
                    enabled: !answered,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Nhập nghĩa tiếng Anh...",
                      hintStyle: TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.grey.shade800,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  if (!answered)
                    ElevatedButton(
                      onPressed:
                          () => _checkAnswer(_textController.text.trim()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF8687E7),
                      ),
                      child: Text("Xác nhận"),
                    ),
                ],
              ),

            SizedBox(height: 20),

            if (answered) ...[
              if (currentMode == "fill")
                Text(
                  isCorrect
                      ? "✅ Đã chính xác!"
                      : "❌ Sai rồi! Đáp án đúng: $correctAnswer",
                  style: TextStyle(
                    color: isCorrect ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    backgroundColor: Color(0xFF8687E7),
                  ),
                  child: Text(
                    "Tiếp tục",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
