from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.orm import Session
from passlib.context import CryptContext
from jose import JWTError, jwt
from datetime import datetime, timedelta
from backend.database import get_db
from backend.models import User
from pydantic import BaseModel
import os

# Router FastAPI
router = APIRouter()

# Cấu hình mã hóa mật khẩu
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# Secret key và thuật toán mã hóa JWT
SECRET_KEY = "supersecretkey"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

# Schema cho người dùng
class UserCreate(BaseModel):
    username: str
    password: str

class UserLogin(BaseModel):
    username: str
    password: str

class TokenData(BaseModel):
    access_token: str
    token_type: str

class ReviewWordCreate(BaseModel):
    word: str
    meaning: str
    date: str

# Hàm mã hóa mật khẩu
def hash_password(password: str):
    return pwd_context.hash(password)

# Hàm kiểm tra mật khẩu
def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)

# Hàm tạo JWT Token
def create_access_token(data: dict, expires_delta: timedelta | None = None):
    to_encode = data.copy()
    expire = datetime.utcnow() + (expires_delta or timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES))
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

# 📝 **API: Đăng ký tài khoản**
@router.post("/register", response_model=TokenData, status_code=201)
def register(user: UserCreate, db: Session = Depends(get_db)):
    print("🟢 Đăng ký với username:", user.username)  # ← thêm dòng này

    existing_user = db.query(User).filter(User.username == user.username).first()
    if existing_user:
        print("🔴 Người dùng đã tồn tại:", existing_user.username)  # ← thêm log
        raise HTTPException(status_code=400, detail="Tên người dùng đã tồn tại")


    hashed_password = hash_password(user.password)
    new_user = User(username=user.username, hashed_password=hashed_password)
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    print("✅ Người dùng đã được lưu:", new_user.username)


    access_token = create_access_token(data={"sub": new_user.username})
    return {"access_token": access_token, "token_type": "bearer"}

# 🔐 **API: Đăng nhập**
@router.post("/login", response_model=TokenData)
def login(user: UserLogin, db: Session = Depends(get_db)):
    db_user = db.query(User).filter(User.username == user.username).first()
    if not db_user or not verify_password(user.password, db_user.hashed_password):
        raise HTTPException(status_code=400, detail="Sai tài khoản hoặc mật khẩu")

    access_token = create_access_token(data={"sub": db_user.username})
    return {"access_token": access_token, "token_type": "bearer"}
