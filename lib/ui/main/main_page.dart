import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<Widget> _pages = [];
  int _currentPage = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _pages = [
      Container(color: Colors.red),
      Container(color: Colors.yellow),
      Container(color: Colors.green),
      Container(color: Colors.blue),
      Container(color: Colors.white),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: _pages.elementAt(_currentPage),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF363636),
        unselectedItemColor: Colors.white,
        selectedItemColor: const Color(0xFF8687E7),
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentPage,
        onTap: (index) {
          if (index == 2) {
            return;
          }
          setState(() {
            _currentPage = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              "assets/images/home-2.png",
              width: 24,
              height: 24,
              fit: BoxFit.fill,
            ),
            activeIcon: Image.asset(
              "assets/images/home-2.png",
              width: 24,
              height: 24,
              fit: BoxFit.fill,
              color: const Color(0xFF8687E7),
            ),
            label: "Index",
            backgroundColor: Colors.transparent,
          ),

          BottomNavigationBarItem(
            icon: Image.asset(
              "assets/images/calendar.png",
              width: 24,
              height: 24,
              fit: BoxFit.fill,
            ),
            activeIcon: Image.asset(
              "assets/images/calendar.png",
              width: 24,
              height: 24,
              fit: BoxFit.fill,
              color: const Color(0xFF8687E7),
            ),
            label: "Calendar",
            backgroundColor: Colors.transparent,
          ),

          BottomNavigationBarItem(
            icon: Container(),
            label: "",
            backgroundColor: Colors.transparent,
          ),

          BottomNavigationBarItem(
            icon: Image.asset(
              "assets/images/clock.png",
              width: 24,
              height: 24,
              fit: BoxFit.fill,
            ),
            activeIcon: Image.asset(
              "assets/images/clock.png",
              width: 24,
              height: 24,
              fit: BoxFit.fill,
              color: const Color(0xFF8687E7),
            ),
            label: "Focuse",
            backgroundColor: Colors.transparent,
          ),

          BottomNavigationBarItem(
            icon: Image.asset(
              "assets/images/user.png",
              width: 24,
              height: 24,
              fit: BoxFit.fill,
            ),
            activeIcon: Image.asset(
              "assets/images/user.png",
              width: 24,
              height: 24,
              fit: BoxFit.fill,
              color: const Color(0xFF8687E7),
            ),
            label: "Profile",
            backgroundColor: Colors.transparent,
          ),
        ],
      ),
      floatingActionButton: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Color(0xFF8687E7),
          borderRadius: BorderRadius.circular(32),
        ),
        child: IconButton(
          onPressed: () {},
          icon: Icon(Icons.add, size: 30, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
