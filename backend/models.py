from flask_sqlalchemy import SQLAlchemy
from datetime import datetime
import uuid

db = SQLAlchemy()

class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(128), nullable=False)
    full_name = db.Column(db.String(100), nullable=False)
    role = db.Column(db.String(20), default='user')  # 'user', 'staff', 'admin'
    balance = db.Column(db.Float, default=0.0)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    qr_code = db.relationship('QRCode', backref='user', uselist=False)
    transactions = db.relationship('Transaction', backref='user', lazy=True)
    meal_plan = db.relationship('MealPlan', backref='user', uselist=False)

    def __repr__(self):
        return f'<User {self.username}>'

class QRCode(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    uuid = db.Column(db.String(36), unique=True, default=lambda: str(uuid.uuid4()))
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    last_used = db.Column(db.DateTime, nullable=True)
    is_active = db.Column(db.Boolean, default=True)

    def __repr__(self):
        return f'<QRCode {self.uuid}>'

class MealPlan(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    plan_type = db.Column(db.String(50), nullable=False)  # 'daily', 'weekly', 'monthly'
    meals_remaining = db.Column(db.Integer, default=0)
    breakfast_allowed = db.Column(db.Boolean, default=True)
    lunch_allowed = db.Column(db.Boolean, default=True)
    dinner_allowed = db.Column(db.Boolean, default=True)
    start_date = db.Column(db.DateTime, default=datetime.utcnow)
    end_date = db.Column(db.DateTime, nullable=True)
    
    def __repr__(self):
        return f'<MealPlan {self.plan_type} for User {self.user_id}>'

class MenuItem(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    description = db.Column(db.Text, nullable=True)
    price = db.Column(db.Float, nullable=False)
    category = db.Column(db.String(50), nullable=False)  # 'breakfast', 'lunch', 'dinner', 'snack'
    is_available = db.Column(db.Boolean, default=True)
    image_url = db.Column(db.String(255), nullable=True)
    
    def __repr__(self):
        return f'<MenuItem {self.name}>'

class Transaction(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    amount = db.Column(db.Float, nullable=False)
    transaction_type = db.Column(db.String(20), nullable=False)  # 'meal', 'extra_item', 'recharge'
    description = db.Column(db.Text, nullable=True)
    timestamp = db.Column(db.DateTime, default=datetime.utcnow)
    meal_type = db.Column(db.String(20), nullable=True)  # 'breakfast', 'lunch', 'dinner'
    status = db.Column(db.String(20), default='completed')  # 'pending', 'completed', 'failed'
    
    def __repr__(self):
        return f'<Transaction {self.id} - {self.amount}>'

class MealConsumption(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    meal_type = db.Column(db.String(20), nullable=False)  # 'breakfast', 'lunch', 'dinner'
    timestamp = db.Column(db.DateTime, default=datetime.utcnow)
    
    def __repr__(self):
        return f'<MealConsumption {self.meal_type} by User {self.user_id}>' 