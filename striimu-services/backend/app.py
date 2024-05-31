from flask import Flask, request, jsonify, make_response
from flask_wtf.csrf import CSRFProtect
import jwt
import datetime
from dotenv import load_dotenv
import os
from flask_cors import CORS
from flask_bcrypt import Bcrypt
import uuid
from peewee import *
from password_validator import PasswordValidator

load_dotenv()

app = Flask(__name__)
CORS(app)
csrf = CSRFProtect(app)
bcrypt = Bcrypt(app)

# Ensure the database is in the current directory
db = SqliteDatabase('users.db')

JWT_SECRET = os.getenv('JWT_SECRET')
ADMIN_TOKEN = os.getenv('ADMIN_TOKEN')
SECRET_KEY = os.getenv('SECRET_KEY')

# Set the secret key for Flask
app.config['SECRET_KEY'] = SECRET_KEY
app.config['SESSION_COOKIE_SECURE'] = True
app.config['SESSION_COOKIE_HTTPONLY'] = True
app.config['SESSION_COOKIE_SAMESITE'] = 'Lax'

class BaseModel(Model):
    class Meta:
        database = db

class User(BaseModel):
    username = CharField(unique=True)
    password = CharField()
    user_key = CharField(unique=True)

class EarlyAccessToken(BaseModel):
    token = CharField(unique=True)
    used = BooleanField(default=False)

db.connect()
db.create_tables([User, EarlyAccessToken])

# Define a password schema
password_schema = PasswordValidator()

# Add properties to the schema
password_schema \
    .min(8) \
    .max(100) \
    .has().uppercase() \
    .has().lowercase() \
    .has().digits() \
    .has().no().spaces() \
    .has().symbols()

@app.route('/auth/register', methods=['POST'])
@csrf.exempt  # Exempt the CSRF check for API endpoints for now
def register():
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')
    access_token = data.get('access_token')

    if not username or not password or not access_token:
        return jsonify({'message': 'Username, password, and access token are required'}), 400
    if User.select().where(User.username == username).exists():
        return jsonify({'message': 'User already exists'}), 400

    # Check if the access token is valid and not used
    token_record = EarlyAccessToken.get_or_none(EarlyAccessToken.token == access_token, EarlyAccessToken.used == False)
    if not token_record:
        return jsonify({'message': 'Invalid or used access token'}), 400

    # Enforce strong password policy
    if not password_schema.validate(password):
        return jsonify({'message': 'Password does not meet the security requirements'}), 400

    hashed_password = bcrypt.generate_password_hash(password).decode('utf-8')
    user_key = str(uuid.uuid4())
    new_user = User.create(username=username, password=hashed_password, user_key=user_key)

    # Mark the access token as used
    token_record.used = True
    token_record.save()

    # Generate token
    token = jwt.encode({'username': username, 'exp': datetime.datetime.utcnow() + datetime.timedelta(hours=1)}, JWT_SECRET, algorithm='HS256')

    response = make_response(jsonify({'message': 'User registered successfully', 'key': user_key, 'token': token}))
    response.set_cookie('token', token, httponly=True, secure=True)  # Ensure Secure flag is used in production

    return response, 201

@app.route('/auth/login', methods=['POST'])
@csrf.exempt
def login():
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')

    if not username or not password:
        return jsonify({'message': 'Username and password are required'}), 400

    user = User.get_or_none(User.username == username)
    if not user or not bcrypt.check_password_hash(user.password, password):
        return jsonify({'message': 'Invalid username or password'}), 401

    token = jwt.encode({'username': username, 'exp': datetime.datetime.utcnow() + datetime.timedelta(hours=1)}, JWT_SECRET, algorithm='HS256')

    response = make_response(jsonify({'message': 'Login successful'}))
    response.set_cookie('token', token, httponly=True, secure=True)  # Ensure Secure flag is used in production

    return response

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
@csrf.exempt
def clean_db():
    token = request.headers.get('Authorization')
    if not token:
        return jsonify({'message': 'No token provided'}), 401

    # Extract token from "Bearer <token>"
    if token.startswith('Bearer '):
        token = token[7:]

    if token != ADMIN_TOKEN:
        return jsonify({'message': 'Unauthorized'}), 401

    db.drop_tables([User, EarlyAccessToken])
    db.create_tables([User, EarlyAccessToken])
    return jsonify({'message': 'Database cleaned successfully'}), 200

@app.route('/admin/generate-token', methods=['POST'])
@csrf.exempt
def generate_invitation_token():
    token = request.headers.get('Authorization')
    if not token or token != f"Bearer {ADMIN_TOKEN}":
        return jsonify({'message': 'Unauthorized'}), 401

    invite_token = str(uuid.uuid4())
    new_token = EarlyAccessToken.create(token=invite_token)

    return jsonify({'invite_token': invite_token})

if __name__ == '__main__':
    import os
    print(f"Current working directory: {os.getcwd()}")
    print(f"Database path: users.db")
    
    app.run(host='0.0.0.0', port=3000)
