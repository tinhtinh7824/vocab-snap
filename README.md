# 📸 VocabSnap – Học từ vựng tiếng Anh qua hình ảnh thực tế

**VocabSnap** là ứng dụng học từ vựng tiếng Anh tích hợp công nghệ AI, giúp người học chụp ảnh các vật thể xung quanh và nhận diện từ vựng tiếng Anh tương ứng. Ứng dụng mang đến trải nghiệm học tập trực quan, sinh động và cá nhân hóa, phù hợp với mọi đối tượng học tiếng Anh trong thời đại số.

---

## 🎯 Mục tiêu

- Học từ vựng tiếng Anh bằng cách **chụp ảnh vật thể thực tế**
- **Nhận diện hình ảnh bằng YOLOv10**, liên kết từ vựng qua API từ điển
- **Lưu trữ, ôn tập và kiểm tra** từ vựng theo tiến độ cá nhân
- Theo dõi tiến trình học bằng **Flashcard, Mini Quiz và biểu đồ thống kê**

---

## 🧠 Các tính năng nổi bật

- 📷 Nhận diện vật thể qua ảnh chụp, trả về từ vựng tiếng Anh tương ứng
- 🔤 Hiển thị phiên âm IPA, nghĩa tiếng Việt, phát âm và ví dụ
- 📚 Hệ thống **Flashcard** luyện tập ghi nhớ
- 🧪 **Mini Quiz** kiểm tra mức độ ghi nhớ
- 📈 Theo dõi tiến độ học tập theo ngày/tuần/tháng
- ⏱️ Tích hợp **Pomodoro** để học hiệu quả hơn
- 🔐 Quản lý tài khoản và dữ liệu học bằng Firebase

---

## 🛠️ Công nghệ sử dụng

| Thành phần      | Công nghệ                    |
|-----------------|-----------------------------|
| Frontend        | Flutter + Dart              |
| Backend         | Python (FastAPI)            |
| Nhận diện ảnh   | YOLOv10 (ultralytics)       |
| Cơ sở dữ liệu   | SQLite / Firebase           |
| API từ điển     | dictionaryapi.dev, Google Translate |

---

## 📲 Đối tượng sử dụng

- Học sinh, sinh viên luyện thi TOEIC, IELTS...
- Người đi làm cần mở rộng vốn từ chuyên ngành
- Người tự học tiếng Anh tại nhà
- Người học yêu thích phương pháp học **trực quan – sinh động – gắn liền thực tế**

---

## 📂 Cấu trúc dự án

```bash
vocab-snap/
├── backend/             # YOLOv10 + API nhận diện
├── frontend/            # Flutter mobile app
├── assets/              # Icon, ảnh minh họa
├── database/            # SQLite / Firebase rules
├── README.md
└── ...
