enum OnboardingPagePosition { page1, page2, page3 }

extension OnboardingPagePositionExtension on OnboardingPagePosition {
  /// Tro ve image cho 3 page
  String onboardingPageImage() {
    switch (this) {
      case OnboardingPagePosition.page1:
        return "assets/images/illustration-2.png";
      case OnboardingPagePosition.page2:
        return "assets/images/illustration-1.png";
      case OnboardingPagePosition.page3:
        return "assets/images/illustration.png";
    }
  }

  String onboardingPageTitle() {
    switch (this) {
      case OnboardingPagePosition.page1:
        return "Học từ vựng bằng hình ảnh";
      case OnboardingPagePosition.page2:
        return "Biến mọi thứ thành bài học";
      case OnboardingPagePosition.page3:
        return "Học tự nhiên, nhớ lâu hơn";
    }
  }

  String onboardingPageContent() {
    switch (this) {
      case OnboardingPagePosition.page1:
        return "Ghi nhớ từ vựng nhanh hơn với hình ảnh thực tế, giúp bạn học dễ dàng và hiệu quả hơn!";
      case OnboardingPagePosition.page2:
        return "Chụp ảnh, quét vật thể và khám phá từ vựng tiếng Anh ngay lập tức!";
      case OnboardingPagePosition.page3:
        return "Liên kết từ vựng với hình ảnh xung quanh, giúp bạn học như người bản xứ!";
    }
  }
}
