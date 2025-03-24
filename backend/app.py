import os
from flask import Flask, request, jsonify, send_file, render_template
from flask_cors import CORS
from flask_jwt_extended import JWTManager, create_access_token, jwt_required, get_jwt_identity
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import datetime, timedelta
import qrcode
from io import BytesIO
import uuid
import json
import logging
import sys
from sqlalchemy import text
import time

from models import db, User, MenuItem, MealPlan, Transaction, MealConsumption

# Configure logging to show more details
logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)

app = Flask(__name__)
# Configure CORS to accept requests from your Flutter app
CORS(app, resources={
    r"/api/*": {
        "origins": ["http://localhost:3000", "http://localhost:5000", "http://127.0.0.1:5000"],
        "methods": ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        "allow_headers": ["Content-Type", "Authorization"],
        "supports_credentials": True
    }
})

app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///canteen.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['JWT_SECRET_KEY'] = os.environ.get('JWT_SECRET_KEY', 'super-secret-key')
app.config['JWT_ACCESS_TOKEN_EXPIRES'] = timedelta(hours=24)
app.config['UPLOAD_FOLDER'] = 'uploads'

jwt = JWTManager(app)
db.init_app(app)

@app.before_request
def log_request_info():
    logger.debug('Headers: %s', dict(request.headers))
    logger.debug('Body: %s', request.get_data())

@app.after_request
def after_request(response):
    logger.debug('Response: %s', response.get_data())
    return response

# Authentication routes
@app.route('/api/auth/login', methods=['POST'])
def login():
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')
    
    user = User.query.filter_by(username=username).first()
    
    if not user or not check_password_hash(user.password_hash, password):
        return jsonify({'message': 'Invalid credentials'}), 401
    
    access_token = create_access_token(identity=user.id)
    return jsonify({
        'access_token': access_token,
        'user': {
            'id': user.id,
            'username': user.username,
            'email': user.email,
            'name': user.name,
            'role': user.role
        }
    }), 200

@app.route('/api/auth/register', methods=['POST'])
def register():
    data = request.get_json()
    
    # Check if username or email already exists
    if User.query.filter_by(username=data['username']).first():
        return jsonify({'message': 'Username already exists'}), 400
    
    if User.query.filter_by(email=data['email']).first():
        return jsonify({'message': 'Email already exists'}), 400
    
    # Handle both name and full_name fields
    name = data.get('name') or data.get('full_name')
    if not name:
        return jsonify({'message': 'Name is required'}), 400
    
    user = User(
        username=data['username'],
        email=data['email'],
        name=name,
        role='user'
    )
    user.set_password(data['password'])
    
    db.session.add(user)
    db.session.commit()
    
    access_token = create_access_token(identity=user.id)
    return jsonify({
        'access_token': access_token,
        'user': {
            'id': user.id,
            'username': user.username,
            'email': user.email,
            'name': user.name,
            'role': user.role
        }
    }), 201

# Menu endpoints
@app.route('/api/menu', methods=['GET'])
@jwt_required()
def get_menu():
    try:
        menu_items = MenuItem.query.all()
        return jsonify([item.to_dict() for item in menu_items])
    except Exception as e:
        logger.error(f"Error fetching menu: {str(e)}")
        return jsonify({'error': 'Failed to fetch menu'}), 500

@app.route('/api/menu', methods=['POST'])
@jwt_required()
def add_menu_item():
    try:
        data = request.get_json()
        new_item = MenuItem(
            name=data['name'],
            description=data['description'],
            price=data['price'],
            category=data['category'],
            is_available=data.get('is_available', True)
        )
        db.session.add(new_item)
        db.session.commit()
        return jsonify(new_item.to_dict()), 201
    except Exception as e:
        logger.error(f"Error adding menu item: {str(e)}")
        return jsonify({'error': 'Failed to add menu item'}), 500

@app.route('/api/menu/<int:item_id>', methods=['PUT'])
@jwt_required()
def update_menu_item(item_id):
    try:
        item = MenuItem.query.get_or_404(item_id)
        data = request.get_json()
        item.name = data.get('name', item.name)
        item.description = data.get('description', item.description)
        item.price = data.get('price', item.price)
        item.category = data.get('category', item.category)
        item.is_available = data.get('is_available', item.is_available)
        db.session.commit()
        return jsonify(item.to_dict())
    except Exception as e:
        logger.error(f"Error updating menu item: {str(e)}")
        return jsonify({'error': 'Failed to update menu item'}), 500

@app.route('/api/menu/<int:item_id>', methods=['DELETE'])
@jwt_required()
def delete_menu_item(item_id):
    try:
        item = MenuItem.query.get_or_404(item_id)
        db.session.delete(item)
        db.session.commit()
        return '', 204
    except Exception as e:
        logger.error(f"Error deleting menu item: {str(e)}")
        return jsonify({'error': 'Failed to delete menu item'}), 500

# Transaction endpoints
@app.route('/api/transactions', methods=['GET'])
@jwt_required()
def get_transactions():
    try:
        user_id = get_jwt_identity()
        transactions = Transaction.query.filter_by(user_id=user_id).order_by(Transaction.created_at.desc()).all()
        return jsonify([t.to_dict() for t in transactions])
    except Exception as e:
        logger.error(f"Error fetching transactions: {str(e)}")
        return jsonify({'error': 'Failed to fetch transactions'}), 500

@app.route('/api/transactions/<int:transaction_id>', methods=['GET'])
@jwt_required()
def get_transaction(transaction_id):
    try:
        transaction = Transaction.query.get_or_404(transaction_id)
        if transaction.user_id != get_jwt_identity():
            return jsonify({'error': 'Unauthorized'}), 403
        return jsonify(transaction.to_dict())
    except Exception as e:
        logger.error(f"Error fetching transaction: {str(e)}")
        return jsonify({'error': 'Failed to fetch transaction'}), 500

# Meal Plan endpoints
@app.route('/api/meal-plan', methods=['GET'])
@jwt_required()
def get_meal_plan():
    try:
        user_id = get_jwt_identity()
        meal_plan = MealPlan.query.filter_by(user_id=user_id).first()
        if not meal_plan:
            return jsonify({'error': 'No meal plan found'}), 404
        return jsonify(meal_plan.to_dict())
    except Exception as e:
        logger.error(f"Error fetching meal plan: {str(e)}")
        return jsonify({'error': 'Failed to fetch meal plan'}), 500

@app.route('/api/meal-plan', methods=['POST'])
@jwt_required()
def create_meal_plan():
    try:
        user_id = get_jwt_identity()
        data = request.get_json()
        meal_plan = MealPlan(
            user_id=user_id,
            plan_type=data['plan_type'],
            start_date=datetime.fromisoformat(data['start_date']),
            end_date=datetime.fromisoformat(data['end_date'])
        )
        db.session.add(meal_plan)
        db.session.commit()
        return jsonify(meal_plan.to_dict()), 201
    except Exception as e:
        logger.error(f"Error creating meal plan: {str(e)}")
        return jsonify({'error': 'Failed to create meal plan'}), 500

@app.route('/api/meal-plan/<int:plan_id>', methods=['PUT'])
@jwt_required()
def update_meal_plan(plan_id):
    try:
        meal_plan = MealPlan.query.get_or_404(plan_id)
        if meal_plan.user_id != get_jwt_identity():
            return jsonify({'error': 'Unauthorized'}), 403
        data = request.get_json()
        meal_plan.plan_type = data.get('plan_type', meal_plan.plan_type)
        meal_plan.start_date = datetime.fromisoformat(data.get('start_date', meal_plan.start_date.isoformat()))
        meal_plan.end_date = datetime.fromisoformat(data.get('end_date', meal_plan.end_date.isoformat()))
        db.session.commit()
        return jsonify(meal_plan.to_dict())
    except Exception as e:
        logger.error(f"Error updating meal plan: {str(e)}")
        return jsonify({'error': 'Failed to update meal plan'}), 500

@app.route('/api/meal-plan/<int:plan_id>', methods=['DELETE'])
@jwt_required()
def delete_meal_plan(plan_id):
    try:
        meal_plan = MealPlan.query.get_or_404(plan_id)
        if meal_plan.user_id != get_jwt_identity():
            return jsonify({'error': 'Unauthorized'}), 403
        db.session.delete(meal_plan)
        db.session.commit()
        return '', 204
    except Exception as e:
        logger.error(f"Error deleting meal plan: {str(e)}")
        return jsonify({'error': 'Failed to delete meal plan'}), 500

# Health check endpoint
@app.route('/api/health', methods=['GET'])
def health_check():
    try:
        # Test database connection
        db.session.execute(text('SELECT 1'))
        return jsonify({
            'status': 'success',
            'message': 'Server is healthy',
            'database': 'connected',
            'timestamp': datetime.utcnow().isoformat()
        }), 200
    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': 'Server health check failed',
            'error': str(e)
        }), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=True)
