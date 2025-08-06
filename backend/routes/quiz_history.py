from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.orm import Session
from backend.database import get_db
from backend.models import QuizHistory, User
from datetime import datetime
from backend.utils import get_current_user
from pydantic import BaseModel
from typing import List

router = APIRouter()

class QuizStats(BaseModel):
    score: int
    total_questions: int
    correct_answers: int
    quiz_date: str

@router.get("/quiz_history")
async def get_quiz_history(
        db: Session = Depends(get_db),
        current_user: User = Depends(get_current_user)
):
    # Lấy lịch sử bài kiểm tra từ database
    history = db.query(QuizHistory).filter(QuizHistory.user_id == current_user.id).all()
    return history


@router.post("/save_stats")
async def save_quiz_stats(
        quiz_stats: QuizStats,
        db: Session = Depends(get_db),
        current_user: User = Depends(get_current_user)
):
    # Lưu kết quả vào cơ sở dữ liệu
    quiz_history = QuizHistory(
        user_id=current_user.id,
        score=quiz_stats.score,
        total_questions=quiz_stats.total_questions,
        correct_answers=quiz_stats.correct_answers,
        quiz_date=quiz_stats.quiz_date
    )
    db.add(quiz_history)
    db.commit()

    return {"message": "Lưu kết quả bài kiểm tra thành công!"}
