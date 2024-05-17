from flask import Flask, request, jsonify
import jwt
import datetime
from dotenv import load_dotenv
import os

load_dotenv()

app = Flask(__name__)

VALID_KEYS = ['your-key-1', 'your-key-2']  # Replace with your actual keys
JWT_SECRET = os.getenv('JWT_SECRET')

@app.route('/auth/login', methods=['POST'])
def login():
    data = request.get_json()
    key = data.get('key')
    if key in VALID_KEYS:
        token = jwt.encode({'key': key, 'exp': datetime.datetime.utcnow() + datetime.timedelta(hours=1)}, JWT_SECRET, algorithm='HS256')
        return jsonify({'token': token})
    return jsonify({'message': 'Invalid key'}), 401

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
