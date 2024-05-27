from flask import Flask, request, jsonify
import jwt
import datetime
from dotenv import load_dotenv
import os
from flask_cors import CORS
from flask_bcrypt import Bcrypt
import uuid
from flask_sqlalchemy import SQLAlchemy
from captcha.image import ImageCaptcha
import base64
from io import BytesIO

load_dotenv()

app = Flask(__name__)
CORS(app)
bcrypt = Bcrypt(app)

app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///users.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)

JWT_SECRET = os.getenv('JWT_SECRET')
ADMIN_TOKEN = os.getenv('ADMIN_TOKEN')

class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    password = db.Column(db.String(200), nullable=False)
    user_key = db.Column(db.String(36), unique=True, nullable=False)

def generate_captcha():
    image = ImageCaptcha()
    captcha_text = str(uuid.uuid4())[:6]
    data = image.generate(captcha_text)
    image_data = base64.b64encode(data.getvalue()).decode('utf-8')
    return captcha_text, image_data

@app.route('/auth/captcha', methods=['GET'])
def get_captcha():
    captcha_text, image_data = generate_captcha()
    return jsonify({'captcha_text': captcha_text, 'captcha_image': image_data})

@app.route('/auth/register', methods=['POST'])
def register():
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')
    captcha_text = data.get('captcha_text')
    captcha_input = data.get('captcha_input')

    if not username or not password:
        return jsonify({'message': 'Username and password are required'}), 400
    if captcha_input != captcha_text:
        return jsonify({'message': 'Invalid CAPTCHA'}), 400
    if User.query.filter_by(username=username).first():
        return jsonify({'message': 'User already exists'}), 400
    
    hashed_password = bcrypt.generate_password_hash(password).decode('utf-8')
    user_key = str(uuid.uuid4())
    new_user = User(username=username, password=hashed_password, user_key=user_key)
    db.session.add(new_user)
    db.session.commit()
    
    # Generate token
    token = jwt.encode({'username': username, 'exp': datetime.datetime.utcnow() + datetime.timedelta(hours=1)}, JWT_SECRET, algorithm='HS256')
    
    return jsonify({'message': 'User registered successfully', 'key': user_key, 'token': token}), 201

@app.route('/auth/login', methods=['POST'])
def login():
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')
    captcha_text = data.get('captcha_text')
    captcha_input = data.get('captcha_input')

    if not username or not password:
        return jsonify({'message': 'Username and password are required'}), 400
    if captcha_input != captcha_text:
        return jsonify({'message': 'Invalid CAPTCHA'}), 400
    
    user = User.query.filter_by(username=username).first()
    if not user or not bcrypt.check_password_hash(user.password, password):
        return jsonify({'message': 'Invalid username or password'}), 401
    
    token = jwt.encode({'username': username, 'exp': datetime.datetime.utcnow() + datetime.timedelta(hours=1)}, JWT_SECRET, algorithm='HS256')
    return jsonify({'token': token})

@app.route('/auth/validate', methods=['GET'])
def validate_token():
    auth_header = request.headers.get('Authorization')
    if not auth_header:
        return jsonify({'message': 'No token provided'}), 401

    if auth_header.startswith('Bearer '):
        token = auth_header[7:]
    else:
        return jsonify({'message': 'Invalid token format'}), 401

    try:
        jwt.decode(token, JWT_SECRET, algorithms=['HS256'])
        return jsonify({'valid': True})
    except jwt.ExpiredSignatureError:
        return jsonify({'message': 'Token has expired'}), 401
    except jwt.InvalidTokenError:
        return jsonify({'message': 'Invalid token'}), 401

@app.route('/admin/clean', methods=['POST'])
def clean_db():
    token = request.headers.get('Authorization')
    if not token:
        return jsonify({'message': 'No token provided'}), 401

    # Extract token from "Bearer <token>"
    if token.startswith('Bearer '):
        token = token[7:]

    if token != ADMIN_TOKEN:
        return jsonify({'message': 'Unauthorized'}), 401

    db.drop_all()
    db.create_all()
    return jsonify({'message': 'Database cleaned successfully'}), 200

if __name__ == '__main__':
    with app.app_context():
        db.create_all()
    app.run(host='0.0.0.0', port=3000)
