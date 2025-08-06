import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FlashcardPage extends StatefulWidget {
  final List<Map<String, String>> words;

  FlashcardPage({required this.words});

  @override
  State<FlashcardPage> createState() => _FlashcardPageState();
}

class _FlashcardPageState extends State<FlashcardPage> {
  int currentIndex = 0;
  int knownCount = 0;
  int learningCount = 0;

  List<Map<String, String>> filteredWords = [];
  String selectedFilter = "Tất cả";

  @override
  void initState() {
    super.initState();
    _applyFilter("Tất cả");
  }

  Future<void> _updateLevelOnServer(String word, int level) async {
    final prefs =
        await SharedPreferences.getInstance(); // lấy SharedPreferences
    final token = prefs.getString("token") ?? ""; // lấy token

    try {
      final response = await http.put(
        Uri.parse("http://10.0.2.2:8000/vocab/update_level"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token", // dùng token lấy được
        },
        body: jsonEncode({"word": word, "level": level}),
      );
      if (response.statusCode != 200) {
        print("⚠️ Không cập nhật được level cho $word");
      }
    } catch (e) {
      print("❌ Lỗi khi gọi API update_level: $e");
    }
  }

  void _onSwipe(CardSwiperDirection direction, int index) async {
    final currentWord = filteredWords[index];
    final word = currentWord['word']!;
    final newLevel = direction == CardSwiperDirection.right ? 2 : 1;

    await _updateLevelOnServer(word, newLevel);

    // Cập nhật toàn bộ từ trùng word
    for (var w in widget.words) {
      if (w['word'] == word) {
        w['level'] = newLevel.toString();
      }
    }

    // Gọi lại filter để làm mới danh sách
    _applyFilter(selectedFilter);
  }

  void _applyFilter(String filter) {
    setState(() {
      selectedFilter = filter;

      if (filter == "Tất cả") {
        filteredWords = widget.words;
      } else if (filter == "Đang học") {
        filteredWords =
            widget.words.where((word) => word["level"] != "2").toList();
      } else if (filter == "Đã thành thạo") {
        filteredWords =
            widget.words.where((word) => word["level"] == "2").toList();
      }

      currentIndex = 0;
      knownCount = filteredWords.where((w) => w["level"] == "2").length;
      learningCount = filteredWords.length - knownCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = filteredWords.length;

    return Scaffold(
      backgroundColor: Color(0xFF1F1F39),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Center(
          child: Text(
            "${currentIndex + 1} / ${total > 0 ? total : 1}",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
        actions: [SizedBox(width: 48)],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: total == 0 ? 0 : (currentIndex + 1) / total,
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
          ),
          SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCounter(learningCount, Colors.orange, "Đang học"),
                _buildCounter(knownCount, Colors.green, "Đã biết"),
              ],
            ),
          ),
          SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:
                  ["Tất cả", "Đang học", "Đã thành thạo"].map((filter) {
                    final isSelected = filter == selectedFilter;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        showCheckmark: false,
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isSelected)
                              Icon(Icons.check, size: 18, color: Colors.white),
                            if (isSelected) SizedBox(width: 4),
                            Text(filter),
                          ],
                        ),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                        selected: isSelected,
                        selectedColor: Color(0xFF4C5AFE),
                        backgroundColor: Colors.grey.shade700,
                        shape: StadiumBorder(),
                        onSelected: (_) => _applyFilter(filter),
                      ),
                    );
                  }).toList(),
            ),
          ),
          SizedBox(height: 12),
          Expanded(
            child:
                filteredWords.isEmpty
                    ? Center(
                      child: Text(
                        "Không có từ nào để học",
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    )
                    : CardSwiper(
                      cardsCount: filteredWords.length,
                      numberOfCardsDisplayed: min(3, filteredWords.length),

                      isLoop: false,
                      onSwipe: (prevIndex, currIndex, direction) {
                        if (currIndex != null) {
                          _onSwipe(direction, prevIndex);
                        }
                        return true;
                      },
                      cardBuilder: (context, index, _, __) {
                        final word = filteredWords[index]["word"]!;
                        final meaning = filteredWords[index]["meaning"]!;
                        return FlipCardWidget(
                          key: UniqueKey(),
                          front: word,
                          back: meaning,
                        );
                      },
                    ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              "⬅ Vuốt trái: Đang học    |    Vuốt phải: Đã biết ➡",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCounter(int value, Color color, String label) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "$value",
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.white70)),
      ],
    );
  }
}

class FlipCardWidget extends StatefulWidget {
  final String front;
  final String back;

  FlipCardWidget({Key? key, required this.front, required this.back})
    : super(key: key);

  @override
  _FlipCardWidgetState createState() => _FlipCardWidgetState();
}

class _FlipCardWidgetState extends State<FlipCardWidget>
    with SingleTickerProviderStateMixin {
  bool _showFrontSide = true;
  final FlutterTts flutterTts = FlutterTts();

  Future<void> _speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showFrontSide = !_showFrontSide;
        });
      },
      child: Stack(
        children: [
          AnimatedSwitcher(
            duration: Duration(milliseconds: 600),
            transitionBuilder: _transitionBuilder,
            switchInCurve: Curves.easeInOutBack,
            switchOutCurve: Curves.easeInOutBack.flipped,
            layoutBuilder:
                (widget, list) => Stack(children: [widget!, ...list]),
            child: _showFrontSide ? _buildFront() : _buildBack(),
          ),
          if (_showFrontSide)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white12,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.volume_up, color: Colors.white),
                  onPressed: () => _speak(widget.front),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCard(String text) {
    return Container(
      key: ValueKey(text),
      margin: EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Color(0xFF303060),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontFamily: "NotoSansIPA",
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildFront() => _buildCard(widget.front);
  Widget _buildBack() => _buildCard(widget.back);

  Widget _transitionBuilder(Widget child, Animation<double> animation) {
    final rotate = Tween(begin: 0.0, end: pi).animate(animation);
    return AnimatedBuilder(
      animation: rotate,
      builder: (context, widget) {
        final angle = _showFrontSide ? rotate.value : rotate.value + pi;
        final transform =
            Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle);
        return Transform(
          transform: transform,
          alignment: Alignment.center,
          child:
              angle > pi / 2 && angle < 3 * pi / 2
                  ? Transform(
                    transform: Matrix4.identity()..rotateY(pi),
                    alignment: Alignment.center,
                    child: child,
                  )
                  : child,
        );
      },
      child: child,
    );
  }
}
