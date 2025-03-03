enum OnboardingPagePosition { page1, page2, page3 }

extension OnboardingPagePositionExtension on OnboardingPagePosition {
  /// Tro ve image cho 3 page
  String onboardingPageImage() {
    switch (this) {
      case OnboardingPagePosition.page1:
        return "assets/images/Frame161.png";
      case OnboardingPagePosition.page2:
        return "assets/images/Frame162.png";
      case OnboardingPagePosition.page3:
        return "assets/images/Group182.png";
    }
  }

  String onboardingPageTitle() {
    switch (this) {
      case OnboardingPagePosition.page1:
        return "Ho";
      case OnboardingPagePosition.page2:
        return "Hi";
      case OnboardingPagePosition.page3:
        return "Hohi";
    }
  }

  String onboardingPageContent() {
    switch (this) {
      case OnboardingPagePosition.page1:
        return "Ho";
      case OnboardingPagePosition.page2:
        return "Hi";
      case OnboardingPagePosition.page3:
        return "Hohi";
    }
  }
}
