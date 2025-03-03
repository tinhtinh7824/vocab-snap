//Class cha: Quan ly cac page con, Di chuyen qua lai giua cac page con
import 'package:app_tieng_anh_de_an/ui/onboarding/onboarding_child_page.dart';
import 'package:app_tieng_anh_de_an/ui/welcome/welcome_page.dart';
import 'package:app_tieng_anh_de_an/ultils/enums/onboarding_page_position.dart';
import 'package:flutter/material.dart';

class OnboardingPageView extends StatefulWidget {
  const OnboardingPageView({super.key});

  @override
  State<OnboardingPageView> createState() => _OnboardingPageViewState();
}

class _OnboardingPageViewState extends State<OnboardingPageView> {
  final _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: [
          //Truyen vao cac widget con ma muon pageview hien thi
          OnboardingChildPage(
            onboardingPagePosition: OnboardingPagePosition.page1,
            nextOnPressed: () {
              _pageController.jumpToPage(1);
            },
            backOnPressed: () {
              //Nothing
            },
            skipOnPressed: () {
              _gotoWelcomePage();
            },
          ),
          OnboardingChildPage(
            onboardingPagePosition: OnboardingPagePosition.page2,
            nextOnPressed: () {
              _pageController.jumpToPage(2);
            },
            backOnPressed: () {
              _pageController.jumpToPage(0);
            },
            skipOnPressed: () {
              _gotoWelcomePage();
            },
          ),
          OnboardingChildPage(
            onboardingPagePosition: OnboardingPagePosition.page3,
            nextOnPressed: () {
              _gotoWelcomePage();
            },
            backOnPressed: () {
              _pageController.jumpToPage(1);
            },
            skipOnPressed: () {
              _gotoWelcomePage();
            },
          ),
        ],
      ),
    );
  }

  void _gotoWelcomePage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WelcomePage()),
    );
  }
}
