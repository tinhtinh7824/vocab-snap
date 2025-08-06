from backend.database import Base, engine
from backend.models import User, ReviewWord

Base.metadata.create_all(bind=engine)
print("✅ Tạo bảng thành công.")
