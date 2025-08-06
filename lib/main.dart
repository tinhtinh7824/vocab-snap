import 'package:app_tieng_anh_de_an/ui/login/login_page.dart';
import 'package:app_tieng_anh_de_an/ui/welcome/welcome_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Học từ vựng',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(
              seedColor:
                  Colors.deepPurple,
            ),
        useMaterial3: true,
        fontFamily: "Lato",
      ),
      initialRoute: '/welcome',
      routes: {
        '/welcome':
            (context) =>
                const WelcomePage(),
        '/login':
            (context) => LoginPage(),
      },
    );
  }
}
