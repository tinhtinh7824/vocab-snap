import 'dart:async';
import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'review_page.dart';

class StatisticsPage extends StatefulWidget {
  final String? avatarUrl;
  const StatisticsPage({Key? key, this.avatarUrl}) : super(key: key);

  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  int _targetWords = 30;
  int _daysAchievedGoal = 0;
  Map<String, int> _wordsPerDay = {};
  int _learningCount = 0;
  int _masteredCount = 0;

  @override
  void initState() {
    super.initState();
    _loadTargetWords();
    _calculateStatistics();
  }

  Future<void> _loadTargetWords() async {
    final prefs = await SharedPreferences.getInstance();
    _targetWords = prefs.getInt('targetWords') ?? 30;
    setState(() {});
  }

  Future<void> _updateTargetWords(int newTarget) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('targetWords', newTarget);
    setState(() {
      _targetWords = newTarget;
    });
    _calculateStatistics();
  }

  Future<List<Map<String, dynamic>>> _loadQuizStats() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url = Uri.parse(
      "http://10.0.2.2:8000/quiz_history/quiz_history",
    ); // URL của API GET

    final response = await http.get(
      url,
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      List<dynamic> quizHistory = jsonDecode(response.body);
      return quizHistory.map((e) => e as Map<String, dynamic>).toList();
    } else {
      print("❌ Lỗi khi lấy dữ liệu: ${response.body}");
      return [];
    }
  }

  void _calculateStatistics() {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month;
    final daysInMonth = DateTime(year, month + 1, 0).day;

    Map<String, int> countPerDay = {};
    for (int day = 1; day <= daysInMonth; day++) {
      final dateKey =
          "$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}";
      countPerDay[dateKey] = 0;
    }

    _learningCount = 0;
    _masteredCount = 0;

    for (var word in reviewWords) {
      final date = DateTime.tryParse(word["date"] ?? "") ?? DateTime(2000);
      final key =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      if (key.startsWith("$year-${month.toString().padLeft(2, '0')}")) {
        countPerDay[key] = (countPerDay[key] ?? 0) + 1;
      }

      if (word["level"] == "2") {
        _masteredCount += 1;
      } else {
        _learningCount += 1;
      }
    }

    final achievedDays =
        countPerDay.values.where((v) => v >= _targetWords).length;

    setState(() {
      _wordsPerDay = countPerDay;
      _daysAchievedGoal = achievedDays;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Color(0xFF1F1F39),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            "Thống kê quá trình học",
            style: TextStyle(color: Colors.white),
          ),
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            tabs: [Tab(text: "Từ vựng"), Tab(text: "Học tập")],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: CircleAvatar(
                backgroundImage:
                    (widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty)
                        ? NetworkImage(widget.avatarUrl!)
                        : AssetImage("assets/images/illustration-2.png")
                            as ImageProvider,
              ),
            ),
          ],
        ),
        body: TabBarView(
          children: [_buildVocabularyStats(), _buildLearningStats()],
        ),
      ),
    );
  }

  Widget _buildVocabularyStats() {
    final sortedDates = _wordsPerDay.keys.toList()..sort();

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SizedBox(height: 10),
          _buildTargetRow(),

          Text("Số từ vựng đã nhận diện tháng này", style: _titleStyle()),
          SizedBox(height: 20),
          _buildLineChart(sortedDates),

          SizedBox(height: 24),
          Text("Lịch sử từ vựng đã nhận diện mỗi ngày", style: _titleStyle()),
          SizedBox(height: 8),
          ..._buildHistoryList(sortedDates),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    return SizedBox(
      height: 180,
      child: PieChart(
        PieChartData(
          centerSpaceRadius: 32,
          sections: [
            PieChartSectionData(
              value: _learningCount.toDouble(),
              title: "Đang học\n$_learningCount",
              color: Colors.orange,
              radius: 50,
              titleStyle: TextStyle(color: Colors.white),
            ),
            PieChartSectionData(
              value: _masteredCount.toDouble(),
              title: "Đã thành thạo\n$_masteredCount",
              color: Colors.green,
              radius: 50,
              titleStyle: TextStyle(color: Colors.white),
            ),
          ],
          sectionsSpace: 4,
        ),
      ),
    );
  }

  Widget _buildTargetRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Mục tiêu mỗi ngày:", style: TextStyle(color: Colors.white)),
        Row(
          children: [
            IconButton(
              onPressed: () {
                if (_targetWords > 5) _updateTargetWords(_targetWords - 5);
              },
              icon: Icon(Icons.remove, color: Colors.white),
            ),
            Text("$_targetWords từ", style: TextStyle(color: Colors.white)),
            IconButton(
              onPressed: () => _updateTargetWords(_targetWords + 5),
              icon: Icon(Icons.add, color: Colors.white),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLineChart(List<String> sortedDates) {
    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          backgroundColor: Colors.transparent,
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 3,
                getTitlesWidget: (value, _) {
                  final index = value.toInt();
                  if (index < 0 || index >= sortedDates.length)
                    return SizedBox();
                  return Text(
                    sortedDates[index].split("-")[2],
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 5,
                getTitlesWidget:
                    (value, _) => Text(
                      "${value.toInt()}",
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: true),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.white24),
          ),
          lineBarsData: [
            LineChartBarData(
              isCurved: true,
              color: Colors.blueAccent,
              barWidth: 3,
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blueAccent.withOpacity(0.3),
              ),
              spots: List.generate(
                sortedDates.length,
                (i) => FlSpot(
                  i.toDouble(),
                  _wordsPerDay[sortedDates[i]]!.toDouble(),
                ),
              ),
            ),
            LineChartBarData(
              isCurved: false,
              color: Colors.greenAccent,
              barWidth: 2,
              dashArray: [6, 4],
              spots: List.generate(
                sortedDates.length,
                (i) => FlSpot(i.toDouble(), _targetWords.toDouble()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildHistoryList(List<String> dates) {
    return dates.where((d) => _wordsPerDay[d]! > 0).toList().reversed.map((
      date,
    ) {
      final count = _wordsPerDay[date]!;
      final formatted =
          "${date.split("-")[2]}/${date.split("-")[1]}/${date.split("-")[0]}";
      return Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Color(0xFFD3E5FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Ngày $formatted",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            LinearProgressIndicator(
              value: count / _targetWords,
              backgroundColor: Colors.white,
              valueColor: AlwaysStoppedAnimation(
                count >= _targetWords ? Colors.green : Colors.blue,
              ),
            ),
            SizedBox(height: 4),
            Text(
              "$count / $_targetWords từ",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }).toList();
  }

  TextStyle _titleStyle() {
    return TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.bold,
    );
  }

  Widget _buildLearningStats() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 12),
          Text(
            "Biểu đồ tổng hợp",
            style: _titleStyle(),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12),
          _buildPieChart(),
          SizedBox(height: 12),
          Text(
            "Thống kê học tập",
            style: _titleStyle(),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          _buildQuizStats(),
        ],
      ),
    );
  }

  Widget _buildQuizStats() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _loadQuizStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text("Lỗi khi tải dữ liệu.");
        }

        if (snapshot.hasData) {
          List<Map<String, dynamic>> quizStats = snapshot.data!;

          // Tính tổng số điểm, số bài làm và tỷ lệ đúng/sai
          int totalScore = 0;
          int totalQuestions = 0;
          int totalCorrectAnswers = 0;

          for (var stat in quizStats) {
            totalScore += (stat['score'] ?? 0) as int;
            totalQuestions += (stat['total_questions'] ?? 0) as int;
            totalCorrectAnswers += (stat['correct_answers'] ?? 0) as int;
          }

          double averageScore = totalScore / quizStats.length;
          double accuracy = (totalCorrectAnswers / totalQuestions) * 100;

          return Column(
            children: [
              Text(
                "            Số bài kiểm tra đã làm: ${quizStats.length}",
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 8),
              Text(
                "               Điểm trung bình: ${averageScore.toStringAsFixed(2)} / 10",
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 8),
              Text(
                "Tỷ lệ đúng: ${accuracy.toStringAsFixed(2)}%",
                style: TextStyle(color: Colors.white),
              ),
            ],
          );
        }

        return Text("Chưa có thống kê.");
      },
    );
  }
}
