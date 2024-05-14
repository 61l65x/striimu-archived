from flask import Flask, request, jsonify
import jwt
import os

app = Flask(__name__)
JWT_SECRET = os.getenv('JWT_SECRET')

@app.before_request
def check_token():
    if request.endpoint not in ['login']:  # Define unprotected endpoints
        token = request.headers.get('Authorization')
        if not token:
            return jsonify({"message": "No token provided"}), 401
        try:
            jwt.decode(token, JWT_SECRET, algorithms=["HS256"])
        except jwt.ExpiredSignatureError:
            return jsonify({"message": "Token expired"}), 401
        except jwt.InvalidTokenError:
            return jsonify({"message": "Invalid token"}), 401

@app.route('/login', methods=['POST'])
def login():
    # Implement your login logic here
    pass

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
