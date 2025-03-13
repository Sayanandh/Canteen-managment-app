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

from models import db, User, QRCode, MealPlan, MenuItem, Transaction, MealConsumption

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
        "origins": "*",
        "methods": ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        "allow_headers": ["Content-Type", "Authorization"]
    }
})

app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///canteen.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['JWT_SECRET_KEY'] = os.environ.get('JWT_SECRET_KEY', 'super-secret-key')
app.config['JWT_ACCESS_TOKEN_EXPIRES'] = timedelta(hours=24)

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

def init_db():
    with app.app_context():
        db.create_all()
        # Create admin user if not exists
        admin = User.query.filter_by(username='admin').first()
        if not admin:
            admin = User(
                username='admin',
                email='admin@example.com',
                password_hash=generate_password_hash('admin123'),
                full_name='Admin User',
                role='admin',
                balance=1000.0
            )
            db.session.add(admin)
            db.session.commit()
            
            # Create QR code for admin
            qr_code = QRCode(user_id=admin.id)
            db.session.add(qr_code)
            db.session.commit()

# Initialize database
init_db()

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
            'full_name': user.full_name,
            'role': user.role,
            'balance': user.balance
        }
    }), 200

@app.route('/api/auth/register', methods=['POST'])
def register():
    logger.info('Registration request received')
    logger.debug('Request Headers: %s', dict(request.headers))
    
    try:
        data = request.get_json()
        logger.debug('Registration data received: %s', data)
    except Exception as e:
        logger.error('Failed to parse JSON data: %s', str(e))
        return jsonify({
            'success': False,
            'message': 'Invalid JSON data'
        }), 400
    
    if not all(key in data for key in ['username', 'email', 'password', 'full_name']):
        logger.error('Missing required fields in registration data')
        return jsonify({
            'success': False,
            'message': 'Missing required fields'
        }), 400
    
    # Check if username or email already exists
    if User.query.filter_by(username=data['username']).first():
        logger.warning(f'Username {data["username"]} already exists')
        return jsonify({'success': False, 'message': 'Username already exists'}), 400
    
    if User.query.filter_by(email=data['email']).first():
        logger.warning(f'Email {data["email"]} already exists')
        return jsonify({'success': False, 'message': 'Email already exists'}), 400
    
    try:
        # Create new user
        logger.info('Creating new user')
        new_user = User(
            username=data['username'],
            email=data['email'],
            password_hash=generate_password_hash(data['password']),
            full_name=data['full_name'],
            role='user',
            balance=0.0
        )
        
        db.session.add(new_user)
        db.session.commit()
        logger.info(f'User created with ID: {new_user.id}')
        
        # Create QR code for the new user
        logger.info('Creating QR code for user')
        qr_code = QRCode(user_id=new_user.id)
        db.session.add(qr_code)
        db.session.commit()
        logger.info('QR code created')
        
        # Create access token for auto-login
        access_token = create_access_token(identity=new_user.id)
        logger.info('Access token created')
        
        response_data = {
            'success': True,
            'message': 'User registered successfully',
            'access_token': access_token,
            'user': {
                'id': new_user.id,
                'username': new_user.username,
                'email': new_user.email,
                'full_name': new_user.full_name,
                'role': new_user.role,
                'balance': new_user.balance
            }
        }
        logger.info('Registration successful')
        return jsonify(response_data), 201
        
    except Exception as e:
        logger.error(f'Error during registration: {str(e)}')
        logger.error('Stack trace:', exc_info=True)
        db.session.rollback()
        return jsonify({
            'success': False,
            'message': f'Registration failed: {str(e)}'
        }), 500

# QR Code routes
@app.route('/api/qrcode/<user_id>', methods=['GET'])
@jwt_required()
def get_qrcode(user_id):
    current_user_id = get_jwt_identity()
    
    # Only admin or the user themselves can access their QR code
    if str(current_user_id) != user_id and User.query.get(current_user_id).role != 'admin':
        return jsonify({'message': 'Unauthorized'}), 403
    
    user = User.query.get(user_id)
    if not user:
        return jsonify({'message': 'User not found'}), 404
    
    qr_code = QRCode.query.filter_by(user_id=user_id, is_active=True).first()
    if not qr_code:
        return jsonify({'message': 'QR code not found'}), 404
    
    # Generate QR code image
    qr = qrcode.QRCode(
        version=1,
        error_correction=qrcode.constants.ERROR_CORRECT_L,
        box_size=10,
        border=4,
    )
    qr.add_data(qr_code.uuid)
    qr.make(fit=True)
    
    img = qr.make_image(fill_color="black", back_color="white")
    
    # Save to BytesIO object
    img_io = BytesIO()
    img.save(img_io, 'PNG')
    img_io.seek(0)
    
    return send_file(img_io, mimetype='image/png')

@app.route('/api/qrcode/regenerate/<user_id>', methods=['POST'])
@jwt_required()
def regenerate_qrcode(user_id):
    current_user_id = get_jwt_identity()
    
    # Only admin or the user themselves can regenerate their QR code
    if str(current_user_id) != user_id and User.query.get(current_user_id).role != 'admin':
        return jsonify({'message': 'Unauthorized'}), 403
    
    # Deactivate old QR code
    old_qr = QRCode.query.filter_by(user_id=user_id, is_active=True).first()
    if old_qr:
        old_qr.is_active = False
        db.session.commit()
    
    # Create new QR code
    new_qr = QRCode(user_id=user_id)
    db.session.add(new_qr)
    db.session.commit()
    
    return jsonify({'message': 'QR code regenerated successfully'}), 200

# Meal verification routes
@app.route('/api/meal/verify', methods=['POST'])
@jwt_required()
def verify_meal():
    current_user_id = get_jwt_identity()
    current_user = User.query.get(current_user_id)
    
    # Only staff or admin can verify meals
    if current_user.role not in ['staff', 'admin']:
        return jsonify({'message': 'Unauthorized'}), 403
    
    data = request.get_json()
    qr_uuid = data.get('qr_uuid')
    meal_type = data.get('meal_type')  # 'breakfast', 'lunch', 'dinner'
    
    if not qr_uuid or not meal_type:
        return jsonify({'message': 'QR UUID and meal type are required'}), 400
    
    # Find the QR code
    qr_code = QRCode.query.filter_by(uuid=qr_uuid, is_active=True).first()
    if not qr_code:
        return jsonify({'message': 'Invalid QR code'}), 404
    
    user = User.query.get(qr_code.user_id)
    meal_plan = MealPlan.query.filter_by(user_id=user.id).first()
    
    # Check if user has a meal plan
    if not meal_plan:
        return jsonify({
            'message': 'No meal plan found',
            'user': {
                'id': user.id,
                'full_name': user.full_name,
                'balance': user.balance
            }
        }), 400
    
    # Check if meal is allowed for this user at this time
    current_time = datetime.utcnow()
    
    # Check if meal plan is active
    if meal_plan.end_date and current_time > meal_plan.end_date:
        return jsonify({
            'message': 'Meal plan expired',
            'user': {
                'id': user.id,
                'full_name': user.full_name,
                'balance': user.balance
            }
        }), 400
    
    # Check if user has meals remaining
    if meal_plan.meals_remaining <= 0:
        return jsonify({
            'message': 'No meals remaining in plan',
            'user': {
                'id': user.id,
                'full_name': user.full_name,
                'balance': user.balance
            }
        }), 400
    
    # Check if this meal type is allowed for the user
    meal_allowed = False
    if meal_type == 'breakfast' and meal_plan.breakfast_allowed:
        meal_allowed = True
    elif meal_type == 'lunch' and meal_plan.lunch_allowed:
        meal_allowed = True
    elif meal_type == 'dinner' and meal_plan.dinner_allowed:
        meal_allowed = True
    
    if not meal_allowed:
        return jsonify({
            'message': f'{meal_type.capitalize()} is not included in the meal plan',
            'user': {
                'id': user.id,
                'full_name': user.full_name,
                'balance': user.balance
            }
        }), 400
    
    # Check if user already had this meal today
    today_start = datetime.utcnow().replace(hour=0, minute=0, second=0, microsecond=0)
    today_end = today_start + timedelta(days=1)
    
    meal_today = MealConsumption.query.filter_by(
        user_id=user.id,
        meal_type=meal_type
    ).filter(
        MealConsumption.timestamp >= today_start,
        MealConsumption.timestamp < today_end
    ).first()
    
    if meal_today:
        return jsonify({
            'message': f'User already had {meal_type} today',
            'user': {
                'id': user.id,
                'full_name': user.full_name,
                'balance': user.balance
            }
        }), 400
    
    # Record meal consumption
    meal_consumption = MealConsumption(
        user_id=user.id,
        meal_type=meal_type
    )
    db.session.add(meal_consumption)
    
    # Update meal plan
    meal_plan.meals_remaining -= 1
    
    # Update QR code last used
    qr_code.last_used = datetime.utcnow()
    
    # Create transaction record
    transaction = Transaction(
        user_id=user.id,
        amount=0.0,  # No charge for regular meal
        transaction_type='meal',
        description=f'{meal_type.capitalize()} consumed',
        meal_type=meal_type
    )
    db.session.add(transaction)
    
    db.session.commit()
    
    return jsonify({
        'message': 'Meal verified successfully',
        'user': {
            'id': user.id,
            'full_name': user.full_name,
            'balance': user.balance,
            'meals_remaining': meal_plan.meals_remaining
        }
    }), 200

# Extra item purchase routes
@app.route('/api/purchase/extra', methods=['POST'])
@jwt_required()
def purchase_extra():
    current_user_id = get_jwt_identity()
    current_user = User.query.get(current_user_id)
    
    # Only staff or admin can process purchases
    if current_user.role not in ['staff', 'admin']:
        return jsonify({'message': 'Unauthorized'}), 403
    
    data = request.get_json()
    qr_uuid = data.get('qr_uuid')
    items = data.get('items')  # List of {item_id, quantity}
    
    if not qr_uuid or not items:
        return jsonify({'message': 'QR UUID and items are required'}), 400
    
    # Find the QR code
    qr_code = QRCode.query.filter_by(uuid=qr_uuid, is_active=True).first()
    if not qr_code:
        return jsonify({'message': 'Invalid QR code'}), 404
    
    user = User.query.get(qr_code.user_id)
    
    # Calculate total amount
    total_amount = 0
    item_details = []
    
    for item in items:
        menu_item = MenuItem.query.get(item['item_id'])
        if not menu_item:
            return jsonify({'message': f'Item with ID {item["item_id"]} not found'}), 404
        
        if not menu_item.is_available:
            return jsonify({'message': f'Item {menu_item.name} is not available'}), 400
        
        item_total = menu_item.price * item['quantity']
        total_amount += item_total
        
        item_details.append({
            'name': menu_item.name,
            'price': menu_item.price,
            'quantity': item['quantity'],
            'total': item_total
        })
    
    # Check if user has enough balance
    if user.balance < total_amount:
        return jsonify({
            'message': 'Insufficient balance',
            'user': {
                'id': user.id,
                'full_name': user.full_name,
                'balance': user.balance
            },
            'required': total_amount
        }), 400
    
    # Update user balance
    user.balance -= total_amount
    
    # Update QR code last used
    qr_code.last_used = datetime.utcnow()
    
    # Create transaction record
    transaction = Transaction(
        user_id=user.id,
        amount=total_amount,
        transaction_type='extra_item',
        description=f'Purchase of extra items: {json.dumps(item_details)}'
    )
    db.session.add(transaction)
    
    db.session.commit()
    
    return jsonify({
        'message': 'Purchase successful',
        'user': {
            'id': user.id,
            'full_name': user.full_name,
            'balance': user.balance
        },
        'transaction': {
            'id': transaction.id,
            'amount': total_amount,
            'items': item_details,
            'timestamp': transaction.timestamp.isoformat()
        }
    }), 200

# Balance management routes
@app.route('/api/balance/add', methods=['POST'])
@jwt_required()
def add_balance():
    current_user_id = get_jwt_identity()
    current_user = User.query.get(current_user_id)
    
    data = request.get_json()
    user_id = data.get('user_id')
    amount = data.get('amount')
    
    # Regular users can only add to their own balance
    if current_user.role not in ['staff', 'admin'] and str(current_user_id) != user_id:
        return jsonify({'message': 'Unauthorized'}), 403
    
    user = User.query.get(user_id)
    if not user:
        return jsonify({'message': 'User not found'}), 404
    
    if amount <= 0:
        return jsonify({'message': 'Amount must be positive'}), 400
    
    # Update user balance
    user.balance += amount
    
    # Create transaction record
    transaction = Transaction(
        user_id=user.id,
        amount=amount,
        transaction_type='recharge',
        description=f'Balance recharge of {amount}'
    )
    db.session.add(transaction)
    
    db.session.commit()
    
    return jsonify({
        'message': 'Balance added successfully',
        'user': {
            'id': user.id,
            'full_name': user.full_name,
            'balance': user.balance
        },
        'transaction': {
            'id': transaction.id,
            'amount': amount,
            'timestamp': transaction.timestamp.isoformat()
        }
    }), 200

# Menu Management API
@app.route('/api/menu', methods=['GET'])
def get_menu_items():
    page = request.args.get('page', 1, type=int)
    per_page = request.args.get('per_page', 20, type=int)
    
    menu_items = MenuItem.query.paginate(page=page, per_page=per_page)
    
    return jsonify({
        'items': [{
            'id': item.id,
            'name': item.name,
            'description': item.description,
            'price': item.price,
            'category': item.category
        } for item in menu_items.items],
        'pagination': {
            'total_items': menu_items.total,
            'total_pages': menu_items.pages,
            'current_page': page,
            'per_page': per_page
        }
    }), 200

@app.route('/api/menu', methods=['POST'])
def add_menu_item():
    data = request.get_json()
    
    menu_item = MenuItem(
        name=data['name'],
        description=data.get('description', ''),
        price=data['price'],
        category=data['category']
    )
    
    db.session.add(menu_item)
    db.session.commit()
    
    return jsonify({
        'id': menu_item.id,
        'name': menu_item.name,
        'description': menu_item.description,
        'price': menu_item.price,
        'category': menu_item.category
    }), 201

@app.route('/api/menu/<int:item_id>', methods=['DELETE'])
def delete_menu_item(item_id):
    menu_item = MenuItem.query.get_or_404(item_id)
    db.session.delete(menu_item)
    db.session.commit()
    return '', 204

# User Management API
@app.route('/api/users', methods=['GET'])
def get_users():
    page = request.args.get('page', 1, type=int)
    per_page = request.args.get('per_page', 20, type=int)
    role = request.args.get('role')
    status = request.args.get('status')
    search = request.args.get('search')
    
    query = User.query
    
    if role and role != 'all':
        query = query.filter(User.role == role)
    
    if search:
        search = f"%{search}%"
        query = query.filter(
            db.or_(
                User.username.ilike(search),
                User.email.ilike(search),
                User.full_name.ilike(search)
            )
        )
    
    users = query.paginate(page=page, per_page=per_page)
    
    return jsonify({
        'users': [{
            'id': user.id,
            'username': user.username,
            'email': user.email,
            'full_name': user.full_name,
            'role': user.role,
            'balance': user.balance,
            'status': 'active'  # You might want to add a status field to your User model
        } for user in users.items],
        'pagination': {
            'total_items': users.total,
            'total_pages': users.pages,
            'current_page': page,
            'per_page': per_page
        }
    }), 200

@app.route('/api/users', methods=['POST'])
def create_user():
    data = request.get_json()
    
    # Check if username or email already exists
    if User.query.filter_by(username=data['username']).first():
        return jsonify({'message': 'Username already exists'}), 400
    
    if User.query.filter_by(email=data['email']).first():
        return jsonify({'message': 'Email already exists'}), 400
    
    user = User(
        username=data['username'],
        email=data['email'],
        full_name=data['full_name'],
        password_hash=generate_password_hash(data['password']),
        role=data['role'],
        balance=data.get('balance', 0.0)
    )
    
    db.session.add(user)
    db.session.commit()
    
    # Create QR code for the user
    qr_code = QRCode(user_id=user.id)
    db.session.add(qr_code)
    db.session.commit()
    
    return jsonify({
        'id': user.id,
        'username': user.username,
        'email': user.email,
        'full_name': user.full_name,
        'role': user.role,
        'balance': user.balance
    }), 201

@app.route('/api/users/<int:user_id>', methods=['GET'])
def get_user(user_id):
    user = User.query.get_or_404(user_id)
    return jsonify({
        'id': user.id,
        'username': user.username,
        'email': user.email,
        'full_name': user.full_name,
        'role': user.role,
        'balance': user.balance
    }), 200

@app.route('/api/users/<int:user_id>', methods=['DELETE'])
def delete_user(user_id):
    user = User.query.get_or_404(user_id)
    
    # Don't allow deleting the last admin
    if user.role == 'admin' and User.query.filter_by(role='admin').count() <= 1:
        return jsonify({'message': 'Cannot delete the last admin user'}), 400
    
    db.session.delete(user)
    db.session.commit()
    return '', 204

# Transaction API with filters
@app.route('/api/transactions', methods=['GET'])
def get_all_transactions():
    page = request.args.get('page', 1, type=int)
    per_page = request.args.get('per_page', 20, type=int)
    date_range = request.args.get('date_range', 'all')
    type_filter = request.args.get('type', 'all')
    status = request.args.get('status', 'all')
    search = request.args.get('search')
    
    query = Transaction.query
    
    # Apply date range filter
    if date_range == 'today':
        today = datetime.utcnow().date()
        query = query.filter(
            db.func.date(Transaction.timestamp) == today
        )
    elif date_range == 'week':
        week_ago = datetime.utcnow() - timedelta(days=7)
        query = query.filter(Transaction.timestamp >= week_ago)
    elif date_range == 'month':
        month_ago = datetime.utcnow() - timedelta(days=30)
        query = query.filter(Transaction.timestamp >= month_ago)
    
    # Apply transaction type filter
    if type_filter != 'all':
        query = query.filter(Transaction.transaction_type == type_filter)
    
    # Apply status filter
    if status != 'all':
        query = query.filter(Transaction.status == status)
    
    # Apply search filter
    if search:
        search = f"%{search}%"
        query = query.join(User).filter(
            db.or_(
                Transaction.id.ilike(search),
                User.username.ilike(search),
                User.full_name.ilike(search)
            )
        )
    
    transactions = query.order_by(Transaction.timestamp.desc()).paginate(
        page=page, per_page=per_page
    )
    
    return jsonify({
        'transactions': [{
            'id': tx.id,
            'user_id': tx.user_id,
            'user_name': User.query.get(tx.user_id).full_name,
            'amount': tx.amount,
            'transaction_type': tx.transaction_type,
            'description': tx.description,
            'timestamp': tx.timestamp.isoformat(),
            'meal_type': tx.meal_type,
            'status': tx.status
        } for tx in transactions.items],
        'pagination': {
            'total_items': transactions.total,
            'total_pages': transactions.pages,
            'current_page': page,
            'per_page': per_page
        }
    }), 200

# Admin Interface Routes
@app.route('/admin')
def admin_dashboard():
    return render_template('admin.html')

@app.route('/admin/users')
def admin_users():
    return render_template('users.html')

@app.route('/admin/transactions')
def admin_transactions():
    return render_template('transactions.html')

# Admin API Routes for Dashboard Data
@app.route('/api/admin/dashboard/stats', methods=['GET'])
def get_dashboard_stats():
    # Get total users
    total_users = User.query.filter(User.role == 'user').count()
    
    # Get today's transactions
    today = datetime.utcnow().date()
    today_start = datetime.combine(today, datetime.min.time())
    today_end = datetime.combine(today, datetime.max.time())
    
    today_transactions = Transaction.query.filter(
        Transaction.timestamp >= today_start,
        Transaction.timestamp <= today_end
    ).all()
    
    # Calculate total revenue
    total_revenue = sum(tx.amount for tx in today_transactions if tx.transaction_type != 'meal')
    
    # Get meal consumption stats
    meals_today = MealConsumption.query.filter(
        MealConsumption.timestamp >= today_start,
        MealConsumption.timestamp <= today_end
    ).count()
    
    return jsonify({
        'total_users': total_users,
        'today_transactions': len(today_transactions),
        'today_revenue': total_revenue,
        'meals_served_today': meals_today
    }), 200

@app.route('/api/admin/users/stats', methods=['GET'])
def get_user_stats():
    total_users = User.query.filter(User.role == 'user').count()
    active_meal_plans = MealPlan.query.filter(
        MealPlan.end_date >= datetime.utcnow()
    ).count()
    
    return jsonify({
        'total_users': total_users,
        'active_meal_plans': active_meal_plans
    }), 200

@app.route('/api/admin/transactions/stats', methods=['GET'])
def get_transaction_stats():
    # Get transaction counts by type
    meal_count = Transaction.query.filter_by(transaction_type='meal').count()
    recharge_count = Transaction.query.filter_by(transaction_type='recharge').count()
    extra_count = Transaction.query.filter_by(transaction_type='extra_item').count()
    
    return jsonify({
        'meal_transactions': meal_count,
        'recharge_transactions': recharge_count,
        'extra_item_transactions': extra_count
    }), 200

# Add a test route
@app.route('/')
def test_server():
    return jsonify({
        'status': 'success',
        'message': 'Flask server is running'
    })

if __name__ == '__main__':
    # Run the app on all network interfaces
    app.run(host='0.0.0.0', port=5000, debug=True) 