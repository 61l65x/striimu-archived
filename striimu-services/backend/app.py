from flask import Flask, request, jsonify, url_for
import jwt
import datetime
from dotenv import load_dotenv
import os
from flask_cors import CORS
from flask_bcrypt import Bcrypt
from flask_mail import Mail, Message
import uuid
from itsdangerous import URLSafeTimedSerializer, SignatureExpired, BadSignature

load_dotenv()

app = Flask(__name__)
CORS(app)  # Enable CORS
bcrypt = Bcrypt(app)

# Email configuration
app.config['MAIL_SERVER'] = 'smtp.example.com'  # e.g., 'smtp.gmail.com'
app.config['MAIL_PORT'] = 587
app.config['MAIL_USE_TLS'] = True
app.config['MAIL_USERNAME'] = os.getenv('MAIL_USERNAME')
app.config['MAIL_PASSWORD'] = os.getenv('MAIL_PASSWORD')
app.config['MAIL_DEFAULT_SENDER'] = os.getenv('MAIL_DEFAULT_SENDER')

mail = Mail(app)

JWT_SECRET = os.getenv('JWT_SECRET')
SECRET_KEY = os.getenv('SECRET_KEY')

# Serializer for generating confirmation tokens
serializer = URLSafeTimedSerializer(SECRET_KEY)

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
    users[username] = {'password': hashed_password, 'key': user_key, 'status': 'pending'}

    # Send confirmation email
    token = serializer.dumps(username, salt='email-confirm')
    confirm_url = url_for('confirm_email', token=token, _external=True)
    msg = Message("Confirm Your Email",
                  recipients=[username])
    msg.body = f"Please click the link to confirm your email address: {confirm_url}"
    mail.send(msg)

    return jsonify({'message': 'User registered successfully. Please check your email to confirm registration.'}), 201

@app.route('/auth/confirm/<token>')
def confirm_email(token):
    try:
        username = serializer.loads(token, salt='email-confirm', max_age=3600)
    except (SignatureExpired, BadSignature):
        return jsonify({'message': 'The confirmation link is invalid or has expired.'}), 400

    if username in users:
        users[username]['status'] = 'pending_approval'
        # Notify admin for approval
        msg = Message("New User Pending Approval",
                      recipients=[os.getenv('ADMIN_EMAIL')])
        msg.body = f"A new user has confirmed their email and is pending approval.\n\nUsername: {username}\nKey: {users[username]['key']}\n\nPlease log in to approve this user."
        mail.send(msg)
        return jsonify({'message': 'Email confirmed. Awaiting admin approval.'}), 200

    return jsonify({'message': 'User not found'}), 404

@app.route('/auth/approve', methods=['POST'])
def approve():
    data = request.get_json()
    username = data.get('username')
    if username not in users:
        return jsonify({'message': 'User not found'}), 404
    users[username]['status'] = 'approved'
    return jsonify({'message': 'User approved successfully'}), 200

@app.route('/auth/login', methods=['POST'])
def login():
    data = request.get_json()
    username = data.get('username')
    key = data.get('key')
    if not username or not key:
        return jsonify({'message': 'Username and key are required'}), 400
    if username not in users or users[username]['key'] != key:
        return jsonify({'message': 'Invalid username or key'}), 401
    if users[username]['status'] != 'approved':
        return jsonify({'message': 'User not approved'}), 403
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
