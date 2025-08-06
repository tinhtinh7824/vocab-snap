import os
import cv2
import numpy as np
from fastapi import APIRouter, UploadFile, File
from fastapi.responses import FileResponse
from ultralytics import YOLO

router = APIRouter()

STATIC_DIR = "static"
os.makedirs(STATIC_DIR, exist_ok=True)

@router.post("/predict")
async def predict(file: UploadFile = File(...)):
    contents = await file.read()
    np_img = np.frombuffer(contents, np.uint8)
    image = cv2.imdecode(np_img, cv2.IMREAD_COLOR)
    image = cv2.GaussianBlur(image, (3, 3), 0)

    model = YOLO("jameslahm/yolov10m")
    results = model.predict(source=image, imgsz=640, conf=0.2)

    detections = []
    for result in results:
        for box in result.boxes:
            detections.append({
                "class": result.names[int(box.cls)],
                "confidence": float(box.conf)
            })

    detected_image_filename = "detected_image.jpg"
    detected_image_path = os.path.join(STATIC_DIR, detected_image_filename)
    processed_image = results[0].plot()
    cv2.imwrite(detected_image_path, processed_image, [cv2.IMWRITE_JPEG_QUALITY, 95])

    return {
        "detections": detections,
        "processed_image_url": f"http://10.0.2.2:8000/static/{detected_image_filename}"
    }

@router.get("/static/detected_image.jpg")
async def get_detected_image():
    path = os.path.join(STATIC_DIR, "detected_image.jpg")
    if os.path.exists(path):
        return FileResponse(path)
    return {"error": "File not found"}
