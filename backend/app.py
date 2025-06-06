from flask import Flask, request, jsonify

app = Flask(__name__)

# Dados de exemplo em memória
alerts = []

@app.route('/api/login', methods=['POST'])
def login():
    data = request.json
    # Implementar validação real
    if data.get('username') and data.get('password'):
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
    app.run(debug=True)
