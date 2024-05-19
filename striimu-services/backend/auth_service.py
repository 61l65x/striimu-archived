from flask import Flask, request, jsonify
import jwt
import datetime
from dotenv import load_dotenv
import os
from flask_cors import CORS
from flask_bcrypt import Bcrypt
import uuid

load_dotenv()

app = Flask(__name__)
CORS(app)  # Enable CORS
bcrypt = Bcrypt(app)

JWT_SECRET = os.getenv('JWT_SECRET')

# Simulate a user database
users = {}

@app.route('/auth/register', methods=['POST'])
def register():
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')
    if not username or not password:
        return jsonify({'message': 'Username and password are required'}), 400
    if username in users:
        return jsonify({'message': 'User already exists'}), 400
    hashed_password = bcrypt.generate_password_hash(password).decode('utf-8')
    user_key = str(uuid.uuid4())  # Generate a unique key for the user
    users[username] = {'password': hashed_password, 'key': user_key}
    return jsonify({'message': 'User registered successfully', 'key': user_key}), 201

@app.route('/auth/login', methods=['POST'])
def login():
    data = request.get_json()
    username = data.get('username')
    key = data.get('key')
    if not username or not key:
        return jsonify({'message': 'Username and key are required'}), 400
    if username not in users or users[username]['key'] != key:
        return jsonify({'message': 'Invalid username or key'}), 401
    token = jwt.encode({'username': username, 'exp': datetime.datetime.utcnow() + datetime.timedelta(hours=1)}, JWT_SECRET, algorithm='HS256')
    return jsonify({'token': token})

@app.route('/auth/validate', methods=['GET'])
def validate_token():
    token = request.headers.get('Authorization')
    if not token:
        return jsonify({'message': 'No token provided'}), 401
    try:
        jwt.decode(token, JWT_SECRET, algorithms=['HS256'])
        return jsonify({'valid': True})
    except jwt.ExpiredSignatureError:
        return jsonify({'message': 'Token has expired'}), 401
    except jwt.InvalidTokenError:
        return jsonify({'message': 'Invalid token'}), 401

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=3000)
