from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from backend.database import get_db
from backend.models import ReviewWord, User
from backend.utils import get_current_user
from pydantic import BaseModel
from typing import List
from fastapi import Body
from datetime import datetime

router = APIRouter()

class WordItem(BaseModel):
    word: str
    meaning: str
    example: str
    date: str
    level: int = 1  # Mặc định là 1 = đang học

# Model trả về cho Flutter
class ReviewWordOut(BaseModel):
    word: str
    meaning: str
    example: str
    date: str
    level: int

    class Config:
        orm_mode = True

@router.get("/review_words", response_model=List[ReviewWordOut])
def get_review_words(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    words = db.query(ReviewWord).filter(ReviewWord.user_id == current_user.id).all()
    return words

@router.post("/save_words")
def save_words(
        words: List[WordItem],
        db: Session = Depends(get_db),
        current_user: User = Depends(get_current_user)
):
    saved = 0
    for item in words:
        if "Không tìm thấy nghĩa" in item.meaning:
            continue

        existing = db.query(ReviewWord).filter_by(
            user_id=current_user.id,
            word=item.word
        ).first()
        if existing:
            db.delete(existing)

        review = ReviewWord(
            word=item.word,
            meaning=item.meaning,
            example=item.example,
            date=item.date,
            user_id=current_user.id,
            level=item.level if item.level in [1, 2] else 1
        )
        db.add(review)
        saved += 1

    db.commit()
    return {"message": f"Đã lưu {saved} từ vựng!"}


@router.put("/update_level")
def update_level(
        word: str = Body(...),
        level: int = Body(...),
        db: Session = Depends(get_db),
        current_user: User = Depends(get_current_user)
):
    review_word = db.query(ReviewWord).filter_by(user_id=current_user.id, word=word).first()
    if not review_word:
        raise HTTPException(status_code=404, detail="Từ không tồn tại")

    review_word.level = level
    db.commit()
    return {"message": f"Đã cập nhật trạng thái từ '{word}' thành công"}