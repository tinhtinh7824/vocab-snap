from sqlalchemy import Column, Integer, String, ForeignKey, Date
from sqlalchemy.orm import relationship
from backend.database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    avatar_url = Column(String, nullable=True)

    review_words = relationship("ReviewWord", back_populates="user")
    quiz_histories = relationship("QuizHistory", back_populates="user")

class ReviewWord(Base):
    __tablename__ = "review_words"

    id = Column(Integer, primary_key=True)
    word = Column(String, nullable=False)
    meaning = Column(String, nullable=False)
    example = Column(String, nullable=True)
    date = Column(String, nullable=False)  # YYYY-MM-DD
    user_id = Column(Integer, ForeignKey("users.id"))
    level = Column(Integer, default=1)  # 1: đang học, 2: thành thạo

    user = relationship("User", back_populates="review_words")

class QuizHistory(Base):
    __tablename__ = 'quiz_history'

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id'))
    score = Column(Integer)  # Điểm người dùng đạt được
    total_questions = Column(Integer)  # Số câu hỏi trong bài kiểm tra
    correct_answers = Column(Integer)  # Số câu trả lời đúng
    quiz_date = Column(String)  # Ngày làm bài kiểm tra (format: YYYY-MM-DD)

    user = relationship("User", back_populates="quiz_histories")
