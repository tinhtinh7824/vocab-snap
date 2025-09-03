from fastapi import FastAPI
from backend.routes import auth, vocab, user, quiz_history, yolo_api
from fastapi.staticfiles import StaticFiles

#  uvicorn backend.main:app --reload
app = FastAPI()

#  Thêm API đăng nhập / đăng ký
app.include_router(auth.router, prefix="/auth", tags=["auth"])

#  Thêm API lưu từ vựng
app.include_router(vocab.router, prefix="/vocab", tags=["vocab"])

#  Thêm API lịch sử bài kiểm tra
app.include_router(quiz_history.router, prefix="/quiz_history", tags=["quiz_history"])

app.include_router(user.router)

app.mount("/static", StaticFiles(directory="static"), name="static")

app.include_router(user.router, tags=["user"])

app.include_router(yolo_api.router, prefix="/yolo", tags=["yolo"])

@app.get("/")
def home():
    return {"message": "API Đăng nhập & Đăng ký chạy thành công!"}
