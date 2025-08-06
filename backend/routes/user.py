from fastapi import APIRouter, UploadFile, File, Depends, HTTPException
from sqlalchemy.orm import Session
from backend.database import get_db
from backend.models import User
from backend.utils import get_current_user
from passlib.context import CryptContext
from pydantic import BaseModel
import shutil, os
from fastapi.responses import JSONResponse

router = APIRouter()

# 📤 API: Upload avatar
@router.post("/user/upload_avatar")
def upload_avatar(
        file: UploadFile = File(...),
        db: Session = Depends(get_db),
        current_user: User = Depends(get_current_user)
):
    os.makedirs("static/avatar", exist_ok=True)

    file_location = f"static/avatar/{current_user.id}_{file.filename}"
    with open(file_location, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    current_user.avatar_url = f"http://10.0.2.2:8000/{file_location}"
    db.commit()

    return JSONResponse(content={"avatar_url": current_user.avatar_url})


# 🧑‍💻 API: Lấy thông tin người dùng hiện tại
@router.get("/user/profile")
def get_user_profile(current_user: User = Depends(get_current_user)):
    return {
        "username": current_user.username,
        "avatar_url": current_user.avatar_url,
    }


pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

class ChangePasswordRequest(BaseModel):
    old_password: str
    new_password: str

@router.post("/user/change_password")
def change_password(
        req: ChangePasswordRequest,
        db: Session = Depends(get_db),
        current_user: User = Depends(get_current_user)
):
    if not pwd_context.verify(req.old_password, current_user.hashed_password):
        raise HTTPException(status_code=400, detail="Mật khẩu cũ không đúng")

    current_user.hashed_password = pwd_context.hash(req.new_password)
    db.commit()
    return {"message": "Đổi mật khẩu thành công"}