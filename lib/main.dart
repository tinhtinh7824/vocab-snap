import 'package:app_tieng_anh_de_an/ui/onboarding/onboarding_page_view.dart';
//import 'package:app_tieng_anh_de_an/ui/onboarding/onboarding_page_view.dart';
//import 'package:app_tieng_anh_de_an/ui/splash/splash.dart';
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
      title: 'Todo List Demo Course',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: "Lato",
      ),
      home: const OnboardingPageView(),
    );
  }
}
