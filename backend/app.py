import os
from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from werkzeug.security import generate_password_hash, check_password_hash

app = Flask(__name__)

# Database configuration for Railway MySQL
db_url = os.getenv("DATABASE_URL")
if not db_url:
    host = os.getenv("MYSQLHOST", "localhost")
    user = os.getenv("MYSQLUSER", "root")
    password = os.getenv("MYSQLPASSWORD", "")
    database = os.getenv("MYSQLDATABASE", "test")
    port = os.getenv("MYSQLPORT", "3306")
    db_url = f"mysql+pymysql://{user}:{password}@{host}:{port}/{database}"

app.config["SQLALCHEMY_DATABASE_URI"] = db_url
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

db = SQLAlchemy(app)

# Simple alerts storage in memory
alerts = []


class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    password_hash = db.Column(db.String(255), nullable=False)


@app.before_first_request
def create_tables():
    db.create_all()

@app.route('/api/register', methods=['POST'])
def register():
    """Register a new user."""
    data = request.json or {}
    username = data.get("username")
    password = data.get("password")
    if not username or not password:
        return jsonify({"error": "Username and password required"}), 400
    if User.query.filter_by(username=username).first():
        return jsonify({"error": "User already exists"}), 400
    user = User(username=username, password_hash=generate_password_hash(password))
    db.session.add(user)
    db.session.commit()
    return jsonify({"id": user.id, "username": user.username}), 201


@app.route('/api/login', methods=['POST'])
def login():
    """Validate user credentials."""
    data = request.json or {}
    username = data.get('username')
    password = data.get('password')
    if not username or not password:
        return jsonify({'success': False}), 400
    user = User.query.filter_by(username=username).first()
    if user and check_password_hash(user.password_hash, password):
        return jsonify({'success': True})
    return jsonify({'success': False}), 401

@app.route('/api/alerts', methods=['GET'])
def list_alerts():
    return jsonify(alerts)

@app.route('/api/alerts', methods=['POST'])
def create_alert():
    alert = request.json
    alerts.append(alert)
    return jsonify(alert), 201

@app.route('/api/alerts/<int:alert_id>', methods=['PUT'])
def update_alert(alert_id):
    if 0 <= alert_id < len(alerts):
        alerts[alert_id] = request.json
        return jsonify(alerts[alert_id])
    return jsonify({'error': 'Not found'}), 404

@app.route('/api/alerts/<int:alert_id>', methods=['DELETE'])
def delete_alert(alert_id):
    if 0 <= alert_id < len(alerts):
        removed = alerts.pop(alert_id)
        return jsonify(removed)
    return jsonify({'error': 'Not found'}), 404

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=True)
