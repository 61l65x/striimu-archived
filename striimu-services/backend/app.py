from flask import Flask, request, jsonify
import requests
import os

app = Flask(__name__)
AUTH_SERVICE_URL = os.getenv('AUTH_SERVICE_URL')

@app.before_request
def check_token():
    if request.endpoint not in ['login']:  # Define unprotected endpoints
        token = request.headers.get('Authorization')
        if not token:
            return jsonify({"message": "No token provided"}), 401
        response = requests.get(AUTH_SERVICE_URL, headers={'Authorization': token})
        if response.status_code != 200:
            return jsonify(response.json()), response.status_code

@app.route('/login', methods=['POST'])
def login():
    # Implement your login logic here
    return jsonify({"message": "Login logic not implemented"}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
