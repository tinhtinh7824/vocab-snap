from flask import Flask, request, jsonify
import firebase_admin
from firebase_admin import credentials, firestore


##uvicorn backend.main:app --reload

app = Flask(__name__)

cred = credentials.Certificate("/Users/admin/Desktop/flutter2004-2025-firebase-adminsdk-fbsvc-62b99de9b1.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

@app.route('/', methods=['GET', 'POST'])
def home():
    if request.method == 'POST':
        data = request.get_json()
        name = data['name']
        age = data['age']

        doc_ref = db.collection('users').document()
        doc_ref.set({'name': name, 'age': age})
        return jsonify({'message': 'User added successfully!'})
    else:
        users = []
        docs = db.collection('users').stream()
        for doc in docs:
            users.append(doc.to_dict())
        return jsonify(users)

if __name__ == '__main__':
    app.run(debug=True)


