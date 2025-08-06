from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from backend.models import ReviewWord
from backend.database import get_db
from .auth import get_current_user  # Hàm xác thực JWT
from .schemas import ReviewWordCreate

router = APIRouter()

@router.post("/review_words")
def save_review_word(
        word_data: ReviewWordCreate,
        db: Session = Depends(get_db),
        current_user = Depends(get_current_user)
):
    new_word = ReviewWord(
        word=word_data.word,
        meaning=word_data.meaning,
        example=word_data.example,
        date=word_data.date,
        user_id=current_user.id
    )
    db.add(new_word)
    db.commit()
    return {"message": "Lưu từ vựng thành công!"}
