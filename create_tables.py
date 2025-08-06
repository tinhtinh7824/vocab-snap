from backend.database import Base, engine
from backend.models import User

# Tạo bảng users trong cơ sở dữ liệu
Base.metadata.create_all(bind=engine)

print("✅ Created all tables successfully.")
